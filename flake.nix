{
  description = "cli wallpaper manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        haskellPackages = pkgs.haskellPackages; 

        hakyllProject = haskellPackages.callCabal2nix "background-set" ./. {};

      in {
        packages.default = hakyllProject;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ hakyllProject.env ];
          
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
