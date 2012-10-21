{ stdenv
, fetchurl
, autoconf
, automake
, libtool
, xorgserver, xproto, fontsproto, xf86driproto, renderproto, videoproto, pixman
, utilmacros
, libdrm
, pkgconfig }:

stdenv.mkDerivation rec {
  name = "xf86-video-nouveau-${version}";
  version = "1.0.2";

  src = fetchurl {
    url = "http://nouveau.freedesktop.org/release/${name}.tar.bz2";
    sha256 = "0pf4rg62cbm4y49rir17yxcb2w5g326i4yjic11lshqxm7132mvn";
  };

  buildInputs = [
    autoconf
    automake
    libtool
    xorgserver xproto fontsproto xf86driproto renderproto videoproto pixman
    utilmacros
    libdrm
    pkgconfig
  ];

  NIX_CFLAGS_COMPILE = "-I${pixman}/include/pixman-1";

  preConfigure = "autoreconf -vfi";

  meta = {
    homepage = http://nouveau.freedesktop.org/wiki/;

    description = "The xorg driver for nouveau-driven video cards";

    license = "gplv2";

    maintainers = [ stdenv.lib.maintainers.shlevy ];
  };
}
