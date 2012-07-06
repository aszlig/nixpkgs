{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "tinyxml-2.6.2";

  src = fetchurl {
    url = mirror://sourceforge/tinyxml/tinyxml_2_6_2.tar.gz;
    sha256 = "14smciid19lvkxqznfig77jxn5s4iq3jpb47vh5a6zcaqp7gvg8m";
  };

  objFiles = [
    "tinyxml.o"
    "tinyxmlparser.o"
    "tinyxmlerror.o"
  ];

  patchPhase = ''
    sed -i -e '/^# Makefile code common to all platforms/,/^# /s/:= */:= -fPIC /' Makefile
  '';

  postBuild = ''
    ar rc libtinyxml.a ${toString objFiles}
    ${stdenv.gcc}/bin/g++ -shared -Wl,-soname,libtinyxml.so -o libtinyxml.so ${toString objFiles}
  '';

  installPhase = ''
    mkdir -p "$out/include"
    install -vD -m 0644 -t "$out/include" tinyxml.h tinystr.h
    mkdir -p "$out/lib"
    install -vD -m 0644 -t "$out/lib" libtinyxml.a
    install -vD -m 0755 -t "$out/lib" libtinyxml.so
  '';

  meta = {
    homepage = http://sourceforge.net/projects/tinyxml/;
    license = stdenv.lib.licenses.zlib;
    description = "A simple and small C++ XML parser";
  };
}
