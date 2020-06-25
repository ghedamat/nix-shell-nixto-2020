{ pkgs ? import <nixpkgs> {} }:
{
  inputs = [ pkgs.curl ];
  hooks = ''
    alias ghedamat="mattia"
  '';
}
