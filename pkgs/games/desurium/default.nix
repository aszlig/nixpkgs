{ stdenv, fetchgit, cmake, pkgconfig, python, subversion
, bzip2, boost, freetype, gtk, glib, tinyxml, v8
, cares, sqlite, libnotify
}:

stdenv.mkDerivation {
  name = "desurium";

  src = fetchgit {
    url = git://github.com/lodle/Desurium.git;
    rev = "70ba8fe6258f864ebff949150148882e8c6ab1f5";
    sha256 = "7a1d3dfa9745745288536a46b1b3e061941ccb3511da373d73de9fd8ad7c0935";
  };

  cmakeFlags = [
    "-DGTK2_GLIBCONFIG_INCLUDE_DIR=${glib}/lib/glib-2.0/include"
    "-DGTK2_GDKCONFIG_INCLUDE_DIR=${gtk}/lib/gtk-2.0/include"
  ];

  buildInputs = [
    pkgconfig python subversion bzip2 boost freetype
    gtk glib tinyxml v8 cares sqlite libnotify
  ];

  buildNativeInputs = [ cmake ];
}
