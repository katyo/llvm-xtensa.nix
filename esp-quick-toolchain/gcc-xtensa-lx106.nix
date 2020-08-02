{ stdenv, fetchurl, autoPatchelfHook, fixDarwinDylibNames, zlib, ncurses5, python27, version ? "10.1.0" }:
with stdenv;
let toolchains = {
  "10.1.0" = {
    #https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.0.0-gnu12/arm-linux-gnueabihf.xtensa-lx106-elf-0474ae9.200706.tar.gz
    #https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.0.0-gnu12/aarch64-linux-gnu.xtensa-lx106-elf-0474ae9.200706.tar.gz
    #https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.0.0-gnu12/i686-linux-gnu.xtensa-lx106-elf-0474ae9.200706.tar.gz
    #https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.0.0-gnu12/x86_64-linux-gnu.xtensa-lx106-elf-0474ae9.200706.tar.gz
    #https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.0.0-gnu12/x86_64-apple-darwin14.xtensa-lx106-elf-0474ae9.200706.tar.gz
    #https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.0.0-gnu12/i686-w64-mingw32.xtensa-lx106-elf-0474ae9.200706.zip
    #https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.0.0-gnu12/x86_64-w64-mingw32.xtensa-lx106-elf-0474ae9.200706.zip
    version = "3.0.0-gnu12";
    tag = "0474ae9.200706";
    mkplatform = platform: platform;
    variants = {
      "arm-linux-gnueabihf" = { sha256 = "1ndkx6amd4n20lzm2974f7rpbwymwwjsjin7av3jwfxfj3jif324"; };
      "aarch64-linux-gnu" = { sha256 = "142qp8x6rqkyi1hkqrp4nln2vs34j2g8vnkqla8klbx8f05b0awl"; };
      "i686-linux-gnu" = { sha256 = "09x6bl2h2bpax1g1rd5vl3r1w3x500fx7vs3c7nnr60dpijsv3zs"; };
      "x86_64-linux-gnu" = { sha256 = "1s2qjfhvq7pawwmqs9yyw71fqklibsviqqynjz1h99mmx71s5srz"; };
      "x86_64-apple-darwin14" = { sha256 = "0d92csy45fxf66153dl014pvx5dv7hv3sa56cplgy9zxph6n241a"; };
      "i686-w64-mingw32" = { sha256 = "1pxb7ld20cr7i0mhkz2xh5phgwjqxaravscl21jcxfv4z3y3wiz2"; };
      "x86_64-w64-mingw32" = { sha256 = "0j0k41jp5s1v7i4rl3hy7jm2rmh7chq9k9vgbjnn54wn6slbl76c"; };
    };
  };
};
platform = with hostPlatform; (if isLinux then (
  if isAarch32 then "arm-linux-gnueabihf" else
  if isAarch64 then "aarch64-linux-gnu" else
  if isi686 then "i686-linux-gnu" else
  if isx86_64 then "x86_64-linux-gnu" else ""
) else if isDarwin then (
  if isx86_64 then "x86_64-apple-darwin14" else ""
) else if isWindows then (
  if isi686 then "i686-w64-mingw32" else
  if isx86_64 then "x86_64-w64-mingw32" else ""
) else "");
toolchain = toolchains.${version};
variant = toolchain.variants.${platform};
in mkDerivation rec {
  pname = "gcc-xtensa-lx106";
  version = toolchain.version;

  src = fetchurl {
    url = "https://github.com/earlephilhower/esp-quick-toolchain/releases/download/${toolchain.version}/${platform}.xtensa-lx106-elf-${toolchain.tag}.tar.gz";
    sha256 = variant.sha256;
  };

  nativeBuildInputs = [ autoPatchelfHook python27 ] ++ lib.optionals hostPlatform.isDarwin [ fixDarwinDylibNames ];

  propagatedBuildInputs = lib.optionals hostPlatform.isLinux [ stdenv.cc.cc zlib ncurses5 ];

  installPhase = ''
    mkdir -p $out
    cp -ra * $out
  '';

  dontStrip = true;

  meta = with lib; {
    inherit version;
    homepage = "https://github.com/earlephilhower/esp-quick-toolchain/";
    license = licenses.gpl3;
    platforms = concatLists (with platforms; [ linux darwin windows ]);
  };
}
