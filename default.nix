self: super: with super; rec {
  # LLVM-based xtensa toolchain
  llvmPackages_10_xtensa = callPackage ./llvm/10 ({
    inherit (stdenvAdapters) overrideCC;
    buildLlvmTools = buildPackages.llvmPackages_10_xtensa.tools;
    targetLlvmLibraries = targetPackages.llvmPackages_10_xtensa.libraries;
  } // stdenv.lib.optionalAttrs (stdenv.hostPlatform.isi686 && buildPackages.stdenv.cc.isGNU) {
    stdenv = gcc7Stdenv;
  });
  clang_10_xtensa = llvmPackages_10_xtensa.clang;
  llvm_10_xtensa = llvmPackages_10_xtensa.llvm;

  llvmPackages_xtensa = llvmPackages_10_xtensa;
  clang_xtensa = clang_10_xtensa;
  llvm_xtensa = llvm_10_xtensa;

  # LLVM-based D-lang toolchain
  ldc_1_22_xtensa = callPackage ./ldc {
    llvm_8 = llvm_10_xtensa;
  };
  ldc_xtensa = ldc_1_22_xtensa;

  # Rust-lang compiler
  rust_1_45_xtensa = callPackage ./rust/1_45.nix {
    inherit (super.darwin.apple_sdk.frameworks) CoreFoundation Security;
  };
  rust_xtensa = rust_1_45_xtensa;

  rustPackages_1_45_xtensa = rust_1_45_xtensa.packages.stable;
  rustPackages_xtensa = rustPackages_1_45_xtensa;

  # GCC-based esp8266 toolchains
  gcc-xtensa-lx106_5_2_0 = callPackage ./espressif/gcc-xtensa-lx106.nix {};
  gcc-xtensa-lx106_5 = gcc-xtensa-lx106_5_2_0;
  gcc-xtensa-lx106 = gcc-xtensa-lx106_5;

  gcc-xtensa-lx106_4_8_5 = gcc-xtensa-lx106.override { version = "4.8.5"; };
  gcc-xtensa-lx106_4 = gcc-xtensa-lx106_4_8_5;
  gcc-xtensa-lx106_legacy = gcc-xtensa-lx106_4;

  gcc-xtensa-lx106_10_1_0 = callPackage ./esp-quick-toolchain/gcc-xtensa-lx106.nix {};
  gcc-xtensa-lx106_10 = gcc-xtensa-lx106_10_1_0;
  gcc-xtensa-lx106_latest = gcc-xtensa-lx106_10;

  # GCC-based esp32 toolchains
  gcc-xtensa-esp32_8_2_0 = callPackage ./espressif/gcc-xtensa-esp32.nix {};
  gcc-xtensa-esp32_8 = gcc-xtensa-esp32_8_2_0;
  gcc-xtensa-esp32 = gcc-xtensa-esp32_8;

  gcc-xtensa-esp32_5_2_0 = gcc-xtensa-esp32.override { version = "5.2.0"; };
  gcc-xtensa-esp32_5 = gcc-xtensa-esp32_5_2_0;
  gcc-xtensa-esp32_legacy = gcc-xtensa-esp32_5;

  # esp8266 rtos sdk
  esp8266-rtos-sdk = callPackage ./espressif/esp8266-rtos-sdk.nix {};
}
