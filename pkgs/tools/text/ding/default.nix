{ stdenv, fetchurl, tk }:

stdenv.mkDerivation rec {
  name = "ding-${version}";
  version = "1.7";

  patchPhase = ''
    sed -i 's@/bin/\(mv\|cp\)@\1@' install.sh
  '';

  installPhase = ''
    mkdir -pv $out/bin $out/lib
    ./install.sh <<-PATHS
    $out/bin
    $out/lib
    PATHS
  '';

  buildInputs = [ tk ];

  src = fetchurl {
    url = "ftp://ftp.tu-chemnitz.de/pub/Local/urz/ding/ding-${version}.tar.gz";
    sha256 = "a6546e1074f954c67ff7697b777c42a08528177adfa08700b827c8323eb1eb91";
  };

  meta = {
    description = "A graphical dictionary lookup program";
  };
}
