with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    ripgrep
  ];
}
