packages: { config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.helic;
  pkg = packages.${pkgs.system}.helic;
in {
  options.services.helic = {
    enable = mkEnableOption "Clipboard Manager";
    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The instance name used for identifying cycles. Defaults to the host name.";
    };
    net = {
      port = mkOption {
        type = types.port;
        default = 9500;
        description = "The http server is used both for yanking and broadcast to other hosts.";
      };
      hosts = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "The network addresses of other helic instances that should be shared with.";
        example = literalExpression ["otherhost:9501"];
      };
      timeout = mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
        description = "Maximum time in milliseconds to wait for a connection to a remote host to be made.";
      };
    };
    tmux = {
      enable = mkEnableOption "Enable tmux integration";
      package = mkOption {
        type = types.package;
        default = pkgs.tmux;
        description = "The package to use for tmux. Defaults to `pkgs.tmux`.";
      };
    };
    maxHistory = mkOption {
      type = types.nullOr types.ints.positive;
      default = 100;
      description = "The maximum number of yanks to store in memory.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [pkg];
    environment.etc."helic.yaml".text = ''
    ${if cfg.name == null then "" else "name: ${cfg.name}"}
    tmux:
      enable: ${if cfg.tmux.enable then "true" else "false"}
      ${if cfg.tmux.enable then "exe: ${cfg.tmux.package}/bin/tmux" else ""}
    net:
      port: ${toString cfg.net.port}
      hosts: [${concatMapStringsSep ", " (h: "'${h}'") cfg.net.hosts}]
      ${if cfg.net.timeout == null then "" else "timeout: ${toString cfg.net.timeout}"}
    maxHistory: ${toString cfg.maxHistory}
    '';
    systemd.user.services.helic = {
      description = "Clipboard Manager";
      wantedBy = ["default.target"];
      restartIfChanged = true;
      serviceConfig = {
        Restart = "always";
        ExecStart = "${pkg}/bin/hel listen";
      };
    };
  };
}
