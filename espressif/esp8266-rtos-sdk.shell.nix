{ pkgs ? import <nixpkgs> {}, ... }:
with pkgs;
with stdenv;
with llvmPackages_xtensa;
mkShell {
  buildInputs = [
    # GCC-based toolchain
    gcc-xtensa-lx106_latest
    # LLVM-based toolchain
    llvm clang bintools
    # Dlang toolchain
    ldc_xtensa
    # RTOS SDK
    esp8266-rtos-sdk
  ];
  # Set path to RTOS SDK
  IDF_PATH = esp8266-rtos-sdk;
  # Set python path
  PY_PATH = "${python}/bin";
  # Set prompt
  shellHook = ''
    export PS1="\n\033[1;32m[${esp8266-rtos-sdk.pname} \033[1;34mv${esp8266-rtos-sdk.version}\033[1;32m:\w]\$\033[0m ";
  '';
}
