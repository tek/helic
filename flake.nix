{
  description = "Clipboard Manager";

  inputs = {
    hix.url = github:tek/hix;
    incipit.url = github:tek/incipit;
  };

  outputs = { self, hix, incipit, ... }:
  let
    gtkDeps = pkgs: with pkgs; [
      pkgconfig
      gobject-introspection
    ];

    all = { transform_, pkgs, unbreak, hackage, source, ... }: {
      exon = hackage "0.3.0.0" "0jgpj8818nhwmb3271ixid38mx11illlslyi69s4m0ws138v6i18";
      flatparse = unbreak;
      helic = transform_ (d: d.overrideAttrs (old: { buildInputs = old.buildInputs ++ gtkDeps pkgs; }));
      polysemy-chronos = hackage "0.4.0.0" "0dckfpz7ww1f96wgbl3i05s1il55bqyyz4kix5lwqrx1zcn8dvvk";
      polysemy-http = hackage "0.7.0.0" "13p6b3c6g8p4x05gs304qg72i58dhdlxbir00izsrcd0228vyb3q";
      polysemy-process = hackage "0.8.0.1" "1djh95amqz1ncyiyb8digc9xn2hlny9xgqpv7myqk81syg1rfvw5";
    };

    dev = { hackage, ... }: {
      polysemy = hackage "1.7.1.0" "0qwli1kx3hk68hqsgw65mk81bx0djw1wlk17v8ggym7mf3lailyc";
      polysemy-plugin = hackage "0.4.3.0" "1r7j1ffsd6z2q2fgpg78brl2gb0dg8r5ywfiwdrsjd2fxkinjcg1";
    };

    outputs = hix.lib.flake ({ config, lib, ... }: {
      base = ./.;
      packages.helic = ./packages/helic;
      overrides = { inherit all dev; };
      depsFull = [incipit];
      devGhc.compiler = "ghc8107";
      compat.enable = false;
      ghci = {
        args = ["-fplugin=Polysemy.Plugin"];
        preludePackage = "incipit";
      };
      hpack.packages.helic = import ./ops/hpack.nix { inherit config; };
      hackage.versionFile = "ops/version.nix";
      ghcid = {
        commands = {
          listen = {
            script = ''
            :set args --verbose listen
            :load Helic.Cli
            import Helic.Cli (app)
            '';
            test = "app";
          };
        };
        shellConfig = {
          buildInputs = gtkDeps config.devGhc.pkgs;
          haskellPackages = g: [g.hsc2hs];
        };
      };
      output.amend = _: outputs: rec {
        apps.hel = {
          type = "app";
          program = "${outputs.packages.helic}/bin/hel";
        };
        defaultApp = apps.hel;
      };
    });

  in outputs // { nixosModule = import ./ops/module.nix self; };
}
