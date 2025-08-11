{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, cli11
, gtest
, libcap
, libseccomp
, nlohmann_json
, debug ? false
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "linyaps-box";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "OpenAtom-Linyaps";
    repo = "linyaps-box";
    rev = finalAttrs.version;
    hash = "sha256-Pdhb7dwAabDfhxmEifZblxEi9F4OUIDPx1X07f2AwPE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cli11
    gtest
    libcap
    libseccomp
    nlohmann_json
  ];

  cmakeFlags = [
    "-Dlinyaps-box_ENABLE_SECCOMP=ON"
  ] ++ lib.optionals debug [
    "-DCMAKE_BUILD_TYPE=Debug"
    "-DCMAKE_CXX_FLAGS_DEBUG=-g -O0"
    "-DCMAKE_C_FLAGS_DEBUG=-g -O0"
  ];

  # 为 debug 版本添加额外的构建选项
  dontStrip = debug;
  separateDebugInfo = !debug;

  meta = {
    description = "Simple OCI runtime mainly used by linyaps";
    homepage = "https://github.com/OpenAtom-Linyaps/linyaps-box";
    mainProgram = "ll-box";
    platforms = lib.platforms.linux;
    license = lib.licenses.lgpl3Plus;
  };
}) 