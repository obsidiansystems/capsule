{ pkgsFun ? import (import ./nix/nixpkgs/thunk.nix)

, rustOverlay ? import "${import ./nix/nixpkgs-mozilla/thunk.nix}/rust-overlay.nix"

# Rust manifest hash must be updated when rust-toolchain file changes.
, rustPackages ? pkgs.rustChannelOf {
    date = "2020-05-04";
    rustToolchain = ./rust-toolchain;
    sha256 = "044jbwgkdp2hr2v0qzxijhlg18raxwd27167hx0laz16bx9cclgx";
  }
, pkgs ? pkgsFun {
    overlays = [
      rustOverlay
    ];
  }

, gitignoreNix ? import ./nix/gitignore.nix/thunk.nix

}:

let
  rustPlatform = pkgs.makeRustPlatform {
    inherit (rustPackages) cargo;
    rustc = rustPackages.rust;
  };
  inherit (import gitignoreNix { inherit (pkgs) lib; }) gitignoreSource;
in rustPlatform.buildRustPackage {
  name = "capsule";
  src = gitignoreSource ./.;
  nativeBuildInputs = [ pkgs.openssl pkgs.pkgconfig ];
  buildInputs = [ rustPackages.rust-std ];
  verifyCargoDeps = true;

  # Cargo hash must be updated when Cargo.lock file changes.
  cargoSha256 = "0ly2vlnb9gck1dx9kxkmpgswx0xw89phgxinf8x6wmcp17haaqm9";
}
