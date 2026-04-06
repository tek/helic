self: {util, ...}: let

  # ---------------------------------------------------------------------------
  # Shell command generators
  # ---------------------------------------------------------------------------

  # Poll until a systemd user service is active, then print its status.
  # service: unit name (e.g. "helic")
  waitService = service: ''
    for i in $(seq 1 30); do
      systemctl --user is-active ${service} && break
      sleep 1
    done
    systemctl --no-pager --user status ${service}
  '';

  # Poll until an HTTP endpoint responds successfully.
  # url: full URL including port and path (e.g. "http://localhost:9500/event")
  waitHttp = url: ''
    for i in $(seq 1 30); do
      curl -sf ${url} >/dev/null 2>&1 && break
      sleep 1
    done
  '';

  # Start a helic daemon in the background with a cleanup trap.
  # cfg:          config file path
  # extraCleanup: additional cleanup commands (e.g. "tmux kill-server 2>/dev/null;")
  daemon = { cfg, extraCleanup ? "" }: ''
    hel --config-file ${cfg} listen &
    pid=$!
    cleanup() { kill $pid 2>/dev/null; ${extraCleanup} }
    trap cleanup EXIT
  '';

  # Start two helic daemons with a combined cleanup trap.
  daemon2 = { cfgA, cfgB }: ''
    hel --config-file ${cfgA} listen &
    pid_a=$!
    hel --config-file ${cfgB} listen &
    pid_b=$!
    cleanup() { kill $pid_a $pid_b 2>/dev/null; }
    trap cleanup EXIT
  '';

  # Retry a shell command up to n times with 1-second sleeps.
  # n:   max attempts
  # cmd: shell command string to try
  retry = n: cmd: ''
    for i in $(seq 1 ${toString n}); do
      ${cmd} && break
      sleep 1
    done
  '';

  # Shorthand for `hel --config-file <cfg> <args>`.
  hel = cfg: args: "hel --config-file ${cfg} ${args}";

  # Build the outer SSH command that runs a zscript inside the VM.
  # port: SSH port on the host
  # check: path to the zscript derivation
  sshTest = { port, check }: ''
    sshpass -p test ssh -p ${toString port} test@localhost ${check}
  '';

  # ---------------------------------------------------------------------------
  # NixOS modules
  # ---------------------------------------------------------------------------

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

  discoveryModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.system}.helic
      pkgs.curl
    ];

    environment.etc."helic-a.yaml".text = ''
    name: instance-a
    verbose: true
    net:
      enable: true
      port: 9500
      timeout: 5000
      auth:
        enable: true
        privateKey: CFUmbCKzYtmnvy7duaq4BPA8bp4U5MDUd9TGdEOuWEM=
        publicKey: eDsSQYyE3555i3dDAiSiMeoOyo7EL2oGeFW1M2YeKHQ=
        peersFile: /tmp/helic-a/peers.yaml
      discovery:
        enable: true
        port: 9501
        interval: 2
        ttl: 10
    tmux:
      enable: false
    x11:
      enable: false
    wayland:
      enable: false
    '';
    environment.etc."helic-b.yaml".text = ''
    name: instance-b
    verbose: true
    net:
      enable: true
      port: 9502
      timeout: 5000
      auth:
        enable: true
        privateKey: IOVMnyBg34PN52t0Rt85XJd++hNCik89/T0gKxBTtF8=
        publicKey: FplCPBqA4D7PRhmDjL2e9QqXF7JZIQziBuO74fqMt3c=
        peersFile: /tmp/helic-b/peers.yaml
      discovery:
        enable: true
        port: 9501
        interval: 2
        ttl: 10
    tmux:
      enable: false
    x11:
      enable: false
    wayland:
      enable: false
    '';
  };

  tmuxModule = { pkgs, ... }: let
    # Need tmux >= 3.4 for %paste-buffer-changed control mode notification.
    # The nixpkgs input provides 3.5a, which has the code but may not reliably send the notification.
    # Pin to 3.6a which is verified to work.
    tmux36 = pkgs.tmux.overrideAttrs (old: rec {
      version = "3.6a";
      src = pkgs.fetchFromGitHub {
        owner = "tmux";
        repo = "tmux";
        rev = version;
        hash = "sha256-VwOyR9YYhA/uyVRJbspNrKkJWJGYFFktwPnnwnIJ97s=";
      };
    });
  in {
    environment.systemPackages = [
      self.packages.${pkgs.system}.helic
      tmux36
      pkgs.curl
    ];

    environment.etc."helic-tmux.yaml".text = ''
    name: tmux-test
    verbose: true
    net:
      broadcast: false
    tmux:
      enable: true
    x11:
      enable: false
    wayland:
      enable: false
    '';
  };

  leakModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.system}.helic
      pkgs.curl
      pkgs.iproute2
    ];

    environment.etc."helic-leak-key".text = "dummy-public-key-for-testing";

    environment.etc."helic-leak.yaml".text = ''
    name: leak-test
    verbose: true
    net:
      enable: true
      port: 9500
      timeout: 5000
      hosts: ['nonexistent:9500']
      auth:
        enable: false
        publicKey: /etc/helic-leak-key
    tmux:
      enable: false
    x11:
      enable: false
    wayland:
      enable: false
    '';
  };

  # ---------------------------------------------------------------------------
  # Sessions
  # ---------------------------------------------------------------------------

  tmuxSession = {
    ports.helic-tmux = { guest = 9500; host = 50; };

    nixos-base = [
      userModule
      tmuxModule
    ];
  };

  leakSession = {
    ports.helic-leak = { guest = 9500; host = 50; };

    nixos-base = [
      userModule
      leakModule
    ];
  };

  discoverySession = {
    ports.helic-a = { guest = 9500; host = 50; };
    ports.helic-b = { guest = 9502; host = 52; };

    nixos-base = [
      userModule
      discoveryModule
    ];
  };

  # ---------------------------------------------------------------------------
  # Config-file shorthands
  # ---------------------------------------------------------------------------

  cfgA = "/etc/helic-a.yaml";
  cfgB = "/etc/helic-b.yaml";
  cfgTmux = "/etc/helic-tmux.yaml";
  cfgLeak = "/etc/helic-leak.yaml";

in {

  services.x11-session = session [helicX11Module x11Module];

  services.wayland-session = session [helicWaylandModule waylandModule];

  services.discovery-session = discoverySession;

  services.tmux-session = tmuxSession;

  services.leak-session = leakSession;

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

  envs.tmux-test = {
    package-set.extends = "ghc912";
    basePort = 14000;
    services.tmux-session.enable = true;
    expose.shell = true;
  };

  envs.leak-test = {
    package-set.extends = "ghc912";
    basePort = 13000;
    services.leak-session.enable = true;
    expose.shell = true;
  };

  envs.discovery-test = {
    package-set.extends = "ghc912";
    basePort = 12000;
    services.discovery-session.enable = true;
    expose.shell = true;
  };

  commands.x11-test = let

    check = util.zscript "check" ''
    ${waitService "helic"}
    export DISPLAY=:0
    export XAUTHORITY=$(systemctl --user show-environment | sed -n 's/^XAUTHORITY=//p')
    echo -n 'helic-x11-test' | xclip -selection clipboard >/dev/null 2>&1 &
    disown
    sleep 3
    hel list | grep -q 'helic-x11-test'
    '';

  in {
    env = "x11-test";
    command = sshTest { port = 10022; inherit check; };
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

  commands.wayland-test = let

    check = util.zscript "check" ''
    ${waitService "helic"}
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
    command = sshTest { port = 11022; inherit check; };
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

  commands.leak-test = let

    check = util.zscript "check" ''
    ${daemon { cfg = cfgLeak; }}
    ${waitHttp "http://localhost:9500/event"}

    # Make 20 yank + list requests to localhost
    for i in $(seq 1 20); do
      echo -n "leak-test-$i" | ${hel cfgLeak "yank"}
      ${hel cfgLeak "list"} >/dev/null 2>&1
      sleep 0.1
    done

    sleep 2

    # Also try load requests
    for i in $(seq 1 10); do
      ${hel cfgLeak "load 0"} >/dev/null 2>&1 || true
      sleep 0.1
    done

    sleep 2

    # Connect to SSE endpoint and disconnect several times
    for i in $(seq 1 15); do
      curl -sf --max-time 0.5 http://localhost:9500/event/listen >/dev/null 2>&1 || true
      sleep 0.2
    done

    sleep 15

    # Check for CLOSE_WAIT connections
    close_wait=$(ss -tn state close-wait sport = :9500 | tail -n +2 | wc -l)
    echo "CLOSE_WAIT connections: $close_wait"

    if [ "$close_wait" -gt 0 ]; then
      echo "FAIL: Found $close_wait CLOSE_WAIT connections on port 9500"
      ss -tnp state close-wait sport = :9500
      exit 1
    fi

    echo "PASS: No CLOSE_WAIT connection leak detected"
    '';

  in {
    env = "leak-test";
    command = sshTest { port = 13022; inherit check; };
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

  commands.tmux-test = let

    retryTmuxRead = retry 10 (hel cfgTmux "list" + " 2>/dev/null | grep -q 'helic-tmux-read-test'");

    check = util.zscript "check" ''
    # Start a tmux server session
    tmux new-session -d -s main

    ${daemon { cfg = cfgTmux; extraCleanup = "tmux kill-server 2>/dev/null;"; }}
    ${waitHttp "http://localhost:9500/event"}

    # Wait for tmux control mode client to connect
    ${retry 30 ''[[ $(tmux list-clients 2>/dev/null | wc -l) -ge 1 ]]''}

    # Test: hel yank -> tmux show-buffer (agent writes to tmux buffer)
    echo -n 'helic-tmux-write-test' | ${hel cfgTmux "yank"}
    ${retry 10 ''[[ $(tmux show-buffer 2>/dev/null) == 'helic-tmux-write-test' ]]''}
    [[ $(tmux show-buffer) == 'helic-tmux-write-test' ]]

    # Test: tmux set-buffer -> hel list (listener detects %paste-buffer-changed)
    tmux set-buffer 'helic-tmux-read-test'
    ${retryTmuxRead}
    ${hel cfgTmux "list"} | grep -q 'helic-tmux-read-test'
    '';

  in {
    env = "tmux-test";
    command = sshTest { port = 14022; inherit check; };
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

  commands.discovery-test = let

    check = util.zscript "check" ''
    # Clean up stale peers files from previous runs
    rm -rf /tmp/helic-a /tmp/helic-b

    ${daemon2 { cfgA = cfgA; cfgB = cfgB; }}
    ${waitHttp "http://localhost:9500/key"}
    ${waitHttp "http://localhost:9502/key"}

    # Wait for UDP discovery to exchange beacons
    sleep 6

    # Trigger connection attempts on both sides so each discovers the other's key.
    # In auth mode, broadcastTargets adds unknown discovered peers to pending.
    echo -n 'trigger-auth-a' | ${hel cfgA "yank"}
    echo 'trigger-auth-a yank exit code: '$?
    echo -n 'trigger-auth-b' | ${hel cfgB "yank"}
    echo 'trigger-auth-b yank exit code: '$?
    sleep 2

    echo '--- B list ---'
    ${hel cfgB "list"}
    echo '--- A list ---'
    ${hel cfgA "list"}

    # Verify that auth blocked the events from being synced.
    # trigger-auth-a was yanked on A but should NOT appear on B.
    # trigger-auth-b was yanked on B but should NOT appear on A.
    if ${hel cfgB "list"} | grep -q 'trigger-auth-a'; then
      echo 'FAIL: B received trigger-auth-a despite auth not being accepted'
      exit 1
    fi
    if ${hel cfgA "list"} | grep -q 'trigger-auth-b'; then
      echo 'FAIL: A received trigger-auth-b despite auth not being accepted'
      exit 1
    fi

    # Both instances should have the other in their pending list
    ${hel cfgA "auth list"}
    ${hel cfgB "auth list"}

    # Accept all pending peers on both instances
    ${hel cfgA "auth accept-all"}
    ${hel cfgB "auth accept-all"}

    # Now yank the real payload on A
    echo -n 'discovery-test-payload' | ${hel cfgA "yank"}

    # Wait for broadcast to instance B
    sleep 3

    # Check instance B has the event
    ${hel cfgB "list"} | grep -q 'discovery-test-payload'
    '';

  in {
    env = "discovery-test";
    command = sshTest { port = 12022; inherit check; };
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

}

