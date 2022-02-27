{
  description = "Clipboard Manager";

  inputs = {
    hix.url = github:tek/hix;
    incipit.url = github:tek/incipit;
    polysemy-resume.url = github:tek/polysemy-resume;
    polysemy-conc.url = github:tek/polysemy-conc;
  };

  outputs = { self, hix, incipit, polysemy-conc, polysemy-resume, ... }:
  let
    inherit (incipit.inputs.polysemy-conc.inputs) polysemy-time;

    gtkDeps = pkgs: with pkgs; [
      pkgconfig
      gobject-introspection
    ];

    all = { transform_, pkgs, unbreak, hackage, source, ... }: {
      exon = hackage "0.3.0.0" "0jgpj8818nhwmb3271ixid38mx11illlslyi69s4m0ws138v6i18";
      flatparse = unbreak;
      helic = transform_ (d: d.overrideAttrs (old: { buildInputs = old.buildInputs ++ gtkDeps pkgs; }));
      polysemy-chronos = source.package polysemy-time "chronos";
      polysemy-http = hackage "0.6.0.0" "02jr278vyqa3sky22z2ywzkd6g339acvlwjq4b6svm7lfpw7nfab";
      polysemy-resume = source.package polysemy-resume "resume";
      polysemy-conc = source.package polysemy-conc "conc";
      polysemy-process = source.package polysemy-conc "process";
    };

    ghc902 = { hackage, ... }: {
    };

    dev = { hackage, ... }: {
      polysemy = hackage "1.7.1.0" "0qwli1kx3hk68hqsgw65mk81bx0djw1wlk17v8ggym7mf3lailyc";
      polysemy-plugin = hackage "0.4.3.0" "1r7j1ffsd6z2q2fgpg78brl2gb0dg8r5ywfiwdrsjd2fxkinjcg1";
    };

    outputs = hix.lib.flake ({ config, ... }: {
      base = ./.;
      packages.helic = ./packages/helic;
      overrides = { inherit all ghc902 dev; };
      deps = [incipit polysemy-conc];
      devGhc.compiler = "ghc8107";
      compat.enable = false;
      ghci = {
        args = ["-fplugin=Polysemy.Plugin"];
        preludePackage = "incipit";
      };
      hackage.versionFile = "ops/hpack/shared/meta.yaml";
      ghcid.shellConfig = {
        buildInputs = gtkDeps config.devGhc.pkgs;
        haskellPackages = g: [g.hsc2hs];
      };
      output.amend = _: outputs: rec {
        apps.hel = {
          type = "app";
          program = "${outputs.packages.helic}/bin/hel";
        };
        defaultApp = apps.hel;
      };
    });

  in outputs // { nixosModule = import ./ops/nix/module.nix self; };
}
