{ stdenv, fetchurl, autoPatchelfHook, fixDarwinDylibNames, zlib, ncurses5, python27, version ? "8.2.0" }:
with stdenv;
let mkext = platform: if platform == "win32" then "zip" else "tar.gz";
toolchains = {
  "5.2.0" = {
    mkplatform = platform: if platform == "macos" then "osx" else platform;
    mkname = platform: version: "${platform}-${version}";
    version = "1.22.0-80-g6c4433a-5.2.0";
    variants = {
      linux32 = { sha256 = "0mdi7qcb5z5kfalmzvvr84f1a0bf59bw5zfsnsyc1py2zyamc1dl"; };
      linux64 = { sha256 = "0mji8jq1dg198z8bl50i0hs3drdqa446kvf6xpjx9ha63lanrs9z"; };
      macos = { sha256 = "1npra9b0d9pqwbks3ycikzhm0xvj1plgn5gl8lkjybsxjjbplc54"; };
      win32 = { sha256 = "192qh322xb1miyis6m5ri12dwn1443bf0dlh4gdr535axb5zq5zj"; };
    };
  };
  "8.2.0" = {
    mkplatform = platform: if platform == "linux32" then "linux-i686" else if platform == "linux64" then "linux-amd64" else platform;
    mkname = platform: version: "${version}-${platform}";
    version = "gcc8_2_0-esp-2020r2";
    variants = {
      linux32 = { sha256 = "1ra09wb2awcmgiirq4b97mpgr1h55kbas2j8f0hxh3czkfycf0x0"; };
      linux64 = { sha256 = "0zhqsas2mp2v71zlg77y0g4vi7y0qsbv952yr9ihm0ajsblvjwvc"; };
      macos = { sha256 = "0xjpzq9i1wbk4dlbkml0r4nkiiagirdm9gqn2s2j61n6wpiqicj8"; };
      win32 = { sha256 = "13yv55kd8w77xf7rvbrfw04lfxdva92j0yjybsaph8ab3kdnpfpj"; };
    };
  };
};
toolchain = toolchains.${version};
platform = if hostPlatform.isDarwin then "macos" else
  if hostPlatform.isWindows then "win32" else
  if hostPlatform.isLinux then (
    if hostPlatform.isx86_64 then "linux64" else
    if hostPlatform.isx86_32 then "linux32" else ""
  ) else "";
variant = toolchain.variants.${platform};
in mkDerivation rec {
  pname = "gcc-xtensa-esp32";
  inherit version;

  src = fetchurl {
    url = "https://dl.espressif.com/dl/xtensa-esp32-elf-${toolchain.mkname (toolchain.mkplatform platform) toolchain.version}.${mkext platform}";
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
    homepage = "https://www.espressif.com/";
    license = licenses.gpl3;
    platforms = concatLists (with platforms; [ linux darwin windows ]);
  };
}
