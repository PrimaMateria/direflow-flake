{
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: {
    overlay = import ./cypress-overlay.nix;
  } // utils.lib.eachDefaultSystem ( system: 
    let 
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };

      npmrc = pkgs.writeText "npmrc-direflow" ''
        prefix=~/.npm-global
        init-author-name=Matus Benko
        email=matus.benko@gmail.com
      '';
    in
    {
      devShell = pkgs.mkShell {
        name = "nix.shell.direflow";
        buildInputs = with pkgs; [ 
          nodejs-16_x
          nodePackages.typescript-language-server
          cypress
        ];
        shellHook = ''
          alias npm="npm --userconfig ${npmrc}"

          if [ ! -d "$HOME/.npm-global" ]; then 
            mkdir "$HOME/.npm-global" 
            echo "Created ~/.npm-global"

            npm install -g @fsouza/prettierd eslint_d
            echo "Installed prettierd and eslint_d"
          fi
          
          export PATH="$HOME/.npm-global/bin:$PATH"

          export CYPRESS_INSTALL_BINARY=0
          export CYPRESS_RUN_BINARY=${pkgs.cypress}/bin/Cypress

          echo "Direflow shell loaded"
        '';
      };
    }
  );
}
