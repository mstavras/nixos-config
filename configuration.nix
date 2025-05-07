# ~/nixos-config/configuration.nix
{ config, pkgs, inputs, username, ... }: # `username` vient de specialArgs dans flake.nix

{
  imports = [
    # Incluez le fichier hardware-configuration.nix généré lors de l'installation de NixOS
    # Assurez-vous que ce fichier existe ou commentez cette ligne pour le premier build
    # et décommentez-la après la première installation réussie où il est généré.
    # /etc/nixos/hardware-configuration.nix
    # Si vous l'avez copié dans votre dossier de configuration :
    ./hardware-configuration.nix
  ];

  # Bootloader (GRUB)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda"; # Ou /dev/nvme0n1, etc. Adaptez à votre disque

  # Réseau
  networking.networkmanager.enable = true; # Pour gérer Wi-Fi et connexions filaires
  # Pour les noms d'hôtes et autres paramètres réseau, vous pouvez ajouter :
  # networking.hostName = "nixos"; # Définissez votre nom d'hôte

  # Fuseaux horaires et locale
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Configurer les utilisateurs
  users.users.${username} = {
    isNormalUser = true;
    description = "warguss"; # Remplacez par votre nom
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "adbusers" ]; # wheel pour sudo
    shell = pkgs.bash; # Ou pkgs.bash
  };
  # Autoriser les membres du groupe wheel à utiliser sudo
  security.sudo.wheelNeedsPassword = false; # ou true si vous préférez taper le mot de passe

  # Paramètres Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true; # Optimise l'espace disque du Nix store
  nixpkgs.config.allowUnfree = true; # Permet d'installer des paquets non libres (comme VSCode ou Edge)

  # Audio avec PipeWire
  #sound.enable = true;
  services.pulseaudio.enable = false; # Désactiver PulseAudio classique
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # Allumer le Bluetooth au démarrage
  services.blueman.enable = true; # Applet graphique pour gérer le Bluetooth

  # Graphiques (Intel Iris Xe)
  services.xserver.videoDrivers = [ "modesetting" ]; # Pilote standard pour Intel
  #hardware.opengl.enable = true;
  #hardware.opengl.driSupport = true;
  #hardware.opengl.driSupport32Bit = true;

  # Hyprland et Wayland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Pour les applications X11
  };
  # Pour que les applications (Firefox, Electron apps) sachent qu'elles tournent sous Hyprland (Wayland)
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # Peut aider avec certains problèmes de curseur Intel
    NIXOS_OZONE_WL = "1"; # Pour Chromium/Electron pour utiliser Wayland
  };

  # Polices de caractères
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome # Pour les icônes
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    # Vous pouvez ajouter d'autres polices ici
  ];

  # Gestionnaire de connexion SDDM
  services.xserver.enable = true; # Nécessaire pour SDDM même sous Wayland pour certains setups
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Démarrer une session Wayland par défaut
  };
  # Assurez-vous qu'il y a une session Hyprland disponible pour SDDM
  environment.pathsToLink = [ "/share/wayland-sessions" ];


  # Paquets système de base (vous pouvez en ajouter d'autres)
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    unzip
    killall # Utile
    # pkgs.htop # Moniteur système en console
  ];

  # Activer l'XDG Desktop Portal pour Hyprland (partage d'écran, etc.)
  xdg.portal = {
    enable = true;
    wlr.enable = true; # Si vous utilisez des outils comme grim/slurp
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };


  # Version du système. Changez cela à chaque modification majeure pour faciliter les rollbacks.
  system.stateVersion = "24.11"; # Ou la version de NixOS que vous installez (ex: "24.05")
}
