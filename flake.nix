{
  description = "cli wallpaper manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        haskellPackages = pkgs.haskellPackages; 

        proj = haskellPackages.callPackage ./default.nix {};      

      in {
        packages.default = proj;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ proj.env ];
          
          buildInputs = with haskellPackages; [
            cabal-install
            stack
          ] ++ (with pkgs; [
            zlib
          ]);

        };
      }
    );
}
