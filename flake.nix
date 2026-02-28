{

  description = "Clipboard Manager";

  inputs.hix.url = "git+https://git.tryp.io/tek/hix";

  outputs = {self, hix, ...}: let

    main = {util, ...}: {
      compiler = "ghc912";
      ghcVersions = ["ghc98" "ghc910" "ghc912"];
      gen-overrides.enable = true;
      compat.enable = false;

      packages.helic = {
        src = ./packages/helic;
        cabal = {
          meta = {
            synopsis = "Clipboard Manager";
            flags = {
              x11 = {
                manual = true;
                default = false;
                description = "Enable X11 clipboard integration (mutually exclusive with wayland)";
              };
              wayland = {
                manual = true;
                default = false;
                description = "Enable Wayland clipboard integratoin (mutually exclusive with x11)";
              };
            };
          };
        };

        library = {
          enable = true;
          paths = true;
          dependencies = [
            "aeson"
            "base64-bytestring"
            "chronos"
            "exon"
            "fast-logger"
            "gi-gdk"
            "gi-gio"
            "gi-glib"
            "gi-gtk"
            "haskell-gi-base"
            "hostname"
            "optparse-applicative"
            "path"
            "path-io"
            "polysemy-chronos"
            "polysemy-http"
            "polysemy-log"
            "polysemy-process"
            "polysemy-time"
            "servant"
            "servant-client"
            "servant-server"
            "table-layout"
            "terminal-size"
            "transformers"
            "typed-process"
            "wai-extra"
            "warp"
            "yaml"
          ];
          component = {
            when = [
              {
                condition = "false";
                generated-other-modules = ["Paths_helic"];
              }
              {
                condition = "flag(x11)";
                source-dirs = ["lib-x11"];
                cpp-options = ["-DX11_NATIVE"];
                exposed-modules = [
                  "Helic.Compat.Display"
                  "Helic.Data.GtkState"
                  "Helic.Data.XClipboardEvent"
                  "Helic.Effect.Gtk"
                  "Helic.Effect.GtkClipboard"
                  "Helic.Effect.GtkMain"
                  "Helic.Effect.XClipboard"
                  "Helic.Gtk"
                  "Helic.GtkClipboard"
                  "Helic.GtkMain"
                  "Helic.Interpreter.AgentX"
                  "Helic.Interpreter.Gtk"
                  "Helic.Interpreter.GtkClipboard"
                  "Helic.Interpreter.GtkMain"
                  "Helic.Interpreter.XClipboard"
                ];
              }
              {
                condition = "!flag(x11) && !flag(wayland)";
                source-dirs = ["lib-no-display"];
              }
              {
                condition = "flag(wayland)";
                source-dirs = ["lib-wayland"];
                dependencies = ["unix"];
                c-sources = [
                  "cbits/ext-data-control-v1-protocol.c"
                ];
                include-dirs = ["cbits"];
                extra-libraries = ["wayland-client"];
                cpp-options = ["-DWAYLAND_NATIVE"];
                exposed-modules = [
                  "Helic.Compat.Display"
                  "Helic.Interpreter.AgentWayland"
                  "Helic.Wayland.Ffi"
                  "Helic.Wayland.Monitor"
                  "Helic.Wayland.Protocol"
                ];
              }

            ];
          };
        };

        executables.hel = {
          source-dirs = "app";
        };

        test = {
          enable = true;
          paths = true;
          dependencies = [
            "aeson"
            "chronos"
            "containers"
            "exon"
            "network"
            "path"
            "polysemy-chronos"
            "polysemy-conc"
            "polysemy-http"
            "polysemy-log"
            "polysemy-test"
            "random"
            "tasty"
            "torsor"
            "zeugma"
          ];
          component = {
            when = [
              {
                condition = "false";
                generated-other-modules = ["Paths_helic"];
              }
              {
                condition = "flag(x11)";
                source-dirs = ["test-x11"];
              }
              {
                condition = "!flag(x11)";
                source-dirs = ["test-no-x11"];
              }
            ];
          };
        };

      };

      ghci = {
        setup.listen = ''
        :set args --verbose listen
        :load Helic.Cli
        import Helic.Cli (app)
        '';

        run.listen = "app";
      };

      commands.listen = {
        ghci = {
          enable = true;
          ghcid = true;
          runner = "listen";
          package = "helic";
          component = "app";
        };
        expose = true;
      };

      cabal = {
        license = "BSD-2-Clause-Patent";
        license-file = "LICENSE";
        author = "Torsten Schmits";
        language = "GHC2021";
        prelude = {
          enable = true;
          package = "prelate";
          module = "Prelate";
        };
        meta = {
          maintainer = "hackage@tryp.io";
          category = "Clipboard";
          github = "tek/helic";
          extra-source-files = ["readme.md" "changelog.md"];
        };
        ghc-options = ["-fplugin=Polysemy.Plugin"];
        dependencies = [
          "polysemy"
          "polysemy-plugin"
        ];
      };

      package-sets.ghc912 = {
        compiler = "ghc912";
        overrides = {hackage, jailbreak, unbreak, ...}: {
          bytebuild = jailbreak;
          chronos = jailbreak;
          incipit = jailbreak;
          incipit-base = jailbreak;
          incipit-core = jailbreak;
          polysemy-chronos = jailbreak (hackage "0.7.0.1" "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k");
          polysemy-conc = jailbreak;
          polysemy-http = jailbreak (hackage "0.13.1.0" "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq");
          polysemy-log = jailbreak;
          polysemy-process = jailbreak unbreak;
          polysemy-resume = jailbreak;
          polysemy-test = jailbreak unbreak;
          polysemy-time = jailbreak;
          prelate = jailbreak (hackage "0.8.0.0" "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg");
          zeugma = jailbreak;
        };
      };

      managed = {
        enable = true;
        latest.compiler = "ghc912";
        lower.enable = true;
        latest.envs.solverOverrides = {buildInputs, enable, ...}: {
          helic = enable "wayland";
          gi-gtk = buildInputs (p: [p.gtk4.dev p.pkg-config]);
          gi-gdk = buildInputs (p: [p.gtk4.dev p.pkg-config]);
        };
      };

      envs = {

        latest.overrides = {buildInputs, ...}: {
          gi-gtk = buildInputs (p: [p.gtk4.dev]);
          gi-gdk = buildInputs (p: [p.gtk4.dev]);
        };

        dev = {
          package-set.extends = "ghc912";
          libraryPath = pkgs: [pkgs.wayland];
          overrides = {self, buildInputs, enable, ...}: {
            helic-x11 = enable "x11" self.helic;
            helic-wayland = enable "wayland" (buildInputs (p: [p.wayland.dev])) self.helic;
          };
        };

        ghc98.overrides = {jailbreak, unbreak, ...}: {
          chronos = jailbreak;
          polysemy-http = jailbreak unbreak;
        };

        ghc910.overrides = {jailbreak, unbreak, ...}: {
          polysemy-http = jailbreak unbreak;
        };

        ghc912.package-set.extends = "ghc912";

        x11 = {
          package-set.extends = "ghc912";
          expose = true;
          overrides = {buildInputs, enable, ...}: {
            helic = enable "x11" (buildInputs (p: [p.gtk4.dev]));
          };
        };

      };

      output.expose.static = false;
      output.extraPackages = ["helic-wayland" "helic-x11"];

      internal.hixCli.dev = true;

    };

    system-test = import ./ops/system-test.nix self;

  in
  hix.lib.pro [main system-test]
  //
  { nixosModules.default = import ./ops/module.nix self; };

}
