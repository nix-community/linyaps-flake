{ lib, stdenv, fetchurl, autoreconfHook, pkg-config, fuse, util-linux, lz4, libselinux
}:

stdenv.mkDerivation rec {
  pname = "erofs-utils";
  version = "1.6";
  outputs = [ "out" "man" ];

  src = fetchurl {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/xiang/erofs-utils.git/snapshot/erofs-utils-${version}.tar.gz";
    sha256 = "sha256-2/Gtrv8buFMrKacsip4ZGTjJOJlGdw3HY9PFnm8yBXE=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ util-linux lz4 libselinux fuse ];

  configureFlags = [
    "--enable-fuse" "--with-uuid" "--with-selinux"
  ];

  postInstall = ''
    find . -name "*.la" -delete
    cp -r include $out/
    install -D lib/.libs/liberofs.a $out/lib/liberofs.a
    install -D fuse/erofsfuse $out/lib/liberofsfuse.a
  '';

  meta = with lib; {
    description = "Userspace utilities for linux-erofs file system";
    license = with licenses; [ gpl2Plus ];
    maintainers = with maintainers; [ ehmry nikstur ];
    platforms = platforms.unix;
  };
}

