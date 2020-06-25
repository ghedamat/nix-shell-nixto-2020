with (import <nixpkgs> { });
let
  # define packages to install with special handling for OSX
  basePackages = [
    python
    nodejs-12_x
    yarn
    gnumake
    gcc
    readline
    openssl
    zlib
    libxml2
    curl
    libiconv
    now-cli
  ];

  inputs = basePackages ++ lib.optional stdenv.isLinux inotify-tools
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  hooks = ''
    mkdir -p .nix-node
    export NODE_PATH=$PWD/.nix-node
    export NPM_CONFIG_PREFIX=$PWD/.nix-node
    export PATH=$NODE_PATH/bin:$PATH
  '';

in mkShell {
  buildInputs = inputs;
  shellHook = hooks;
}

