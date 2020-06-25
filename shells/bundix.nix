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
