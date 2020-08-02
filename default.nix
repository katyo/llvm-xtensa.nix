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
  ldc_xtensa = callPackage ./ldc {
    llvm_8 = llvm_10_xtensa;
  };

}
