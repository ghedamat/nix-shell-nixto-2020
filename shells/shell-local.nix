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
