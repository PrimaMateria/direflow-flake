{
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: 
  let out = system: 
  let 
    pkgs = nixpkgs.legacyPackages."${system}";
    npmrc = pkgs.writeText "npmrc-direflow" ''
      prefix=~/.npm-global
      init-author-name=Matus Benko
      email=matus.benko@gmail.com
    '';
  in
  {
    devShell = pkgs.mkShell {
      name = "shell.direflow.nix";
      buildInputs = with pkgs; [ 
        nodejs-16_x
        nodePackages.typescript-language-server
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
      '';
    };
  }; in with utils.lib; eachSystem defaultSystems out;
}
