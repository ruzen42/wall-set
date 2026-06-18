{ mkDerivation, base, directory, filepath, lib, optparse-applicative, process, random }:
mkDerivation {
  pname = "wall-set";
  version = "1.0.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base directory filepath  optparse-applicative 
    process random
  ];
  executableHaskellDepends = [
    base directory filepath optparse-applicative 
    process random
  ];
  homepage = "https://github.com/ruzen42/wall-set#readme";
  license = lib.meta.getLicenseFromSpdxId "BSD-3-Clause";
  mainProgram = "wall-set";
}
