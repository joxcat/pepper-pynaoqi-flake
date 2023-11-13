{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachSystem [ utils.lib.system.x86_64-linux ] (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      stdenv = pkgs.stdenv;
      lib = pkgs.lib;

      naoqiOsVersion = "2.5.10";
      naoqiVersion = "2.5.7.1";
      naoqi-py = pkgs.python2Packages.buildPythonPackage {
        pname = "naoqi";
        format = "other";
        version = naoqiOsVersion;
        doCheck = false;
        src = pkgs.fetchurl {
          url = "https://community-static.aldebaran.com/resources/${naoqiOsVersion}/Python%20SDK/pynaoqi-python2.7-${naoqiVersion}-linux64.tar.gz";
          sha256 = "sha256-0gYK1p+HSB8N2oLt5scMO2WvpvG/BuLBB8Ljc9JtksI=";
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [ stdenv.cc.cc.lib pkgs.zlib pkgs.bzip2 ];
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          mv {bin,lib,share} $out
          chmod +x $out/lib/*.so
          runHook postInstall
        '';
      };
    in {
      packages = rec {
        naoqi = naoqi-py;
        default = naoqi;
      };
      devShells = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ python2 naoqi-py ];
          shellHook = ''
            export PYTHONPATH="${naoqi-py}/lib/python2.7/site-packages:$PYTHONPATH"
          '';
        };
      };
    });
}
