{ stdenv, fetchurl, makeWrapper, libX11 }:

stdenv.mkDerivation rec {
  name = "steam-${version}";
  version = "1.0.0.17beta";

  src = fetchurl {
    url = "http://repo.steampowered.com/steam/pool/steam/s/steam/"
        + "steam_1.0.0.17_i386.deb";
    sha256 = "1mknhr9xgaqfqp7p449w974ias8g69yzgjh3z4zyzci6ccfb8dp1";
  };

  buildInputs = [ unzip makeWrapper ];

  unpackCmd = ''
    ar p "$curSrc" data.tar.gz |
      tar xz ./usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz -O |
      tar xJ ubuntu12_32/steam
  '';

  dontStrip = true;

  buildPhase = let
    rpath = stdenv.lib.makeLibraryPath [ stdenv.gcc.gcc libX11 ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_GCC/nix-support/dynamic-linker)" \
      --set-rpath "${rpath}" \
      steam
  '';

  installPhase = ''
    libexec="$out/libexec/steam"
    install -vt "$libexec/bin" steam

    makeWrapper "$libexec/bin/steam" "$out/bin/steam" \
      --set LD_LIBRARY_PATH "$libexec"
  '';
}
