self: {util, ...}: let

  userModule = {
    users.users.test = {
      isNormalUser = true;
      password = "test";
      home = "/home/test";
      createHome = true;
    };
  };

  helicX11Module = {
    services.helic = {
      enable = true;
      user = "test";
      verbose = true;
    };
  };

  helicWaylandModule = {
    services.helic = {
      enable = true;
      user = "test";
      verbose = true;
      wayland.enable = true;
    };
  };

  x11Module = { pkgs, ... }: {

    environment.systemPackages = [pkgs.xclip];

    services = {

      xserver.enable = true;
      xserver.desktopManager.xfce.enable = true;

      displayManager = {
        autoLogin = {
          enable = true;
          user = "test";
        };
        sddm.enable = true;
        defaultSession = "xfce";
      };

    };

  };

  waylandModule = { pkgs, ... }: {

    programs.sway = {
      enable = true;
      extraPackages = [];
    };

    environment.systemPackages = [pkgs.wl-clipboard];

    environment.etc."sway/config.d/helic-test".text = ''
      exec systemctl --user import-environment WAYLAND_DISPLAY XDG_RUNTIME_DIR
      exec systemctl --user start graphical-session.target
    '';

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "sway";
        user = "test";
      };
    };

  };

  session = modules: {
    ports.helic = { guest = 9500; host = 50; };

    nixos-base = [
      (import ./module.nix self)
      userModule
    ] ++ modules;
  };

in {

  services.x11-session = session [helicX11Module x11Module];

  services.wayland-session = session [helicWaylandModule waylandModule];

  envs.x11-test = {
    package-set.extends = "ghc912";
    basePort = 10000;
    services.x11-session.enable = true;
    expose.shell = true;
  };

  envs.wayland-test = {
    package-set.extends = "ghc912";
    basePort = 11000;
    services.wayland-session.enable = true;
    expose.shell = true;
  };

  commands.x11-test = let

    check = util.zscript "check" ''
    for i in $(seq 1 30); do
      systemctl --user is-active helic && break
      sleep 1
    done
    systemctl --user status helic
    export DISPLAY=:0
    export XAUTHORITY=$(systemctl --user show-environment | sed -n 's/^XAUTHORITY=//p')
    echo -n 'helic-x11-test' | xclip -selection clipboard
    sleep 3
    hel list | grep -q 'helic-x11-test'
    '';

  in {
    env = "x11-test";
    command = ''
    sshpass -p test ssh -p 10022 test@localhost ${check}
    '';
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

  commands.wayland-test = let

    check = util.zscript "check" ''
    for i in $(seq 1 30); do
      systemctl --user is-active helic && break
      sleep 1
    done
    systemctl --user status helic
    export WAYLAND_DISPLAY=wayland-1

    # Test clipboard read: wl-copy -> helic detects it
    wl-copy 'helic-wayland-test'
    sleep 3
    hel list | grep 'helic-wayland-test'

    # Test clipboard write: hel yank -> wl-paste reads it
    echo -n 'helic-wayland-write' | hel yank
    sleep 3
    result=$(timeout 5 wl-paste 2>&1) || true
    [[ $result == 'helic-wayland-write' ]]
    '';

  in {
    env = "wayland-test";
    command = ''
    sshpass -p test ssh -p 11022 test@localhost ${check}
    '';
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

}
