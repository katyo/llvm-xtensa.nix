{ stdenv, fetchurl, ncurses, flex, bison, gperf, pkgconfig, python }:
let owner = "espressif";
    repo = "ESP8266_RTOS_SDK";
    shell_nix = ./esp8266-rtos-sdk.shell.nix;
    bash_script = ./esp8266-rtos-sdk.bash;

in stdenv.mkDerivation rec {
  pname = "esp8266-rtos-sdk";
  version = "3.3";

  src = fetchurl {
    url = "https://github.com/${owner}/${repo}/archive/v${version}.tar.gz";
    sha256 = "0gvrcmvd7la56gpms4dbkvrb8qki7kqih7xma69g1m222swgj1vj";
  };

  nativeBuildInputs = [ pkgconfig ncurses flex bison gperf ];

  propagatedBuildInputs = [
    (python.withPackages (pkgs: with pkgs; [ pyparsing pyserial six ]))
  ];

  buildPhase = ''
    make -C tools/kconfig
  '';

  installPhase = ''
    mkdir -p $out
    cp -ra * $out
    install -d $out/share $out/bin
    install -m0644 ${shell_nix} $out/share/shell.nix
    install -m0755 ${bash_script} $out/bin/${pname}
  '';

  dontStrip = true;
}
