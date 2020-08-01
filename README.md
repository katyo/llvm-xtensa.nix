# LLVM with Xtensa for NixOS

This is an overlay for NixOS which adds LLVM toolchain with experimental Xtensa target support.

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
