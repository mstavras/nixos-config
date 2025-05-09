# ~/nixos-config/home.nix
{ pkgs, inputs, username, ... }: # `username` vient de specialArgs

{
  # Nécessaire pour Home Manager
  home.username = username; # Utilise le username passé en argument
  home.homeDirectory = "/home/${username}"; # Adapte le chemin du répertoire personnel

  # Paquets installés pour votre utilisateur
  home.packages = with pkgs; [
    # Terminal
    kitty
    microsoft-edge
    vscode
    gnome-text-editor
    gvfs
    uv

    # Outils pour l'écosystème Hyprland/Wayland
    waybar       # Barre d'état
    rofi-wayland # Lanceur d'applications (alternative: wofi)
    dunst        # Démon de notifications (alternative: mako)
    swaylock-effects # Pour verrouiller l'écran (avec effets, ou swaylock simple)
    swww         # Pour gérer les fonds d'écran (alternative: hyprpaper)
    grim         # Pour les captures d'écran
    slurp        # Pour sélectionner une région pour grim
    wl-clipboard # Pour copier/coller dans Wayland
    cliphist     # Historique du presse-papier pour Wayland

    # Utilitaires
    pavucontrol  # Contrôleur de volume PulseAudio (fonctionne avec PipeWire)
    # qutebrowser # Un autre navigateur pour explorer
  ];

  # Gestion des "dotfiles" et configuration des programmes
  # Home Manager va créer des liens symboliques vers ces fichiers
  # ou intégrer leur configuration directement.

  # Configuration de base pour Hyprland (liée depuis un fichier externe)
  xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;

  # Configuration pour Kitty (liée depuis un fichier externe)
  xdg.configFile."kitty/kitty.conf".source = ./kitty.conf;

  # Configuration pour Waybar
  programs.waybar = {
    enable = true;
    # Si vous préférez gérer les fichiers de configuration de Waybar manuellement via xdg.configFile :
    # package = pkgs.waybar; # Assurez-vous qu'il est installé
  };
  # Gérer les fichiers Waybar via xdg.configFile (recommandé pour Waybar)
  xdg.configFile."waybar/config".source = ./waybar-config;
  xdg.configFile."waybar/style.css".source = ./waybar-style.css;

  # Configuration pour Dunst (notifications)
  services.dunst = {
    enable = true;
    # Vous pouvez ajouter des paramètres ici ou lier un fichier de configuration :
    # settings = {
    #   global = {
    #     monitor = 0;
    #     # ... autres paramètres
    #   };
    # };
  };

  # GTK Theming (pour l'apparence des applications GTK comme Nautilus, Gedit)
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark"; # Thème sombre par défaut
      package = pkgs.adwaita-icon-theme; # S'assurer que le thème Adwaita est là
    };
    iconTheme = {
      name = "Papirus-Dark"; # Un pack d'icônes populaire
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
    # Pour forcer les applications Qt à utiliser un style GTK (peut être mitigé)
    # qt.platformTheme = "gtk";
  };

  # Variables d'environnement pour votre session utilisateur
  home.sessionVariables = {
    EDITOR = "nvim"; # Ou "code", "gedit", etc. si Neovim est votre éditeur principal
    BROWSER = "microsoft-edge"; # Ou "firefox"
    # GTK_THEME = "Adwaita-dark"; # Peut être défini ici aussi
  };

  # Activer le module Home Manager
  programs.home-manager.enable = true;

  # Version de l'état pour Home Manager (similaire à system.stateVersion)
  home.stateVersion = "24.11"; # Ou "24.05"
}
