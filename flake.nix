{

  description = "Clipboard Manager";

  inputs = {
    hix.url = "git+https://git.tryp.io/tek/hix";
    prelate.url = "git+https://git.tryp.io/tek/prelate";
  };

  outputs = {self, hix, prelate, ...}: let

    jailbreaks910 = {hackage, jailbreak, unbreak, ...}: {
      bytebuild = jailbreak;
      chronos = jailbreak;
      incipit = jailbreak;
      incipit-base = jailbreak;
      incipit-core = jailbreak;
      polysemy-chronos = jailbreak;
      polysemy-conc = jailbreak;
      polysemy-log = jailbreak;
      polysemy-process = jailbreak unbreak;
      polysemy-resume = jailbreak;
      polysemy-test = jailbreak unbreak;
      polysemy-time = jailbreak;
      zeugma = jailbreak;
    };

    overrides910 = api@{hackage, jailbreak, unbreak, ...}: jailbreaks910 api // {
      byte-order = jailbreak;
      exon = hackage "1.7.1.0" "16vf84nnpivxw4a46g7jsy2hg4lpla7grkv3gp8nd69zlv43777l";
      polysemy-http = hackage "0.13.1.0" "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
      prelate = hackage "0.8.0.0" "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    };

    main = {util, ...}: {
      depsFull = [prelate];
      ghcVersions = ["ghc94" "ghc96" "ghc98" "ghc910"];
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
        envs.solverOverrides = overrides910;
        envs.verbatim.globalOverrides = true;
      };

      envs.latest.overrides = jailbreaks910;

      overrides = {hackage, ...}: {
        polysemy-http = hackage "0.13.1.0" "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
      };

      output.expose.static = false;

    };

    system-test = import ./ops/system-test.nix self;

  in
  hix.lib.pro [main system-test]
  //
  { nixosModules.default = import ./ops/module.nix self; };

}
