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
