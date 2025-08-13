{
  fetchFromGitHub,
  lib,
  stdenv,
  cmake,
  copyDesktopItems,
  pkg-config,
  qt6Packages,
  linyaps-box,

  cli11,
  curl,
  gpgme,
  gtest,
  libarchive,
  libelf,
  libsodium,
  libsysprof-capture,
  nlohmann_json,
  openssl,
  ostree,
  systemdLibs,
  tl-expected,
  uncrustify,
  xz,
  yaml-cpp,

  replaceVars,
  bash,
  binutils,
  coreutils,
  desktop-file-utils,
  erofs-utils,
  fuse3,
  fuse-overlayfs,
  gnutar,
  glib,
  shared-mime-info,
  debug ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "linyaps";
  version = "1.9.8";

  src = fetchFromGitHub {
    owner = "OpenAtom-Linyaps";
    repo = finalAttrs.pname;
    tag = finalAttrs.version;
    hash = "sha256-GOgjL6I33HA4BYBc/oXwXPgEk0w360eM+BSKddpwAxg=";
  };

  patches = [
    ./fix-path.patch
    (replaceVars ./patch-binary-path.patch {
      bash = lib.getExe bash;
      cp = lib.getExe' coreutils "cp";
      sh = lib.getExe' bash "sh";
      mkfs_erofs = lib.getExe' erofs-utils "mkfs.erofs";
      erofsfuse = lib.getExe' erofs-utils "erofsfuse";
      fusermount = lib.getExe' fuse3 "fusermount3";
      tar = lib.getExe gnutar;
      objcopy = lib.getExe' binutils "objcopy";
      ar = lib.getExe' binutils "ar";
      update-desktop-database = lib.getExe' desktop-file-utils "update-desktop-database";
      update-mime-database = lib.getExe' shared-mime-info "update-mime-database";
      glib-compile-schemas = lib.getExe' glib "glib-compile-schemas";
      fuse-overlayfs = lib.getExe fuse-overlayfs;
    })
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LINGLONG_DEFAULT_OCI_RUNTIME" (lib.getExe linyaps-box))
  ] ++ lib.optionals debug [
    "-DCMAKE_BUILD_TYPE=Debug"
  ];

  # 为 debug 版本添加额外的构建选项
  dontStrip = debug;
  separateDebugInfo = !debug;

  postPatch = ''
    substituteInPlace apps/dumb-init/CMakeLists.txt \
      --replace-fail "target_link_options(\''${DUMB_INIT_TARGET} PRIVATE -static)" \
                     "target_link_options(\''${DUMB_INIT_TARGET} PRIVATE -static -L${stdenv.cc.libc.static}/lib -lc -lm)"
  '';

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
    qt6Packages.qtbase
    systemdLibs
    tl-expected
    uncrustify
    xz
    yaml-cpp
    linyaps-box
  ];

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    pkg-config
    qt6Packages.wrapQtAppsNoGuiHook
  ];

  # 禁用 Qt 包装
  dontWrapQtApps = true;

  # 手动包装需要的二进制文件，跳过 dumb-init
  postFixup = ''
    # 包装 bin/ 目录下的可执行文件
    for f in $out/bin/*; do
      if [ -f "$f" ] && [ -x "$f" ]; then
        wrapQtApp "$f"
      fi
    done

    # 包装 libexec/ 目录下的可执行文件，但跳过 dumb-init
    if [ -d "$out/libexec" ]; then
      find "$out/libexec" -type f -executable ! -name "dumb-init" -print0 | while IFS= read -r -d "" f; do
        wrapQtApp "$f"
      done
    fi
  '';

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
