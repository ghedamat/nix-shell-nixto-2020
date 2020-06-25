with (import (fetchTarball https://github.com/nixos/nixpkgs/archive/8531aee99f4907bd255545eb94468e52a79a44f1.tar.gz) {});
mkShell {
  buildInputs = [
    git-up
  ];
}
