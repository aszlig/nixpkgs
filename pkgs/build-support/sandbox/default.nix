{ stdenv }:

name:

stdenv.mkDerivation {
  name = "${name}-sandbox";

  buildCommand = ''
    gcc -O3 -std=c99 -Wall -Werror -pedantic \
      -pthread "${./sandbox.c}" -o "$out"
  '';
}
