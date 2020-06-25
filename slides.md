---
marp: true
theme: default
paginate: false
---

# An introduction to `nix-shell`

What is it and how to use it

---

## Def: `nix-shell`

```
nix-shell — start an interactive shell based on a Nix expression
```
---

## Def: `nix-shell`
[Nix manual](https://nixos.org/nix/manual/#name-2)


> The command nix-shell will build the dependencies of the specified derivation, but not the derivation itself. 
> It will then start an interactive shell in which all environment variables defined by the derivation path have been set to their corresponding values, and the script $stdenv/setup has been sourced. This is useful for reproducing the environment of a derivation for development.

---


# <!--fit--> 🤔
---

## Def: `nix-shell`, translated

`nix-shell` will start an *interactive* `bash` shell, in the same directory that it is being run from.

This shell will have its `ENV` set appropriately so that all the packages in the shell definition are available.


---

## `nix-shell` to use a package without installing it globally

```
$ which rg
rg not found

$ nix-shell -p ripgrep
[nix-shell:~]$ which rg
/nix/store/rw24lqk4ls1b90k1jj0j1ld05kgqb8ac-ripgrep-11.0.2/bin/rg
```

---

## `nix-shell --packages`

```
$ nix-shell -p packagename
# or
$ nix-shell --packages packagename
```

Starts a `nix-shell` that has the package available in its `$PATH`

---

## `nix-shell --run`

```
$ nix-shell -p ripgrep --run "rg foo"
```

Executes the given command in a non-interactive shell

---

## `nix-shell --pure`

```
$ which wget
/usr/bin/wget

$ nix-shell --pure -p curl
[nix-shell:~]$ which wget
which not found
```

> If this flag is specified, the environment is almost entirely cleared before the interactive shell is started.

---

## A simple `shell.nix`

```nix
# save this as shell.nix
with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    ripgrep
  ];
}
```

```bash
$ nix-shell
[nix-shell:~]$ rg foo
# ... WIN
```

---

## Adding `shellHook`
```nix
with (import <nixpkgs> {});
mkShell {
  shellHook = ''
    alias ll="ls -l"
    export FOO=bar
  '';
}
```

```bash
$ nix-shell
[nix-shell:~]$ echo $FOO
bar

```


---

## A `Node` example

```nix
with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    nodejs-12_x
    yarn
  ];
  shellHook = ''
      mkdir -p .nix-node
      export NODE_PATH=$PWD/.nix-node
      export NPM_CONFIG_PREFIX=$PWD/.nix-node
      export PATH=$NODE_PATH/bin:$PATH
  '';
}
```

---

## A `Ruby/Rails` example

```nix
with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    nodejs-12_x
    ruby
    yarn
    gnumake
    gcc
    readline
    openssl
    zlib
    libiconv
    postgresql_11
    pkgconfig
    libxml2
    libxslt
  ];
  shellHook = ''
    mkdir -p .nix-gems

    export GEM_HOME=$PWD/.nix-gems
    export GEM_PATH=$GEM_HOME
    export PATH=$GEM_HOME/bin:$PATH
    export PATH=$PWD/bin:$PATH

    gem list -i ^bundler$ -v 1.17.3 || gem install bundler --version=1.17.3 --no-document
    bundle config build.nokogiri --use-system-libraries
    bundle config --local path vendor/cache
  '';
}
```

---

## `Ruby` and `bundix`

- In the "Nix way" a package and its dependecies are "reproducible", the final derivation we build is alwasy gonna be the same because the inputs will always be the same.
- Languages like `ruby`, `js` and others don't naturally have that
- The Nix ecosystem has a few ways to work around this problem
- For Ruby it's called `bundix`
- `bundix` runs against your `Gemfile` and generates a nix derivation for each `gem` in your project

---

## `ruby` and `bundix` #2

- run `bundix -l`
- source `gemset.nix` in your `shell.nix`
- use the `nix-shell`

```nix
with (import <nixpkgs> {});
let
  gems = bundlerEnv {
    name = "your-package";
    inherit ruby;
    gemdir = ./.;
  };
in mkShell {
  buildInputs = [gems ruby];
}
```

---

## Beyond `bundix`

Similar solutions exist for `Elixir`, `JavaScript` and other languages


---

## A python example

```nix
with (import <nixpkgs> {});
let
  my-python-packages = python-packages: with python-packages; [
    pandas
    requests
    # other python packages you want
  ];
  python-with-my-packages = python3.withPackages my-python-packages;
in
mkShell {
  buildInputs = [
    python-with-my-packages
  ];
  shellHook = ''
      mkdir -p .nix-node
      export NODE_PATH=$PWD/.nix-node
      export NPM_CONFIG_PREFIX=$PWD/.nix-node
      export PATH=$NODE_PATH/bin:$PATH
  '';
}
```

[Other python examples](https://thomazleite.com/posts/development-with-nix-python/)

---

## A `rust` example

```nix
with import <nixpkgs> {};
let src = fetchFromGitHub {
      owner = "mozilla";
      repo = "nixpkgs-mozilla";
      rev = "9f35c4b09fd44a77227e79ff0c1b4b6a69dff533";
      sha256 = "18h0nvh55b5an4gmlgfbvwbyqj91bklf1zymis6lbdh75571qaz0";
   };
in
with import "${src.out}/rust-overlay.nix" pkgs pkgs;
stdenv.mkDerivation {
  name = "rust-env";
  buildInputs = [
    # Note: to use use stable, just replace `nightly` with `stable`
    latest.rustChannels.nightly.rust

    # Add some extra dependencies from `pkgs`
    pkgconfig openssl
  ];

  # Set Environment Variables (<-- another way to do this)
  RUST_BACKTRACE = 1;
}
```

---

## Using a specific "Nix channel" 

```nix
with (import (fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) {});
mkShell {
  buildInputs = [
    git-up
  ];
}
```

---

## Sharing `nix-shell`

When sharing a `shell.nix` it can be helpful to "pin" the `<nixpkgs>` version

This is done by specifying a `sha` directly from Github

```nix
with (import (fetchTarball https://github.com/nixos/nixpkgs/archive/8531aee99f4907bd255545eb94468e52a79a44f1.tar.gz) {});
mkShell {
  buildInputs = [
    git-up
  ];
}
```

This pretty much guarantees that so long as you specify all the dependencies, and don't accidentally rely on something coming from the OS, everyone will have the same setup.


---

## Extending a shared shell - `shell.nix`

When sharing `shell.nix` it's nice to allow for customization

```nix
with (import <nixpkgs> {});
let
  basePackages = [ ripgrep ];
  localPath = ./local.nix;
  inputs = basePackages
    ++ lib.optional (builtins.pathExists localPath) (import localPath {}).inputs;

  baseHooks = ''
    alias ll="ls -l"
  '';

  shellHooks = baseHooks
    + lib.optionalString (builtins.pathExists localPath) (import localPath {}).hooks;

in mkShell {
  buildInputs = inputs;
  shellHook = shellHooks;
}
```

---

## Extending a shared shell - `local.nix`


```nix
{ pkgs ? import <nixpkgs> {} }:
{
  inputs = [ pkgs.curl ];
  hooks = ''
    alias ghedamat="mattia"
  '';
}
```

---

## Cross platform `nix-shell`

Nix works both on MacOS and Linux but there are some dependencies that are platform specific.

```nix
with (import <nixpkgs> {});
let
  basePackages = [
    ripgrep
  ];

  inputs = basePackages
    ++ lib.optional stdenv.isLinux inotify-tools
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        CoreFoundation
        CoreServices
      ]);

in mkShell {
  buildInputs = inputs;
}
```

---

## nix-shell and docker

- `nix-shell` works great to configure dependencies
- It does not solve for "services"
- Often you need `postgresql`, `redis` and more
- You could install them at a system level but `docker` is really good at this
- Solution: `docker-compose.yml` for services and `nix-shell` to run the code!

[Full blog post](https://ghedam.at/15502/speedy-development-environments-with-nix-and-docker)

---

## A few minor annoyances

Because `nix-shell` aims at providing a generic environment, the shell that is generate is free of most settings and environment variables.

This means no aliases, no auto-complete etc.

---

## Customizing the shell

- `nix-shell --run zsh` is a simple workaround
- [`direnv`](https://direnv.net/) can be used to take this a step further and "load" the `nix-shell` ENV without spawning a new shell
- [`lorri`](https://github.com/target/lorri) is another project that aims at replacing nix-shell by extending it.

---

## Nix-shell as an interpreter

[https://nixos.org/nix/manual/#use-as-a-intepreter](https://nixos.org/nix/manual/#use-as-a-intepreter)

```sh
#! /usr/bin/env nix-shell
#! nix-shell -i ruby -p ruby
puts 1+1

# installs ruby and outputs
$ 2
```


---

## Recap

- `nix-shell`s allow you to define development environments for pretty much any language in a consistent way
- It's also easy to support different versions of the same language!
- Adding `shell.nix` to your project can be used to ensure that everyone on the team has the same configuration
- `shell.nix` is also a great way to help new contributors get setup
- In my experience combining `docker` and `nix-shell` is the way to go!


---

## Fin

[@ghedamat](https://ghedam.at)
