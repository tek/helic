{ config, ... }:
let

  paths.when = {
    condition = false;
    generated-other-modules = ["Paths_helic"];
  };

  base = {
    name = "base";
    version = ">= 4.12 && < 5";
    mixin = "hiding (Prelude)";
  };

  commonDeps = [
    base
    "incipit >= 0.1.0.3"
    "polysemy >= 1.6"
    "polysemy-plugin >= 0.4"
  ];

in {
  name = "helic";
  synopsis = "Clipboard Manager";
  version = import ./version.nix;
  github = "tek/helic";
  description = "See <https://hackage.haskell.org/package/helic/docs/Helic.html>";
  license = "BSD-2-Clause-Patent";
  license-file = "LICENSE";
  author = "Torsten Schmits";
  maintainer = "hackage@tryp.io";
  copyright = "2022 Torsten Schmits";
  category = "Clipboard";
  build-type = "Simple";
  extra-source-files = ["readme.md" "changelog.md"];

  library = paths // {
    source-dirs = "lib";
    dependencies = commonDeps ++ [
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

  executables.hel = paths // {
    main = "Main.hs";
    source-dirs = "app";
    dependencies = commonDeps ++ ["helic"];
    ghc-options = ["-threaded" "-rtsopts" "-with-rtsopts=-N"];
  };

  tests.helic-unit = paths // {
    main = "Main.hs";
    source-dirs = "test";
    ghc-options = ["-threaded" "-rtsopts" "-with-rtsopts=-N"];
    dependencies = commonDeps ++ [
      "exon"
      "helic"
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
    ];
  };

  ghc-options = [
    "-Wall"
    "-Wmissing-deriving-strategies"
    "-Wredundant-constraints"
    "-Wunused-packages"
    "-fplugin=Polysemy.Plugin"
  ];

  default-extensions = config.ghci.extensions;
}
