{ stdenv, fetchgit, cmake, pkgconfig, python, subversion
, bzip2, boost, freetype, gtk, glib, tinyxml, v8
, cares, sqlite, libnotify
}:

stdenv.mkDerivation {
  name = "desurium";

  src = fetchgit {
    url = git://github.com/lodle/Desurium.git;
    rev = "2918d09ad47b6ddf28a4902da0df428ca429385c";
    sha256 = "95066b7e420f080c7fa784a82534841f380d2340dd7e12e155a58ccc63a321b9";
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
