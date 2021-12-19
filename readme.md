# About

*Helic* is a tool for synchronizing clipboard contents across *X11*, *tmux* and network, consisting of a daemon
listening for changes and a CLI client for use in programs like *Neovim*.

When some text is copied or selected in *X11*, the daemon receives an event that it proceeds to broadcast to the
configured targets.
If the source was a selection, the *X11* clipboard is updated as well.
The CLI program `hel` can be used to manually send text to the daemon, for example from *tmux* or *Neovim*.
If remote hosts are configured, each yank event is sent over the network to update their clipboards.

Several yank events are stored in memory in order to avoid duplicates and cycles.

# Installing and Running Helic

## Nix

The project uses a [Nix] [flake] to configure its build, and it is recommended to install or run it using *Nix* as well.
If *Nix* is installed and configured for use with *flakes*, the app can be run like this:

```shell
$ nix run github:tek/helic -- listen
$ echo 'yank me' | nix run github:tek/helic -- yank
```

## NixOS

The flake provides a *NixOS* module that can be used by adding it to `/etc/nixos/configuration.nix`:

```nix
{
  inputs.helic.url = github:/tek/helic;
  outputs = { nixpkgs, helic, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [helic.nixosModule];
      services.helic.enable = true;
    };
  };
}
```

With this, a *systemd* user service will be started on login and the client will be in `$PATH`:

```shell
$ echo 'yank me' | hel yank
```

## Without Nix

Alternatively, the app can be installed using a *Haskell* package manager, like [Cabal]:

```shell
$ cabal install helic
$ hel listen
```

## CLI

If neither of the commands `listen` and `yank` have been specified explicitly, *Helic* decides which one to start by the
presence of stdin data:

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

# Configuring Helic

The app reads the first existing one of these three configuration files:

* The file specified with `--config-file`
* `$XDG_CONFIG_DIR/helic.yaml` (most likely `~/.config/helic.yaml`)
* `/etc/helic.yaml`

An example config file looks like this:

```yaml
name: myhost
maxHistory: 1000
net:
  port: 10001
  hosts:
    - "remote1:1000"
    - "remote2:2000"
  timeout: 5
tmux:
  enable: true
  exe: /bin/tmux
```

For *NixOS*, the file `/etc/helic.yaml` is generated from module options:

```nix
{
  services.helic = {
    enable = true;
    name = "myhost";
    maxHistory = 1000;
    net = {
      port = 10001;
      hosts = ["remote1:1000" "remote2:2000"];
      timeout = 5;
    };
    tmux = {
      enable = true;
      package = old.tmux;
    };
  };
}
```

The meaning of these options is:

|Key|Default|Description|
|---|---|---|
|`name`|Host name|An identifier for the host, used for filtering duplicates.|
|`maxHistory`|100|The number of yanks that should be kept.|
|`net.port`|`9500`|The HTTP port the daemon listens to for both remote sync and `hel yank`.|
|`net.hosts`|`[]`|The addresses (with port) of the hosts to which this instance should broadcast yank events.|
|`net.timeout`|`300`|The timeout in milliseconds for requests to remote hosts.|
|`tmux.enable`|`true`|Whether to send events to *tmux*.|
|`tmux.package`|`pkgs.tmux`|Only for *NixOS*: The `nixpkgs` package used for the *tmux* executable.|
|`tmux.exe`|`tmux`|Only for YAML file: The path to the *tmux* executable|

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
