{ stdenv, fetchurl, libX11 }:

stdenv.mkDerivation rec {
  name = "steam-${version}";
  version = "1.0.0.17beta";

  src = fetchurl {
    url = "http://repo.steampowered.com/steam/pool/steam/s/steam/"
        + "steam_1.0.0.17_i386.deb";
    sha256 = "1mknhr9xgaqfqp7p449w974ias8g69yzgjh3z4zyzci6ccfb8dp1";
  };

  unpackCmd = ''
    ar p "$curSrc" data.tar.gz | \
      tar xz ./usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz -O | \
      tar xJ ubuntu12_32
  '';

  dontStrip = true;

  buildPhase = let
    rpath = stdenv.lib.makeLibraryPath [ stdenv.gcc.gcc libX11 ];
  in ''
    patchelf \
      --interpreter "$(cat $NIX_GCC/nix-support/dynamic-linker)" \
      --set-rpath "${rpath}" \
      steam
  '';

  installPhase = ''
    install -vD steam "$out/bin/steam"
  '';
}
