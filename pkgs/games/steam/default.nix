{ stdenv, fetchurl, unzip, makeWrapper, libX11
, zlib, pango, glib, mesa
, libXrandr, libXext, libXfixes, libXi, libXrender
, cups, cairo, freetype, fontconfig, openal, nss, gtk2, gdk_pixbuf
, alsaLib, pulseaudio, nspr, dbus, libpng12, libgcrypt
}:

with stdenv.lib;

let
  fetchSteam = pkg: sha1: fetchurl {
    inherit sha1;
    url = "http://media.steampowered.com/client/${pkg}.zip.${sha1}";
  };

  steamPackages = [
    (fetchSteam "bins_ubuntu12"   "c5b2136df4191824b6a4239193aaa49f75294d68")
    (fetchSteam "webkit_ubuntu12" "2afa14b88266fbb01846ce0eeded8a0c67767b37")
    (fetchSteam "sdl2_ubuntu12"   "ef2498ac145cf54eede07acdb74473afd39f170f")
  ];

in stdenv.mkDerivation rec {
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

  postUnpack = flip map steamPackages (pkg: ''
    unzip "${pkg}" 'ubuntu12_32/*'
  '');

  dontStrip = true;

  buildPhase = let
    rpath = makeLibraryPath [
      stdenv.gcc.gcc libX11 zlib pango glib mesa
      libXrandr libXext libXfixes libXi libXrender
      cups cairo freetype fontconfig openal nss gtk2 gdk_pixbuf
      alsaLib pulseaudio nspr dbus libpng12 libgcrypt
    ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_GCC/nix-support/dynamic-linker)" \
      --set-rpath "${rpath}" \
      steam

    for libfile in *.so*; do
      patchelf --set-rpath "${rpath}" "$libfile"
      LD_LIBRARY_PATH="$LD_LIBRARY_PATH:." ldd "$libfile"
    done
  '';

  installPhase = ''
    libexec="$out/libexec/steam"
    install -vt "$libexec/bin" steam
    cp -vr -t "$libexec" *.so*

    makeWrapper "$libexec/bin/steam" "$out/bin/steam" \
      --set LD_LIBRARY_PATH "$libexec"
  '';
}
