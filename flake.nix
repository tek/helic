{
  description = "Clipboard Manager";

  inputs.hix.url = github:tek/hix;
  inputs.polysemy-conc.url = github:tek/polysemy-conc;

  outputs = { hix, polysemy-conc, ... }:
  let
    gtkDeps = pkgs: with pkgs; [
      pkgconfig
      gobject-introspection
    ];

    overrides = { hackage, source, jailbreak, unbreak, transform_, pkgs, ... }:
    {
      exon = hackage "0.2.0.1" "0hs0xrh1v64l1n4zqx3rqfjdh6czxm7av85kj1awya9zxcfcy5cl";
      flatparse = unbreak;
      polysemy = hackage "1.7.1.0" "0qwli1kx3hk68hqsgw65mk81bx0djw1wlk17v8ggym7mf3lailyc";
      polysemy-chronos = hackage "0.2.0.1" "15j7x4jvigqji7gc6dr4fjlsv912sxzvfyb3jvll09p5j3rk4qc2";
      polysemy-conc = hackage "0.5.1.0" "1d61nr3bj1fhaljvrbxlwgfzwadavj5d62jqsp9h2q81fj3ibm5w";
      polysemy-http = hackage "0.5.0.0" "12kzq6910qwj7n1rwym3zibjm5cv7llfgk9iagcwd16vfysag6wp";
      polysemy-process = hackage "0.5.0.0" "1vjlim66hqbk4l16ip4qifz1qa93sfnwbcbaq15x6cwwxbsqdjr7";
      polysemy-log = hackage "0.4.0.0" "1r9f925884ay06w44r1fvp8bh5nm642g49np2vybz8hjiia8ghdx";
      polysemy-plugin = hackage "0.4.3.0" "1r7j1ffsd6z2q2fgpg78brl2gb0dg8r5ywfiwdrsjd2fxkinjcg1";
      helic = transform_ (d: d.overrideAttrs (old: { buildInputs = old.buildInputs ++ gtkDeps pkgs; }));
    };

    outputs = hix.flake {
      base = ./.;
      inherit overrides;
      deps = [polysemy-conc];
      packages.helic = ./packages/helic;
      ghci.extraArgs = ["-fplugin=Polysemy.Plugin"];
      shellConfig = { pkgs, ...}: {
        buildInputs = gtkDeps pkgs;
        haskellPackages = g: [g.hsc2hs];
      };
      compat = false;
      modify = _: outputs: rec {
        apps.hel = {
          type = "app";
          program = "${outputs.packages.helic}/bin/hel";
        };
        defaultApp = apps.hel;
      };
    };

  in outputs // { nixosModule = import ./ops/nix/module.nix outputs.packages; };
}
