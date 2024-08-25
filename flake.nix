{
  description = "void.vote Remix application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    foundry.url = "github:shazow/foundry.nix/monthly"; # Use monthly branch for permanent releases
  };

  outputs = { self, nixpkgs, flake-utils, foundry }:
    flake-utils.lib.eachDefaultSystem (system:
      let
	 pkgs = import nixpkgs {
          inherit system;
          overlays = [ foundry.overlay ];
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            nodePackages.npm
            nodePackages.yarn
            foundry-bin
	    solc
          ];

          shellHook = ''
	  # it is necessary to install 
            export PATH="$PWD/node_modules/.bin:$PATH"
          '';
        };
      });
}
