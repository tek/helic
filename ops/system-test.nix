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

  tmuxModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.system}.helic
      pkgs.tmux
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
    for i in $(seq 1 30); do
      systemctl --user is-active helic && break
      sleep 1
    done
    systemctl --no-pager --user status helic
    export DISPLAY=:0
    export XAUTHORITY=$(systemctl --user show-environment | sed -n 's/^XAUTHORITY=//p')
    echo -n 'helic-x11-test' | xclip -selection clipboard >/dev/null 2>&1 &
    disown
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
    systemctl --no-pager --user status helic
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

  commands.leak-test = let

    check = util.zscript "check" ''
    # Start helic daemon
    hel --config-file /etc/helic-leak.yaml listen &
    pid=$!
    cleanup() { kill $pid 2>/dev/null; }
    trap cleanup EXIT

    # Wait for HTTP server
    for i in $(seq 1 30); do
      curl -sf http://localhost:9500/event >/dev/null 2>&1 && break
      sleep 1
    done

    # Make 20 yank + list requests to localhost
    for i in $(seq 1 20); do
      echo -n "leak-test-$i" | hel --config-file /etc/helic-leak.yaml yank
      hel --config-file /etc/helic-leak.yaml list >/dev/null 2>&1
      sleep 0.1
    done

    sleep 2

    # Also try load requests
    for i in $(seq 1 10); do
      hel --config-file /etc/helic-leak.yaml load 0 >/dev/null 2>&1 || true
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
    command = ''
    sshpass -p test ssh -p 13022 test@localhost ${check}
    '';
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

  commands.tmux-test = let

    check = util.zscript "check" ''
    # Start a tmux server session for helic to connect to
    tmux new-session -d -s main

    # Start helic daemon
    hel --config-file /etc/helic-tmux.yaml listen &
    pid=$!
    cleanup() { kill $pid 2>/dev/null; tmux kill-server 2>/dev/null; }
    trap cleanup EXIT

    # Wait for HTTP server to be ready
    for i in $(seq 1 30); do
      curl -sf http://localhost:9500/event >/dev/null 2>&1 && break
      sleep 1
    done

    # Give the tmux listener time to connect in control mode
    sleep 5

    # Test 1: tmux set-buffer -> hel list (tmux listener detects clipboard change)
    tmux set-buffer 'helic-tmux-read-test'
    for i in $(seq 1 10); do
      hel --config-file /etc/helic-tmux.yaml list 2>/dev/null | grep -q 'helic-tmux-read-test' && break
      sleep 1
    done
    hel --config-file /etc/helic-tmux.yaml list | grep -q 'helic-tmux-read-test'

    # Test 2: hel yank -> tmux show-buffer (agent writes to tmux buffer)
    echo -n 'helic-tmux-write-test' | hel --config-file /etc/helic-tmux.yaml yank
    for i in $(seq 1 10); do
      result=$(tmux show-buffer 2>/dev/null) || true
      [[ $result == 'helic-tmux-write-test' ]] && break
      sleep 1
    done
    [[ $(tmux show-buffer) == 'helic-tmux-write-test' ]]
    '';

  in {
    env = "tmux-test";
    command = ''
    sshpass -p test ssh -p 14022 test@localhost ${check}
    '';
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

  commands.discovery-test = let

    check = util.zscript "check" ''
    # Clean up stale peers files from previous runs
    rm -rf /tmp/helic-a /tmp/helic-b

    # Start two helic instances as background processes
    hel --config-file /etc/helic-a.yaml listen &
    pid_a=$!
    hel --config-file /etc/helic-b.yaml listen &
    pid_b=$!

    cleanup() { kill $pid_a $pid_b 2>/dev/null; }
    trap cleanup EXIT

    # Wait for both HTTP servers to be ready
    for i in $(seq 1 30); do
      curl -sf http://localhost:9500/key >/dev/null 2>&1 && break
      sleep 1
    done
    for i in $(seq 1 30); do
      curl -sf http://localhost:9502/key >/dev/null 2>&1 && break
      sleep 1
    done

    # Wait for UDP discovery to exchange beacons
    sleep 6

    # Trigger connection attempts on both sides so each discovers the other's key.
    # In auth mode, broadcastTargets adds unknown discovered peers to pending.
    echo -n 'trigger-auth-a' | hel --config-file /etc/helic-a.yaml yank
    echo 'trigger-auth-a yank exit code: '$?
    echo -n 'trigger-auth-b' | hel --config-file /etc/helic-b.yaml yank
    echo 'trigger-auth-b yank exit code: '$?
    sleep 2

    echo '--- B list ---'
    hel --config-file /etc/helic-b.yaml list
    echo '--- A list ---'
    hel --config-file /etc/helic-a.yaml list

    # Verify that auth blocked the events from being synced.
    # trigger-auth-a was yanked on A but should NOT appear on B.
    # trigger-auth-b was yanked on B but should NOT appear on A.
    if hel --config-file /etc/helic-b.yaml list | grep -q 'trigger-auth-a'; then
      echo 'FAIL: B received trigger-auth-a despite auth not being accepted'
      exit 1
    fi
    if hel --config-file /etc/helic-a.yaml list | grep -q 'trigger-auth-b'; then
      echo 'FAIL: A received trigger-auth-b despite auth not being accepted'
      exit 1
    fi

    # Both instances should have the other in their pending list
    hel --config-file /etc/helic-a.yaml auth list
    hel --config-file /etc/helic-b.yaml auth list

    # Accept all pending peers on both instances
    hel --config-file /etc/helic-a.yaml auth accept-all
    hel --config-file /etc/helic-b.yaml auth accept-all

    # Now yank the real payload on A
    echo -n 'discovery-test-payload' | hel --config-file /etc/helic-a.yaml yank

    # Wait for broadcast to instance B
    sleep 3

    # Check instance B has the event
    hel --config-file /etc/helic-b.yaml list | grep -q 'discovery-test-payload'
    '';

  in {
    env = "discovery-test";
    command = ''
    sshpass -p test ssh -p 12022 test@localhost ${check}
    '';
    expose = true;
    buildInputs = pkgs: [pkgs.sshpass];
  };

}
