{
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = github:nixos/nixpkgs/nixos-23.05;
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Dev tools
    treefmt-nix.url = "github:numtide/treefmt-nix";
    mission-control.url = "github:Platonic-Systems/mission-control";
    flake-root.url = "github:srid/flake-root";
  };


  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.mission-control.flakeModule
        inputs.flake-root.flakeModule
      ];
      perSystem = { config, self', pkgs, lib, system, ... }: {

        # Flake outputs
        packages.default = pkgs.libsForQt5.callPackage ./source/display/package.nix { };
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.flake-root.devShell
            config.treefmt.build.devShell
            config.mission-control.devShell
          ];
          #shellHook = ''
          #'';
          nativeBuildInputs = with pkgs; [
            #gnumake
            config.mission-control.wrapper
            config.treefmt.build.wrapper
          ];
          buildInputs = with pkgs; [
            libsForQt5.qt5.qtmultimedia
            libsForQt5.qt5.qtserialport
            libsForQt5.qmake
            qtcreator
          ] ++ lib.optionals stdenv.isLinux [
            libsForQt5.qt5.qtwayland
          ];
        };

        # Add your auto-formatters here.
        # cf. https://numtide.github.io/treefmt/
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
            clang-format.enable = false; # works but changes a lot of files
          };
        };

        # Makefile'esque but in Nix. Add your dev scripts here.
        # cf. https://github.com/Platonic-Systems/mission-control
        mission-control.scripts = {
          fmt = {
            exec = config.treefmt.build.wrapper;
            description = "Format the nix files";
            category = "Tools";
          };

          creator = {
            exec = ''
              qtcreator source/display/display.pro
            '';
            description = "Open qtcreator project";
          };

          run = {
            exec = self'.packages.default;
            description = "Run the project executable";
          };

          #watch = {
          #  exec = ''
          #    set -x
          #    cargo watch -x "run -- $*"
          #  '';
          #  description = "Watch for changes and run the project executable";
          #};
        };
      };
    };
}
