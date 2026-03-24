self: { config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.helic;

  packages = self.packages.${pkgs.system};

  defaultPackage =
    if cfg.wayland.enable
    then packages.helic-wayland
    else if cfg.x11.enable
    then packages.helic-x11
    else packages.helic
    ;

  waylandEnabled =
    (config.programs.sway.enable or false)
    ||
    (config.programs.hyprland.enable or false);

  x11Enabled = config.services.xserver.enable or false;

  # Remove null values from a nested attrset.
  clean = attrs:
    let
      cleaned = filterAttrs (_: v: v != null) attrs;
    in
      mapAttrs (_: v: if builtins.isAttrs v then clean v else v) cleaned;

  toYAML = let
    indent = depth: concatStrings (genList (_: "  ") depth);
    scalar = v:
      if builtins.isBool v then (if v then "true" else "false")
      else if builtins.isInt v then toString v
      else if builtins.isFloat v then toString v
      else if builtins.isString v then v
      else throw "toYAML: unsupported scalar type";
    renderValue = depth: v:
      if builtins.isAttrs v then "\n" + renderAttrs depth v
      else if builtins.isList v then
        if v == [] then " []"
        else "\n" + concatMapStringsSep "\n" (item: "${indent depth}- ${scalar item}") v
      else " ${scalar v}";
    renderAttrs = depth: attrs:
      concatStringsSep "\n" (mapAttrsToList (k: v:
        "${indent depth}${k}:${renderValue (depth + 1) v}"
      ) attrs);
  in
    attrs: renderAttrs 0 attrs;

  configData = clean ({
    inherit (cfg) name maxHistory debounceMillis x11 wayland;
    tmux = {
      inherit (cfg.tmux) enable;
      exe = if cfg.tmux.enable then "${cfg.tmux.package}/bin/tmux" else null;
    };
    net = cfg.net // {
      auth = cfg.net.auth // {
        allowedKeys = if cfg.net.auth.allowedKeys == [] then null else cfg.net.auth.allowedKeys;
      };
    };
  });

in {

  options.services.helic = {

    enable = mkEnableOption "Clipboard Manager";

    user = mkOption {
      description = mdDoc ''
      A system user name or ID. If set, the service will only be started for that user.
      '';
      type = types.nullOr (types.either types.str types.ints.positive);
      default = null;
    };

    package = mkOption {
      type = types.package;
      default = defaultPackage;
      description = ''
      The package to use for helic.
      The default applies Cabal flags based on the `x11`/`wayland` config.
      '';
    };

    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The instance name used for identifying cycles. Defaults to the host name.";
    };

    maxHistory = mkOption {
      type = types.nullOr types.ints.positive;
      default = 100;
      description = "The maximum number of yanks to store in memory.";
    };

    debounceMillis = mkOption {
      type = types.nullOr types.ints.positive;
      default = 3000;
      description = "The interval in milliseconds during which the same text is ignored.";
    };

    verbose = mkEnableOption "Increase the log level.";

    net = {

      enable = mkEnableOption "network propagation" // { default = true; };

      port = mkOption {
        type = types.port;
        default = 9500;
        description = "The http server is used both for yanking and broadcast to other hosts.";
      };

      hosts = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "The network addresses of other helic instances that should be shared with.";
        example = literalExpression ["otherhost:9500"];
      };

      timeout = mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
        description = "Maximum time in milliseconds to wait for a connection to a remote host to be made.";
      };

      auth = {

        enable = mkEnableOption "authentication and encryption";

        privateKey = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Base64-encoded X25519 private key. If not set, a key pair is generated automatically.";
        };

        publicKey = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Base64-encoded X25519 public key. If not set, derived from the private key.";
        };

        allowedKeys = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Base64-encoded public keys of trusted remote instances. If empty and auth is enabled, unknown peers are added to pending.";
        };

        peersFile = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Absolute path to the peers state file. Defaults to ~/.local/state/helic/peers.yaml.";
        };

      };

      discovery = {

        enable = mkEnableOption "UDP broadcast peer discovery";

        port = mkOption {
          type = types.port;
          default = 9501;
          description = "UDP port for broadcast beacons.";
        };

        interval = mkOption {
          type = types.ints.positive;
          default = 5;
          description = "Seconds between beacon broadcasts.";
        };

        ttl = mkOption {
          type = types.ints.positive;
          default = 15;
          description = "Seconds after which a peer is considered stale if no beacon is received.";
        };

      };

    };

    tmux = {

      enable = mkEnableOption "tmux integration" // { default = true; };

      package = mkOption {
        type = types.package;
        default = pkgs.tmux;
        description = "The package to use for tmux. Defaults to `pkgs.tmux`.";
      };

    };

    x11 = {

      enable = mkEnableOption "X11 integration" // { default = x11Enabled; };

      subscribedSelections = mkOption {
        type = types.listOf types.str;
        default = ["Clipboard" "Primary"];
        description = "A list of unique X11 selections from which to listen to events for.";
        example = literalExpression ["Clipboard"];
      };

    };

    wayland = {

      enable = mkEnableOption "Wayland integration" // { default = waylandEnabled; };

    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [cfg.package];

    environment.etc."helic.yaml".text = toYAML configData;

    systemd.user.services.helic = {
      description = "Clipboard Manager";
      wantedBy = ["graphical-session.target"];
      restartIfChanged = true;
      unitConfig.ConditionUser = mkIf (cfg.user != null) cfg.user;
      serviceConfig = {
        Restart = "always";
        ExecStart = "${cfg.package}/bin/hel listen ${lib.optionalString cfg.verbose "--verbose"}";
      };

    };

  };

}
