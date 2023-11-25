{
  description = "Clipboard Manager";

  inputs = {
    hix.url = "git+https://git.tryp.io/tek/hix";
    prelate.url = "git+https://git.tryp.io/tek/prelate";
  };

  outputs = { self, hix, prelate, ... }: hix.lib.pro ({config, ...}: {
    depsFull = [prelate];
    hackage.versionFile = "ops/version.nix";
    compat.enable = false;

    cabal = {
      license = "BSD-2-Clause-Patent";
      license-file = "LICENSE";
      author = "Torsten Schmits";
      prelude = {
        enable = true;
        package = {
          name = "prelate";
          version = ">=0.5 && <0.8";
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
        "polysemy ^>=1.9"
        "polysemy-plugin ^>=0.4"
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
          "chronos ^>=1.1.1"
          "exon >=1.4 && <1.6"
          "fast-logger >=3.1 && <3.3"
          "gi-gdk ^>=3"
          "gi-glib ^>=2"
          "gi-gtk ^>=3"
          "hostname ^>=1"
          "optparse-applicative ^>=0.17"
          "path ^>=0.9"
          "path-io >=1.7 && <1.9"
          "polysemy-chronos ^>=0.6"
          "polysemy-conc >=0.12 && <0.14"
          "polysemy-http >=0.11 && <0.14"
          "polysemy-log >=0.9 && <0.11"
          "polysemy-process >=0.12 && <0.14"
          "polysemy-time ^>=0.6"
          "servant ^>=0.19"
          "servant-client ^>=0.19"
          "servant-server ^>=0.19"
          "table-layout ^>=0.9"
          "terminal-size ^>=0.3.2.1"
          "transformers"
          "typed-process ^>=0.2.6"
          "wai-extra ^>=3.1"
          "warp ^>=3.3"
          "yaml ^>=0.11"
        ];
      };

      executables.hel = {
        source-dirs = "app";
      };

      test = {
        enable = true;
        dependencies = [
          "chronos ^>=1.1.1"
          "containers"
          "exon >=1.4 && <1.6"
          "network ^>=3.1"
          "path ^>=0.9"
          "polysemy-chronos ^>=0.6"
          "polysemy-conc >=0.12 && <0.14"
          "polysemy-http >=0.11 && <0.14"
          "polysemy-log >=0.9 && <0.11"
          "polysemy-test >=0.7 && <0.10"
          "random ^>=1.2"
          "tasty ^>=1.4"
          "torsor ^>=0.1"
          "zeugma >=0.7 && <0.10"
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

  }) // { nixosModules.default = import ./ops/module.nix self; };
}
