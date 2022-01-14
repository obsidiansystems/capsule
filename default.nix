{ pkgsFun ? import (import ./nix/nixpkgs/thunk.nix)

, rustOverlay ? import "${import ./nix/nixpkgs-mozilla/thunk.nix}/rust-overlay.nix"

# Rust manifest hash must be updated when rust-toolchain file changes.
, rustPackages ? pkgs.rustChannelOf {
    date = "2020-05-04";
    rustToolchain = ./rust-toolchain;
    sha256 = "14qhjdqr2b4z7aasrcn6kxzj3l7fygx4mpa5d4s5d56l62sllhgq";
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
  cargoSha256 = "1c3511ms8ai9kym5qfbk5qrdwg7wn1xfp554zh3n50rf29nrkn3z";
}
