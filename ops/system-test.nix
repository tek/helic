self: {util, ...}: let

  testModule = {

    services = {

      helic = {
        enable = true;
        user = "test";
        verbose = true;
      };

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

    users.users.test = {
      isNormalUser = true;
      password = "test";
      home = "/home/test";
      createHome = true;
    };

  };

in {

  services.user-session = {

    ports.helic = { guest = 9500; host = 50; };

    nixos-base = [
      (import ./module.nix self)
      testModule
    ];

  };

  envs.system-test = {
    basePort = 10000;
    services.user-session.enable = true;
    expose.shell = true;
  };

  commands.system-test = let

    check = util.zscript "check" ''
    sleep 1
    systemctl --user status helic
    '';

  in {
    env = "system-test";
    command = ''
    sshpass -p test ssh -p 10022 test@localhost ${check}
    '';
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

}
