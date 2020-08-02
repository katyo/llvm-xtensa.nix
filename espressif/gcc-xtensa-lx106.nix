{ stdenv, fetchurl, autoPatchelfHook, fixDarwinDylibNames, zlib, ncurses5, python27, version ? "5.2.0" }:
with stdenv;
let toolchains = {
  "4.8.5" = {
    version = "1.22.0-88-gde0bdc1-4.8.5";
    mkplatform = platform: if platform == "macos" then "osx" else platform;
    variants = {
      linux32 = { sha256 = "031iidf8j7qbkilj9sldjdv44lgycladf3498rnabgrw1jm7pdy0"; };
      linux64 = { sha256 = "0ylsh9xx3cypybr1066p7d93i1ki0vvncb5vhcdvcjb35vl6lj08"; };
      macos = { sha256 = "0s2g9g8s3zgvzz4rl6qfdk9h63yiavaaxj9x593q4ivkp0vh52ha"; };
      win32 = { sha256 = "0cqwbx4rf8f2dkc8ar4m23ncdw07xi7l5hzibkv3q0n4lfvndcc3"; };
    };
  };
  "5.2.0" = {
    version = "1.22.0-100-ge567ec7-5.2.0";
    mkplatform = platform: platform;
    variants = {
      linux32 = { sha256 = "0s9770pk8wiyabbcivh8nyma0c46dgagk9ij3zq658vki9wgjkd9"; };
      linux64 = { sha256 = "1574p170cpd46pz5mpi22jsfqrj5bd7xys1gj5fzihjr6y2h4skh"; };
      macos = { sha256 = "1141n6x7bhgq85i10sba9dz0gck32wc0mnbh9gfg8zxbm1mjwfsf"; };
      win32 = { sha256 = "08qswgg3j34psafa7by36q515d2ywhk5iry8g3d47wzq08lk0l39"; };
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
  pname = "gcc-xtensa-lx106";
  version = toolchain.version;

  src = fetchurl {
    url = "https://dl.espressif.com/dl/xtensa-lx106-elf-${toolchain.mkplatform platform}-${version}.tar.gz";
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
