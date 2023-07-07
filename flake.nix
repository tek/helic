{
  description = "Clipboard Manager";

  inputs = {
    hix.url = "git+https://git.tryp.io/tek/hix";
    prelate.url = "git+https://git.tryp.io/tek/prelate";
  };

  outputs = { self, hix, prelate, ... }: hix.lib.pro ({config, ...}: {
    depsFull = [prelate];

    cabal = {
      license = "BSD-2-Clause-Patent";
      license-file = "LICENSE";
      author = "Torsten Schmits";
      prelude = {
        enable = true;
        package = {
          name = "prelate";
          version = "^>= 0.5";
        };
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
        "polysemy ^>= 1.9"
        "polysemy-plugin ^>= 0.4"
      ];
    };

    packages.helic = {
      src = ./packages/helic;
      cabal = {
        meta.synopsis = "Clipboard Manager";
      };

      library = {
        enable = true;
        dependencies = [
          "aeson >= 1.5"
          "chronos >= 1.1.1"
          "exon >= 0.3"
          "gi-gdk >= 3"
          "gi-glib >= 2"
          "gi-gtk >= 3"
          "fast-logger >= 3"
          "hostname >= 1"
          "http-client >= 0.5.14"
          "http-client-tls >= 0.3.1"
          "optparse-applicative >= 0.16"
          "path >= 0.8"
          "path-io >= 1.6"
          "polysemy-conc >= 0.6"
          "polysemy-chronos >= 0.3"
          "polysemy-http >= 0.6"
          "polysemy-log >= 0.5"
          "polysemy-process >= 0.6"
          "polysemy-time >= 0.3"
          "servant >= 0.18"
          "servant-client >= 0.18"
          "servant-client-core >= 0.18"
          "servant-server >= 0.18"
          "table-layout >= 0.9"
          "template-haskell"
          "terminal-size >= 0.3.2.1"
          "transformers"
          "typed-process >= 0.2.6"
          "wai-extra >= 3.1"
          "warp >= 3.3"
          "unix"
          "yaml >= 0.11"
        ];
      };

      executables.hel = {
        source-dirs = "app";
      };

      test = {
        enable = true;
        dependencies = [
          "exon"
          "chronos"
          "containers"
          "path"
          "polysemy-chronos"
          "polysemy-conc"
          "polysemy-log"
          "polysemy-test"
          "polysemy-time"
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

  }) // { nixosModule = import ./ops/module.nix self; };
}
