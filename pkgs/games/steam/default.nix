{ stdenv, fetchurl, unzip, makeWrapper, libX11, writeText
, zlib, pango, glib, mesa
, libXrandr, libXext, libXfixes, libXi, libXrender, libXinerama
, cups, cairo, freetype, fontconfig, openal, nss, gtk2, gdk_pixbuf
, alsaLib, pulseaudio, nspr, dbus, libpng12, libgcrypt
}:

with stdenv.lib;

let
  fetchSteam = pkg: sha1: (fetchurl {
    inherit sha1;
    name = "${pkg}.zip";
    url = "http://media.steampowered.com/client/${pkg}.zip.${sha1}";
  }) // {
    inherit pkg sha1;
  };

  version = "1355250651";

  srcs = [
    (fetchSteam "strings_all"
                "9de2aafbac6a2b87810a2ba34d2535e39815131c")
    (fetchSteam "resources_all"
                "363599fd9b416988a0e6e7dfb466fdb5111ab7c3")
    (fetchSteam "tenfoot_all"
                "decc1a5ea469abd3af5d2bbd6d63e22065e303a1")
    (fetchSteam "tenfoot_fonts_all"
                "a155ceac3231ac6e40345fd45c6c7c8213920018")
    (fetchSteam "tenfoot_ambientsounds_all"
                "ac31503c42f094976f64844d8ff54705cadc7dd3")
    (fetchSteam "tenfoot_sounds_all"
                "e8cce9ed600fc09e4a3f510fc3595d515bba6cd6")
    (fetchSteam "tenfoot_images_all"
                "77918e672284f4e512d805fda98452b2cdda33f1")
    (fetchSteam "public_all"
                "59f6218bb080590b710237c10c96f2fe8d431f41")
    (fetchSteam "bins_ubuntu12"
                "9a078431a78d549867dbe4574207f908042ad9d5")
    (fetchSteam "webkit_ubuntu12"
                "2afa14b88266fbb01846ce0eeded8a0c67767b37")
    (fetchSteam "miles_ubuntu12"
                "9c547c676be26625a4cd64c2595821d10b8fc9ff")
    (fetchSteam "sdl2_ubuntu12"
                "ef2498ac145cf54eede07acdb74473afd39f170f")
    (fetchSteam "steam_ubuntu12"
                "c84c824580aa0912ea56805ea5af97db2a21239a")
  ];

  mkFakePackageItem = src: ''
    "${src.pkg}"
    {
      "file" "${src}"
      "checksum" "${src.sha1}"
      "size" "$(stat -c '%s' "${src}")"
    }
  '';

  fakePackageBuilder = writeText "steampkg.sh" ''
    cat <<STEAMPKG
    "ubuntu12"
    {
      "version" "${version}"
      ${concatMapStrings mkFakePackageItem srcs}
    }
    STEAMPKG
  '';

  preloader = stdenv.mkDerivation {
    name = "steam-preloader.so";
    buildCommand = ''
      gcc -O3 -std=c99 -finline-functions -Wall -Werror -pedantic \
        -pthread "${./preload.c}" -fPIC -shared -o "$out" -ldl
    '';
  };

in stdenv.mkDerivation {
  name = "steam-${version}";
  inherit version srcs;

  buildInputs = [ unzip makeWrapper ];

  unpackPhase = ''
    sourceRoot="steam-${version}"
    for archive in $srcs; do
      unzip -qqu "$archive" -d "$sourceRoot"
    done
    chmod -R u+w "$sourceRoot"
  '';

  dontStrip = true;

  buildPhase = let
    rpath = makeLibraryPath [
      stdenv.gcc.gcc libX11 zlib pango glib mesa
      libXrandr libXext libXfixes libXi libXrender libXinerama
      cups cairo freetype fontconfig openal nss gtk2 gdk_pixbuf
      alsaLib pulseaudio nspr dbus libpng12 libgcrypt
    ];
  in ''
    libexec="$out/libexec/steam"

    find ubuntu12_32 -type f -exec chmod +x '{}' +

    for binfile in steam gameoverlayui; do
      patchelf \
        --set-interpreter "$(cat $NIX_GCC/nix-support/dynamic-linker)" \
        --set-rpath "$libexec/ubuntu12_32:${rpath}" \
        "ubuntu12_32/$binfile"
    done

    for libfile in ubuntu12_32/*.so*; do
      patchelf --set-rpath "$libexec/ubuntu12_32:${rpath}" "$libfile"
    done
  '';

  installPhase = ''
    mkdir -vp "$libexec"
    cp -avt "$libexec" *

    installed_data="$(find "$libexec"    \
         \( -type f -printf '%p,%s\n' \) \
      -o \( -type d -printf '%p,-1\n' \)
    )"

    mkdir -vp "$libexec/package"
    echo "$installed_data" > "$libexec/package/steam_client_ubuntu12.installed"
    sh "${fakePackageBuilder}" > "$libexec/package/steam_client_ubuntu12"

    makeWrapper "$libexec/ubuntu12_32/steam" "$out/bin/steam" \
      --set LD_LIBRARY_PATH "$libexec/ubuntu12_32" \
      --set NIX_STEAM_ALLOWED_PATHS "$libexec:\$HOME/Steam" \
      --set LD_PRELOAD "${preloader}"
  '';
}
