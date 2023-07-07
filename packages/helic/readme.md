# About

*Helic* is a tool for synchronizing clipboard contents across *X11*, *tmux* and network, consisting of a daemon
listening for changes and a CLI client for use in programs like *Neovim*.

*X11* has three separate copy buffers, called the *clipboard*, the *primary selection* and the *secondary selection*.
Selections are used when text is selected with the mouse, while the clipboard is updated by `Ctrl-C`.

When some text is copied or selected in *X11*, the daemon receives an event that it proceeds to broadcast to the
configured targets.
If the source was a selection, the *X11* clipboard is updated as well.

The CLI program `hel` can be used to manually send text to the daemon, for example from *tmux* or *Neovim*.
If remote hosts are configured, each yank event is sent over the network to update their clipboards.

Several yank events are stored in memory in order to detect duplicates and cycles.

The CLI understands four different commands:

|Command|Meaning|
|---|---|
|`hel listen`|Start the daemon. This is best done from a *systemd* user service.|
|`hel yank`|Send standard input or argument to the daemon as a manual yank event.|
|`hel list`|Print the event history.|
|`hel load`|Load an older event to the clipboard, given its index into the history.|

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

The index in the first column, with 0 being the latest event, can be used with `hel load`.

# Installing and Running Helic

## Nix

The project uses a [Nix] [flake] to configure its build, and it is recommended to install or run it using *Nix* as well.
If *Nix* is installed and configured for use with *flakes*, the app can be run without installation like this:

```shell
$ nix run github:tek/helic -- listen
$ echo 'yank me' | nix run github:tek/helic -- yank --agent cli
$ nix run github:tek/helic -- list 100
$ nix run github:tek/helic -- load 5
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
|`listen`|`--agent NAME`|Used to avoid sending yanks back to the application that sent them.|
|`list`|positional (`hel list 5`)|Limit the number of printed events.|
|`load`|positional (`hel load 5`)|Choose the index of the event to be loaded.|
|`yank`|`--agent NAME`|Custom name used in the `list` output and to avoid cycles.|
|`yank`|`--text TEXT`|Yank text, uses stdin if not specified.|

# Configuring Helic

The app reads the first existing one of these three configuration files:

* The file specified with `--config-file`
* `$XDG_CONFIG_DIR/helic.yaml` (most likely `~/.config/helic.yaml`)
* `/etc/helic.yaml`

An example config file looks like this:

```yaml
name: myhost
maxHistory: 1000
verbose: true
net:
  enable: true
  port: 10001
  hosts:
    - "remote1:1000"
    - "remote2:2000"
  timeout: 5
tmux:
  enable: true
  exe: /bin/tmux
x11:
  enable: true
  display: ":0"
```

For *NixOS*, the file `/etc/helic.yaml` is generated from module options:

```nix
{
  services.helic = {
    enable = true;
    name = "myhost";
    maxHistory = 1000;
    verbose = true;
    user = "myuser";
    net = {
      enable = true;
      port = 10001;
      hosts = ["remote1:1000" "remote2:2000"];
      timeout = 5;
    };
    tmux = {
      enable = true;
      package = pkgs.tmux;
    };
    x11 = {
      enable = true;
      display = ":0";
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
|`verbose`||Increase the log level.|
|`net.enable`|`true`|Whether to send events over the network.|
|`net.port`|`9500`|The HTTP port the daemon listens to for both remote sync and `hel yank`.|
|`net.hosts`|`[]`|The addresses (with port) of the hosts to which this instance should broadcast yank events.|
|`net.timeout`|`300`|The timeout in milliseconds for requests to remote hosts.|
|`tmux.enable`|`true`|Whether to send events to *tmux*.|
|`tmux.package`|`pkgs.tmux`|Only for *NixOS*: The `nixpkgs` package used for the *tmux* executable.|
|`tmux.exe`|`tmux`|Only for YAML file: The path to the *tmux* executable|
|`x11.enable`|`true`|Whether to synchronize the X11 clipboard.|
|`x11.display`|`:0`|The display identifier used when connecting to the default display via GTK fails.|

# Neovim

*Neovim*'s clipboard requires configuration with a tool in any case, so changing it to use `hel` is simple:

```vim
let g:clipboard = {
  \   'name': 'helic',
  \   'copy': {
  \      '+': 'hel yank --agent nvim',
  \      '+': 'hel yank --agent nvim',
  \    },
  \   'paste': {
  \      '+': 'xsel -bo',
  \      '*': 'xsel -bo',
  \   },
  \ }
```

Since *Helic* updates the *X11* clipboard, a custom `paste` command is not necessary.

[Nix]: https://nixos.org/learn.html
[flake]: https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html
[Cabal]: https://cabal.readthedocs.io
