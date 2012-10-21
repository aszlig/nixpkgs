{ stdenv, fetchurl, autoconf, automake, libtool, pkgconfig, mesa }:

stdenv.mkDerivation rec {
  name = "mesa-glu-${version}";
  version = "9.0.0";

  src = fetchurl {
    url = "http://cgit.freedesktop.org/mesa/glu/snapshot/glu-${version}.tar.gz";
    sha256 = "0xzxb1ifd99x3pydlj545x9js3j8zksr2a9996sz17fapf7ky4za";
  };

  preConfigure = ''
    autoreconf -vfi
  '';

  buildInputs = [ autoconf automake libtool pkgconfig mesa ];

  meta = {
    description = "Mesa OpenGL Utility library";
    homepage = "http://cgit.freedesktop.org/mesa/glu";
    license = stdenv.lib.licenses.sgi;
  };
}
