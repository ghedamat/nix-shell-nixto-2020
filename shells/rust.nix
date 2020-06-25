with import <nixpkgs> {};
let src = fetchFromGitHub {
      owner = "mozilla";
      repo = "nixpkgs-mozilla";
      rev = "9f35c4b09fd44a77227e79ff0c1b4b6a69dff533";
      sha256 = "18h0nvh55b5an4gmlgfbvwbyqj91bklf1zymis6lbdh75571qaz0";
   };
in
with import "${src.out}/rust-overlay.nix" pkgs pkgs;
mkShell {
  buildInputs = [
    # Note: to use use stable, just replace `nightly` with `stable`
    latest.rustChannels.nightly.rust

    # Add some extra dependencies from `pkgs`
    pkgconfig openssl
  ];

  # Set Environment Variables (another way)
  RUST_BACKTRACE = 1;
}

