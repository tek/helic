# About

*Helic* is a tool for synchronizing clipboard contents across *X11*, *Wayland*, *tmux* and network, consisting of a
daemon listening for changes and a CLI client for use in programs like *Neovim*.

*X11* has three separate copy buffers, called the *clipboard*, the *primary selection* and the *secondary selection*.
Selections are used when text is selected with the mouse, while the clipboard is updated by `Ctrl-C`.

*Wayland* is supported natively using the `ext-data-control-v1` protocol, monitoring both clipboard and primary
selection without depending on external tools like `wl-clipboard`.

When something is copied or selected, the daemon receives an event that it proceeds to broadcast to the configured
targets.
If the source was a selection, the clipboard is updated as well.

The daemon supports both text and binary content (e.g., images), preserving MIME type information across the network.

The CLI program `hel` can be used to manually send text or binary content to the daemon, for example from *tmux* or
*Neovim*.
If remote hosts are configured, each yank event is sent over the network to update their clipboards.
Events can optionally be encrypted and authenticated.

Several yank events are stored in memory in order to detect duplicates and cycles.

Remote hosts may be specified explicitly in the config, or discovered automatically via UDP broadcast beacons on the
local network.

The CLI understands these commands:

|Command|Meaning|
|---|---|
|`hel listen`|Start the daemon. This is best done from a *systemd* user service.|
|`hel yank`|Send standard input or argument to the daemon as a manual yank event.|
|`hel list`|Print the event history.|
|`hel load`|Load an older event to the clipboard, given its index into the history.|
|`hel paste`|Write event content to stdout or a file (useful for binary content like images).|
|`hel auth`|Review and authorize pending peers.|

The `list` command will print a table like this:

```
╭───┬──────────┬───────┬──────────┬──────────────────────────╮
│ # │ Instance │ Agent │   Time   │         Content          │
╞═══╪══════════╪═══════╪══════════╪══════════════════════════╡
│ 2 │   test   │ nvim  │ 12:00:00 │ single line              │
├───┼──────────┼───────┼──────────┼──────────────────────────┤
│ 1 │   test   │ nvim  │ 12:00:00 │ single line with newline │
├───┼──────────┼───────┼──────────┼──────────────────────────┤
│ 0 │   test   │ nvim  │ 12:00:00 │ three lines 1 [3 lines]  │
╰───┴──────────┴───────┴──────────┴──────────────────────────╯
```

The index in the first column, with 0 being the latest event, can be used with `hel load` or `hel paste`.

# Installing and Running Helic

## Nix

The project uses a [Nix] [flake] to configure its build, and it is recommended to install or run it using *Nix* as well.
If *Nix* is installed and configured for use with *flakes*, the app can be run without installation like this:

```shell
$ nix run github:tek/helic -- listen
$ echo 'yank me' | nix run github:tek/helic -- yank --agent cli
$ nix run github:tek/helic -- list 100
$ nix run github:tek/helic -- load 5
$ nix run github:tek/helic -- paste --output /tmp/image.png
```

## NixOS

The flake provides a *NixOS* module that can be used by adding it to `/etc/nixos/flake.nix`:

```nix
{
  inputs.helic.url = "github:tek/helic";
  outputs = { nixpkgs, helic, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [helic.nixosModules.default];
      services.helic.enable = true;
    };
  };
}
```

With this, a `systemd` user service will be started on login and the client will be in `$PATH`:

```shell
$ echo 'yank me' | hel yank
$ hel yank --agent custom-name --text 'yank me'
```

After a rebuild, the service may not be started right away, so this command must be executed:

```shell
$ systemctl --user start helic
```

Globally enabled `systemd` user services are started for all users on login.
To prevent that, you can set the module option `services.helic.user = "myuser"`.

The NixOS module automatically selects the appropriate package variant based on the configuration in `x11` and
`wayland`.

## Without Nix

Alternatively, the app can be installed using a *Haskell* package manager, like [Cabal]:

```shell
$ cabal install helic
$ hel listen
```

## CLI

If no command has been specified explicitly, *Helic* decides which one to start by the presence of stdin data:

```shell
$ hel # start daemon
$ echo 'yank me' | hel # yank
```

Global CLI options are specified *before* the command name, command-specific ones after it.

|Command|Name|Description|
|---|---|---|
|Global|`--verbose`|Increase the log level.|
|Global|`--config-file FILE`|Use the specified file path instead of the default locations.|
|`listen`|—|Start the daemon.|
|`yank`|`--agent NAME`|Custom name used in the `list` output and to avoid cycles.|
|`yank`|`--text TEXT`|Yank text, uses stdin if not specified.|
|`yank`|`--image FILE`|Yank an image file as binary content.|
|`yank`|`--mime TYPE`|Specify the MIME type for binary content from `--image` or stdin.|
|`list`|positional (`hel list 5`)|Limit the number of printed events.|
|`load`|positional (`hel load 5`)|Choose the index of the event to be loaded.|
|`paste`|positional (`hel paste 3`)|Index of the event (default: latest).|
|`paste`|`--output FILE`|Write to a file instead of stdout (use `-` for stdout).|
|`auth`|`--list`|List pending peers without prompting.|
|`auth`|`--accept HOST`|Accept a pending peer by host name.|
|`auth`|`--reject HOST`|Reject a pending peer by host name.|
|`auth`|`--accept-all`|Accept all pending peers.|

The `paste` command is useful for binary clipboard content (such as images) that cannot be meaningfully printed by
`hel list`.
Binary content is automatically written to stdout when it is redirected to a pipe or file.
When stdout is a terminal, binary content requires `--output` to specify a file, or `--output -` to force it.

# Authentication and Encryption

When `net.auth.enable` is set to `true`, *Helic* uses *X25519 crypto_box* for authenticating and encrypting network
sync events.
A key pair is generated automatically on first startup and stored in `~/.local/state/helic/`.
Alternatively, keys can be specified in the config.

Unknown peers that send authenticated requests are placed into a pending list.
Use `hel auth` to review, accept, or reject pending peers:

```shell
$ hel auth --list          # show pending peers
$ hel auth --accept myhost # accept a peer
$ hel auth --reject myhost # reject a peer
$ hel auth --accept-all    # accept all pending peers
$ hel auth                 # interactive prompt
```

Pre-trusted public keys can be added to `net.auth.allowedKeys` to skip the acceptance step.

### Key Generation

By default, *Helic* generates a key pair automatically on first startup and stores it in
`~/.local/state/helic/key.x25519`.

To generate keys manually (e.g., for pre-sharing public keys between hosts), use the bundled `helic-gen-keys` tool:

```shell
$ nix run github:tek/helic#helic-gen-keys
net:
  auth:
    privateKey: 8C1jIHfrLqvgVP9AUHIbhieZkmRVB6xHvDzBphq+ZXw=
    publicKey: I5XTL3+USJW6seRmRLnAtJodLM2QeQdnKFpKDTiORVY=
```

The default output format is `yaml`, which can be used directly in the config file.
Pass `--format Nixos` for NixOS module syntax:

```shell
$ nix run github:tek/helic#helic-gen-keys -- --format Nixos
services.helic = {
  net.auth.privateKey = "8C1jIHfrLqvgVP9AUHIbhieZkmRVB6xHvDzBphq+ZXw=";
  net.auth.publicKey = "I5XTL3+USJW6seRmRLnAtJodLM2QeQdnKFpKDTiORVY=";
};
```

The private key can be set via `net.auth.privateKey`, and the public key of a remote host can be added to
`net.auth.allowedKeys` to pre-authorize it.

When auth is disabled (the default), events are sent in plain text without verification, which is suitable for trusted
networks.

# Peer Discovery

With `net.discovery.enable` set to `true`, *Helic* broadcasts UDP beacons on the local network to automatically discover
other instances, eliminating the need to configure `net.hosts` manually.

Discovered peers are subject to the same authorization rules as manually configured hosts when auth is enabled—unknown
peers are added to the pending list and must be accepted before events are synced to them.

All instances that should discover each other must use the same `net.discovery.port`.

Discovery options:

|Key|Default|Description|
|---|---|---|
|`net.discovery.enable`|`false`|Enable UDP broadcast peer discovery.|
|`net.discovery.port`|`9501`|UDP port for beacon broadcast and listening.|
|`net.discovery.interval`|`5`|Seconds between beacon broadcasts.|
|`net.discovery.ttl`|`15`|Seconds after which a peer is considered stale.|

# Configuring Helic

The app reads the first existing one of these three configuration files:

* The file specified with `--config-file`
* `$XDG_CONFIG_DIR/helic.yaml` (most likely `~/.config/helic.yaml`)
* `/etc/helic.yaml`

An example config file looks like this:

```yaml
name: myhost
maxHistory: 1000
debounceMillis: 3000
verbose: true
net:
  enable: true
  port: 10001
  hosts:
    - "remote1:1000"
    - "remote2:2000"
  timeout: 5
  auth:
    enable: true
    allowedKeys:
      - "base64-encoded-public-key-of-remote1"
  discovery:
    enable: true
    port: 9501
    interval: 5
    ttl: 15
tmux:
  enable: true
  exe: /bin/tmux
x11:
  enable: true
wayland:
  enable: false
```

For *NixOS*, the file `/etc/helic.yaml` is generated from module options:

```nix
{
  services.helic = {
    enable = true;
    name = "myhost";
    maxHistory = 1000;
    debounceMillis = 3000;
    verbose = true;
    user = "myuser";
    net = {
      enable = true;
      port = 10001;
      hosts = ["remote1:1000" "remote2:2000"];
      timeout = 5;
      auth = {
        enable = true;
        allowedKeys = ["base64-encoded-public-key-of-remote1"];
      };
      discovery = {
        enable = true;
        port = 9501;
        interval = 5;
        ttl = 15;
      };
    };
    tmux = {
      enable = true;
      package = pkgs.tmux;
    };
    x11 = {
      enable = true;
      subscribedSelections = ["Clipboard" "Primary"];
    };
    wayland = {
      enable = false;
    };
  };
}
```

The meaning of these options is:

|Key|Default|Description|
|---|---|---|
|`name`|Host name|An identifier for the host, used for filtering duplicates.|
|`user`|null|Only for *NixOS*: If set, only start the service for that user.|
|`maxHistory`|100|The number of yanks that should be kept.|
|`debounceMillis`|3000|The interval in milliseconds during which the same text is ignored.|
|`verbose`||Increase the log level.|
|`net.enable`|`true`|Whether to send events over the network.|
|`net.port`|`9500`|The HTTP port the daemon listens to for both remote sync and `hel yank`.|
|`net.hosts`|`[]`|The addresses (with port) of the hosts to which this instance should broadcast yank events.|
|`net.timeout`|`2000`|The timeout in milliseconds for requests to remote hosts.|
|`net.auth.enable`|`false`|Enable X25519 authentication and encryption for network events.|
|`net.auth.privateKey`|generated|Base64-encoded X25519 private key. Generated automatically if not set.|
|`net.auth.publicKey`|derived|Base64-encoded X25519 public key. Derived from the private key if not set.|
|`net.auth.allowedKeys`|`[]`|Base64-encoded public keys of trusted peers. Unknown peers are added to the pending list.|
|`net.auth.peersFile`|`~/.local/state/helic/peers.yaml`|Path to the peers state file.|
|`net.discovery.enable`|`false`|Enable UDP broadcast peer discovery on the local network.|
|`net.discovery.port`|`9501`|UDP port for beacon broadcast and listening.|
|`net.discovery.interval`|`5`|Seconds between beacon broadcasts.|
|`net.discovery.ttl`|`15`|Seconds after which a peer is considered stale.|
|`tmux.enable`|`true`|Whether to send/receive events to/from *tmux*.|
|`tmux.package`|`pkgs.tmux`|Only for *NixOS*: The `nixpkgs` package used for the *tmux* executable.|
|`tmux.exe`|`tmux`|Only for YAML file: The path to the *tmux* executable.|
|`x11.enable`|auto|Whether to synchronize the X11 clipboard. Defaults to `true` when an X server is enabled.|
|`x11.subscribedSelections`|`["Clipboard" "Primary"]`|Which X11 selections to listen to.|
|`wayland.enable`|auto|Whether to synchronize the Wayland clipboard. Defaults to `true` when Sway or Hyprland is enabled.|

# Neovim

*Neovim*'s clipboard requires configuration with a tool in any case, so changing it to use `hel` is simple:

```vim
let g:clipboard = {
  \   'name': 'helic',
  \   'copy': {
  \      '+': 'hel yank --agent nvim',
  \      '*': 'hel yank --agent nvim',
  \    },
  \   'paste': {
  \      '+': 'hel paste',
  \      '*': 'hel paste',
  \   },
  \ }
```

Since *Helic* updates the system clipboard, a custom `paste` command is not strictly necessary.

[Nix]: https://nixos.org/learn.html
[flake]: https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html
[Cabal]: https://cabal.readthedocs.io
