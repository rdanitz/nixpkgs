{ stdenv
, fetch
, cmake
, zlib
, ncurses
, swig
, which
, libedit
, libxml2
, llvm
, clang-unwrapped
, python
, version
, darwin
}:

stdenv.mkDerivation {
  name = "lldb-${version}";

  src = fetch "lldb" "0g83hbw1r4gd0z8hlph9i34xs6dlcc69vz3h2bqwkhb2qq2qzg9d";

  patchPhase = ''
    # Fix up various paths that assume llvm and clang are installed in the same place
    sed -i 's,".*ClangConfig.cmake","${clang-unwrapped}/lib/cmake/clang/ClangConfig.cmake",' \
      cmake/modules/LLDBStandalone.cmake
    sed -i 's,".*tools/clang/include","${clang-unwrapped}/include",' \
      cmake/modules/LLDBStandalone.cmake
    sed -i 's,"$.LLVM_LIBRARY_DIR.",${llvm}/lib ${clang-unwrapped}/lib,' \
      cmake/modules/LLDBStandalone.cmake
  '';

  nativeBuildInputs = [ cmake python which swig ];
  buildInputs = [ ncurses zlib libedit libxml2 llvm ]
    ++ stdenv.lib.optionals stdenv.isDarwin [ darwin.libobjc darwin.apple_sdk.libs.xpc ];

  CXXFLAGS = "-fno-rtti";
  hardeningDisable = [ "format" ];

  cmakeFlags = [
    "-DLLDB_DISABLE_LIBEDIT=ON"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A next-generation high-performance debugger";
    homepage    = http://llvm.org/;
    license     = licenses.ncsa;
    platforms   = platforms.allBut platforms.darwin;
  };
}
