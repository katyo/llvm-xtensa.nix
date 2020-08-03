# LLVM with Xtensa for NixOS

This is an overlay for NixOS which adds LLVM-based toolchains with experimental Xtensa target support.

Also GCC-based toolchains was added to support platform-specific build tools (ld, objdump and etc).

## Packages

- [x] __LLVM__ packages
  - [x] llvmPackages_xtensa (llvmPackages_10_xtensa)
  - [x] llvm_xtensa (llvmPackages_10_xtensa.llvm)
- [x] __LLVM__-based toolchains
  - [x] __Clang__
    - [x] clang_xtensa (llvmPackages_10_xtensa.clang)
  - [x] __D__
    - [x] ldc_xtensa (ldc_1_22_xtensa)
  - [x] __Rust__
    - [x] rustPackages_xtensa (rustPackages_1_45_xtensa)
    - [x] rust_xtensa (rust_1_45_xtensa)
    - [ ] rustPackages_xtensa_beta
    - [ ] rust_xtensa_beta
    - [ ] rustPackages_xtensa_nightly
    - [ ] rust_xtensa_nightly
- [x] __GCC__-based toolchains
  - [x] Espressif's
    - [x] gcc-xtensa-lx106 (gcc-xtensa-lx106_5, gcc-xtensa-lx106_5_2_0)
    - [x] gcc-xtensa-lx106_legacy (gcc-xtensa-lx106_4, gcc-xtensa-lx106_4_8_5)
    - [x] gcc-xtensa-esp32 (gcc-xtensa-esp32_8, gcc-xtensa-esp32_8_2_0)
    - [x] gcc-xtensa-esp32_legacy (gcc-xtensa-esp32_5, gcc-xtensa-esp32_5_2_0)
  - [x] ESP Quick toolchain
    - [x] gcc-xtensa-lx106_latest (gcc-xtensa-lx106_10, gcc-xtensa-lx106_10_1_0)
- [x] __SDK__
  - [ ] Espressif's
    - [x] esp8266-rtos-sdk (v3.3)
    - [ ] esp-idf

## Usage

Install overlay

```
$ mkdir -p ~/.config/nixpkgs/overlays
$ git clone https://github.com/katyo/llvm-xtensa.nix ~/.config/nixpkgs/overlays/llvm-xtensa
```

Start shell with clang

```
$ nix-shell -p clang_xtensa -p llvm_xtensa
$ llvm-config --targets-built
AArch64 AMDGPU ARM BPF Hexagon Lanai Mips MSP430 NVPTX PowerPC RISCV Sparc SystemZ WebAssembly X86 XCore Xtensa

$ clang -target xtensa-esp8266-none-eabi --print-supported-cpus
clang version 10.0.1
Target: xtensa-esp8266-none-eabi
Thread model: posix
Available CPUs for this target:

	esp32
	esp32-s2
	esp8266
	generic
```
