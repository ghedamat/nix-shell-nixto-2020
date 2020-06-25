with (import (fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) {});
mkShell {
  buildInputs = [
    git-up
  ];
}
