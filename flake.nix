# ~/nixos-config/flake.nix
{
  description = "Ma configuration NixOS avec Hyprland";

  inputs = {
    # Nixpkgs (la collection de paquets Nix) - utilisez la branche qui vous convient
    # nixos-unstable est souvent utilisée pour avoir les dernières versions pour Hyprland
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager pour gérer l'environnement utilisateur
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # S'assure que home-manager utilise le même nixpkgs
    };

    # Utilitaires pour les Flakes (optionnel mais pratique)
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs:
    let
      system = "x86_64-linux"; # Votre architecture système
      # Remplacez "your_username" par votre nom d'utilisateur réel
      username = "warguss";
    in
    {
      # Configuration NixOS
      nixosConfigurations = {
        # Vous pouvez nommer votre machine comme vous le souhaitez ici (ex: "laptop")
        # Ce nom sera utilisé pour construire : nixos-rebuild switch --flake .#laptop
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username; }; # Passer les inputs et username à configuration.nix et home.nix
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true; # Permet à Home Manager d'utiliser les paquets de nixpkgs système
              home-manager.useUserPackages = true; # Permet à l'utilisateur d'installer des paquets via Home Manager
              home-manager.extraSpecialArgs = { inherit inputs username; }; # Passer aussi à la configuration Home Manager
              home-manager.users.${username} = import ./home.nix;
            }
          ];
        };
      };
    };
}
