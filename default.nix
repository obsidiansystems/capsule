{ pkgs ? import (builtins.fetchTarball { # 2020-02-13 (nixos-19.09)
    url = "https://github.com/NixOS/nixpkgs/archive/e02fb6eaf70d4f6db37ce053edf79b731f13c838.tar.gz";
    sha256 = "1dbjbak57vl7kcgpm1y1nm4s74gjfzpfgk33xskdxj9hjphi6mws";
  }) {}

, fetch ? { private ? false, fetchSubmodules ? false, owner, repo, rev, sha256, ... }:
    if !fetchSubmodules && !private then builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz"; inherit sha256;
    } else (import <nixpkgs> {}).fetchFromGitHub {
      inherit owner repo rev sha256 fetchSubmodules private;
    }

, rustOverlay ? import
    "${fetch (builtins.fromJSON (builtins.readFile ./nix/nixpkgs-mozilla/github.json))}/rust-overlay.nix"
    pkgs
    pkgs

# Rust manifest hash must be updated when rust-toolchain file changes.
, rustPackages ? rustOverlay.rustChannelOf {
    date = "2020-05-04";
    rustToolchain = ./rust-toolchain;
    sha256 = "14qhjdqr2b4z7aasrcn6kxzj3l7fygx4mpa5d4s5d56l62sllhgq";
  }

, gitignoreNix ? fetch (builtins.fromJSON (builtins.readFile ./nix/gitignore.nix/github.json))

}:

let
  rustPlatform = pkgs.makeRustPlatform {
    inherit (rustPackages) cargo;
    rustc = rustPackages.rust;
  };
  inherit (import gitignoreNix { inherit (pkgs) lib; }) gitignoreSource;
in rustPlatform.buildRustPackage {
  name = "capsule";
  srcs = gitignoreSource ./.;
  nativeBuildInputs = [ pkgs.pkgconfig pkgs.llvmPackages.libclang pkgs.clang ];
  buildInputs = [ rustPackages.rust-std pkgs.openssl pkgs.libudev pkgs.zlib ];
  verifyCargoDeps = true;

  # NOTE(skylar): For some reason rustc wasn't seeing the zlib libraries it required.
  # so as part of the preconfigure step we make that visible via LD_LIBRARY_PATH
  # TODO(skylar): Should this be in the preBuild? Can we just set envvars using the set?
  preBuild = ''
   export LD_LIBRARY_PATH="${pkgs.zlib}/lib:$LD_LIBRARY_PATH"
   export LIBCLANG_PATH="${pkgs.llvmPackages.libclang.lib}/lib"
   export BINDGEN_EXTRA_CLANG_ARGS="-isystem ${pkgs.llvmPackages.libclang.lib}/lib/clang/${pkgs.lib.getVersion pkgs.clang}/include";
  '';

  # Cargo hash must be updated when Cargo.lock file changes.
  cargoSha256 = "0j3y11bmajyn8a67m2gsrphc29ywvac6c6fwk9xf9420l5g2y4qp";
}
