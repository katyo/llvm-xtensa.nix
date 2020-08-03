{ rustcVersion
, rustcSha256
, enableRustcDev ? true
, bootstrapVersion
, bootstrapHashes
, selectRustPackage
, rustcPatches ? []
}:
{ stdenv, lib
, buildPackages
, newScope, callPackage
, CoreFoundation, Security
, llvmPackages_5
, pkgsBuildTarget, pkgsBuildBuild
}:
let PACKAGING_PATH = buildPackages.path + /pkgs/development/compilers/rust;
    BUILD_SUPPORT_PATH = buildPackages.path + /pkgs/build-support/rust;
in rec {
  toRustTarget = platform: with platform.parsed; let
    cpu_ = {
      "armv7a" = "armv7";
      "armv7l" = "armv7";
      "armv6l" = "arm";
    }.${cpu.name} or platform.rustc.arch or cpu.name;
  in platform.rustc.config
    or "${cpu_}-${vendor.name}-${kernel.name}${lib.optionalString (abi.name != "unknown") "-${abi.name}"}";

  makeRustPlatform = { rustc, cargo, ... }: rec {
    rust = {
      inherit rustc cargo;
    };

    fetchcargo = buildPackages.callPackage (BUILD_SUPPORT_PATH + /fetchcargo.nix) {
      inherit cargo;
    };

    buildRustPackage = callPackage BUILD_SUPPORT_PATH {
      inherit rustc cargo fetchcargo;
    };

    rustcSrc = callPackage (PACKAGING_PATH + /rust-src.nix) {
      inherit rustc;
    };
  };

  # This just contains tools for now. But it would conceivably contain
  # libraries too, say if we picked some default/recommended versions from
  # `cratesIO` to build by Hydra and/or try to prefer/bias in Cargo.lock for
  # all vendored Carnix-generated nix.
  #
  # In the end game, rustc, the rust standard library (`core`, `std`, etc.),
  # and cargo would themselves be built with `buildRustCreate` like
  # everything else. Tools and `build.rs` and procedural macro dependencies
  # would be taken from `buildRustPackages` (and `bootstrapRustPackages` for
  # anything provided prebuilt or their build-time dependencies to break
  # cycles / purify builds). In this way, nixpkgs would be in control of all
  # bootstrapping.
  packages = {
    prebuilt = callPackage (PACKAGING_PATH + /bootstrap.nix) {
      version = bootstrapVersion;
      hashes = bootstrapHashes;
    };
    stable = lib.makeScope newScope (self: let
      # Like `buildRustPackages`, but may also contain prebuilt binaries to
      # break cycle. Just like `bootstrapTools` for nixpkgs as a whole,
      # nothing in the final package set should refer to this.
      bootstrapRustPackages = self.buildRustPackages.overrideScope' (_: _:
        lib.optionalAttrs (stdenv.buildPlatform == stdenv.hostPlatform)
          (selectRustPackage buildPackages).packages.prebuilt);
      bootRustPlatform = makeRustPlatform bootstrapRustPackages;
    in {
      # Packages suitable for build-time, e.g. `build.rs`-type stuff.
      buildRustPackages = (selectRustPackage buildPackages).packages.stable;
      # Analogous to stdenv
      rustPlatform = makeRustPlatform self.buildRustPackages;
      rustc = self.callPackage ./rustc.nix ({
        version = rustcVersion;
        sha256 = rustcSha256;
        inherit enableRustcDev;

        patches = rustcPatches;

        # Use boot package set to break cycle
        rustPlatform = bootRustPlatform;
      } // lib.optionalAttrs (stdenv.cc.isClang && stdenv.hostPlatform == stdenv.buildPlatform) {
        stdenv = llvmPackages_5.stdenv;
        pkgsBuildBuild = pkgsBuildBuild // { targetPackages.stdenv = llvmPackages_5.stdenv; };
        pkgsBuildHost = pkgsBuildBuild // { targetPackages.stdenv = llvmPackages_5.stdenv; };
        pkgsBuildTarget = pkgsBuildTarget // { targetPackages.stdenv = llvmPackages_5.stdenv; };
      });
      rustfmt = self.callPackage (PACKAGING_PATH + /rustfmt.nix) { inherit Security; };
      cargo = self.callPackage (PACKAGING_PATH + /cargo.nix) {
        # Use boot package set to break cycle
        rustPlatform = bootRustPlatform;
        inherit CoreFoundation Security;
      };
      clippy = self.callPackage (PACKAGING_PATH + /clippy.nix) { inherit Security; };
      rls = self.callPackage (PACKAGING_PATH + /rls) { inherit CoreFoundation Security; };
    });
  };
}
