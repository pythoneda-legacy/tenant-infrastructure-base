{
  description = "Infrastructure layer for pythoneda-tenant/base";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-base = {
      url = "github:pythoneda/base/0.0.1a14";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-tenant-base = {
      url = "github:pythoneda-tenant/base/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-infrastructure-base = {
      url = "github:pythoneda-infrastructure/base/0.0.1a10";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        description = "Infrastructure layer for pythoneda-tenant/base";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-tenant-infrastructure/base";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/devShells.nix;
        pythoneda-tenant-infrastructure-base-for = { version, pythoneda-base
          , pythoneda-tenant-base, pythoneda-infrastructure-base, python }:
          let
            pname = "pythoneda-tenant-infrastructure-base";
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-base
              pythoneda-tenant-base
              pythoneda-infrastructure-base
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ "pythonedatenantinfrastructure" ];

            preBuild = ''
              python -m venv .env
              source .env/bin/activate
              pip install ${pythoneda-base}/dist/pythoneda_base-${pythoneda-base.version}-py3-none-any.whl
              pip install ${pythoneda-tenant-base}/dist/pythoneda_tenant_base-${pythoneda-tenant-base.version}-py3-none-any.whl
              pip install ${pythoneda-infrastructure-base}/dist/pythoneda_infrastructure_base-${pythoneda-infrastructure-base.version}-py3-none-any.whl
              rm -rf .env
            '';

            postInstall = ''
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description license homepage maintainers;
            };
          };
        pythoneda-tenant-infrastructure-base-0_0_1a1-for = { pythoneda-base
          , pythoneda-tenant-base, pythoneda-infrastructure-base, python }:
          pythoneda-tenant-infrastructure-base-for {
            version = "0.0.1a1";
            inherit pythoneda-base pythoneda-tenant-base
              pythoneda-infrastructure-base python;
          };
      in rec {
        packages = rec {
          pythoneda-tenant-infrastructure-base-0_0_1a1-python38 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              pythoneda-tenant-base =
                pythoneda-tenant-base.packages.${system}.pythoneda-tenant-base-latest-python38;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python38;
              python = pkgs.python38;
            };
          pythoneda-tenant-infrastructure-base-0_0_1a1-python39 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              pythoneda-tenant-base =
                pythoneda-tenant-base.packages.${system}.pythoneda-tenant-base-latest-python39;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python39;
              python = pkgs.python39;
            };
          pythoneda-tenant-infrastructure-base-0_0_1a1-python310 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              pythoneda-tenant-base =
                pythoneda-tenant-base.packages.${system}.pythoneda-tenant-base-latest-python310;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python310;
              python = pkgs.python310;
            };
          pythoneda-tenant-infrastructure-base-latest-python38 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-python38;
          pythoneda-tenant-infrastructure-base-latest-python39 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-python39;
          pythoneda-tenant-infrastructure-base-latest-python310 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-python310;
          pythoneda-tenant-infrastructure-base-latest =
            pythoneda-tenant-infrastructure-base-latest-python310;
          default = pythoneda-tenant-infrastructure-base-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-tenant-infrastructure-base-0_0_1a1-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-tenant-infrastructure-base-0_0_1a1-python38;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-tenant-infrastructure-base-0_0_1a1-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-tenant-infrastructure-base-0_0_1a1-python39;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-tenant-infrastructure-base-0_0_1a1-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-tenant-infrastructure-base-0_0_1a1-python310;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-tenant-infrastructure-base-latest-python38 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-python38;
          pythoneda-tenant-infrastructure-base-latest-python39 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-python39;
          pythoneda-tenant-infrastructure-base-latest-python310 =
            pythoneda-tenant-infrastructure-base-0_0_1a1-python310;
          pythoneda-tenant-infrastructure-base-latest =
            pythoneda-tenant-infrastructure-base-latest-python310;
          default = pythoneda-tenant-infrastructure-base-latest;

        };
      });
}
