{

  description = "Clipboard Manager";

  inputs.hix.url = "git+https://git.tryp.io/tek/hix";

  outputs = {self, hix, ...}: let

    main = {util, ...}: {
      ghcVersions = ["ghc94" "ghc96" "ghc98"];
      hackage.versionFile = "ops/version.nix";
      gen-overrides.enable = true;
      compat.enable = false;

      packages.helic = {
        src = ./packages/helic;
        cabal = {
          meta.synopsis = "Clipboard Manager";
        };

        library = {
          enable = true;
          dependencies = [
            "chronos"
            "exon"
            "fast-logger"
            "gi-gdk"
            "gi-glib"
            "gi-gtk"
            "hostname"
            "optparse-applicative"
            "path"
            "path-io"
            "polysemy-chronos"
            "polysemy-conc"
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
        };

        executables.hel = {
          source-dirs = "app";
        };

        test = {
          enable = true;
          dependencies = [
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

      managed = {
        enable = true;
        latest.compiler = "ghc910";
        lower.enable = true;
      };

      overrides = {hackage, jailbreak, unbreak, ...}: {
        incipit = jailbreak;
        polysemy-conc = jailbreak;
        polysemy-http = hackage "0.13.1.0" "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
        polysemy-log = jailbreak;
        polysemy-process = unbreak;
        polysemy-test = jailbreak unbreak;
        prelate = hackage "0.8.0.0" "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
      };

      output.expose.static = false;

      internal.hixCli.dev = true;

    };

    system-test = import ./ops/system-test.nix self;

  in
  hix.lib.pro [main system-test]
  //
  { nixosModules.default = import ./ops/module.nix self; };

}
