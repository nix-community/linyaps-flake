{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, libselinux
, erofs-utils
, zlib
, zstd
, fuse
, lz4
, pcre2
, xz
, lzo
, glibc
, linux_6_1
}:

stdenv.mkDerivation rec {
  pname = "linglong-loader";
  version = "1.3.3.10-1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "linglong-loader";
    rev = version;
    hash = "sha256-68UxgdPTTdeGeck/WbThh7PBSYbqnHiMIaAThzp5F+w=";
  };

  patches = [
    ./patch/fix-build-loader.diff
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libselinux
    erofs-utils
    zlib
    zstd
    #(zlib.override { shared = false; static = true; })
    #(zstd.override { static = true; })
    fuse
    lz4
    pcre2
    xz
    lzo
    #glibc.static
    #linux_6_1
  ];

  env.NIX_CFLAGS_COMPILE = "-L${erofs-utils}/bin";

  meta = with lib; {
    description = "Linglong Loader";
    homepage = "https://github.com/linuxdeepin/linglong-loader";
    license = with licenses; [ lgpl3Plus ];
    maintainers = with maintainers; [ rewine ];
  };
}
