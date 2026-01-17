{
  inputs.nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        tl = pkgs.texlive.combine {
          inherit
            (pkgs.texlive)
            scheme-minimal
            latex-bin
            dvisvgm
            latexmk
            ;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.ruby_3_4
            tl
          ];
          shellHook = ''
            export BUNDLE_PATH="$PWD/vendor/bundle"
            export GEM_HOME="$PWD/vendor/bundle"
            export GEM_PATH="$GEM_HOME:$GEM_PATH"
          '';
        };
      }
    );
}
