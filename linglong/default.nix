{ lib
, stdenv
, fetchFromGitHub
, cmake
, curl
, gdk-pixbuf
, glib
, gtest
, libarchive
, libselinux
, libsepol
, libyamlcpp
, ostree
, pcre
, pkg-config
, procps
, qttools
, qtwebsockets
, runtimeShell
, util-linux
, wrapGAppsNoGuiHook
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "linyaps";
  version = "1.9.8";

  src = fetchFromGitHub {
    owner = "OpenAtom-Linyaps";
    repo = pname;
    rev = "${version}";
    hash = "sha256-GBPfEZWpEa+dbIycC/f7LTH3dQSIjjpWRRUxe+2g0ic=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapGAppsNoGuiHook
    wrapQtAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    curl
    gdk-pixbuf
    glib
    gtest
    libarchive
    libselinux
    libsepol
    libyamlcpp
    ostree
    pcre
    qtwebsockets
  ];

  postPatch = ''
    substituteInPlace misc/libexec/linglong/app-conf-generator \
                      misc/share/applications/linyaps.desktop \
        --replace "/usr/bin" "$out/bin"
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ostree procps util-linux ]}"
    "--set SHELL ${runtimeShell}"
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "The container application toolkit of deepin";
    homepage = "https://linglong.dev";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
}
