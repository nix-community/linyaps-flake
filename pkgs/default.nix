{ lib
, stdenv
, fetchFromGitHub
, cmake
, copyDesktopItems
, pkg-config
, cli11
, curl
, gpgme
, gtest
, libarchive
, libelf
, libsodium
, libsysprof-capture
, nlohmann_json
, openssl
, ostree
, qt6
, systemd
, tl-expected
, uncrustify
, xz
, yaml-cpp
, linyaps-box
, bash
, binutils
, coreutils
, desktop-file-utils
, erofs-utils
, fuse3
, fuse-overlayfs
, gnutar
, glib
, shared-mime-info
}:

let
  erofs-utils' = erofs-utils.override {
    fuse = fuse3;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "linyaps";
  version = "1.9.8";

  src = fetchFromGitHub {
    owner = "OpenAtom-Linyaps";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-GOgjL6I33HA4BYBc/oXwXPgEk0w360eM+BSKddpwAxg=";
  };

  cmakeFlags = [
    (lib.cmakeFeature "LINGLONG_DEFAULT_OCI_RUNTIME" (lib.getExe linyaps-box))
  ];

  buildInputs = [
    cli11
    curl
    gpgme
    gtest
    libarchive
    libelf
    libsodium
    libsysprof-capture
    nlohmann_json
    openssl
    ostree
    qt6.qtbase
    systemd
    tl-expected
    uncrustify
    xz
    yaml-cpp
    stdenv.cc.libc.static
  ];

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    pkg-config
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Cross-distribution package manager with sandboxed apps and shared runtime";
    homepage = "https://linyaps.org.cn/";
    downloadPage = "https://github.com/OpenAtom-Linyaps/linyaps";
    changelog = "https://github.com/OpenAtom-Linyaps/linyaps/releases/tag/${finalAttrs.version}";
    mainProgram = "ll-cli";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
