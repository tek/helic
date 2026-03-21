{
dev-extends-ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
discovery-test-extends-ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
ghc910 = {
};
ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
ghc98 = {
};
hix-build-tools = {
};
hls = {
};
latest = {
  base-compat = {
  meta = {
    sha256 = "1bmmqclp2cphxyk06sh453n271dxrlw22c1946qflhp5hz1g9rz5";
    url = "https://hackage.haskell.org";
    ver = "0.15.0";
  };
  drv = { mkDerivation, base, ghc-prim, lib }:
mkDerivation {
  pname = "base-compat";
  version = "0.15.0";
  src = /nix/store/i5i5bkdgvzf77dbd9a2iaq2nclwnfgnz-source;
  libraryHaskellDepends = [ base ghc-prim ];
  description = "A compatibility layer for base";
  license = lib.licenses.mit;
}
;
}
;
  base16 = {
  meta = {
    sha256 = "0rhjm2b4mpp6lr2cgppsls2z1ipfx6rc681cpj88pvf5p6jf5fd4";
    url = "https://hackage.haskell.org";
    ver = "1.0";
  };
  drv = { mkDerivation, base, base16-bytestring, bytestring, criterion
, deepseq, lib, primitive, QuickCheck, random-bytestring, tasty
, tasty-hunit, tasty-quickcheck, text, text-short
}:
mkDerivation {
  pname = "base16";
  version = "1.0";
  src = /nix/store/4panfmmj73f12h99422ni2v4lhq58jg4-source;
  libraryHaskellDepends = [
    base bytestring deepseq primitive text text-short
  ];
  testHaskellDepends = [
    base base16-bytestring bytestring QuickCheck random-bytestring
    tasty tasty-hunit tasty-quickcheck text text-short
  ];
  benchmarkHaskellDepends = [
    base base16-bytestring bytestring criterion deepseq
    random-bytestring text
  ];
  homepage = "https://github.com/emilypi/base16";
  description = "Fast RFC 4648-compliant Base16 encoding";
  license = lib.licenses.bsd3;
}
;
}
;
  base64 = {
  meta = {
    sha256 = "0m9h8r88jxidjkgg2h3ggv0qsqxsrmii4injnhsbq1vrcr0jmd30";
    url = "https://hackage.haskell.org";
    ver = "1.0";
  };
  drv = { mkDerivation, base, base64-bytestring, bytestring, criterion
, deepseq, lib, QuickCheck, random-bytestring, tasty, tasty-hunit
, tasty-quickcheck, text, text-short
}:
mkDerivation {
  pname = "base64";
  version = "1.0";
  src = /nix/store/63kjy8cxx6rl26v04byymi7h1yi6k3v6-source;
  libraryHaskellDepends = [
    base bytestring deepseq text text-short
  ];
  testHaskellDepends = [
    base base64-bytestring bytestring QuickCheck random-bytestring
    tasty tasty-hunit tasty-quickcheck text text-short
  ];
  benchmarkHaskellDepends = [
    base base64-bytestring bytestring criterion deepseq
    random-bytestring text
  ];
  homepage = "https://github.com/emilypi/base64";
  description = "A modern Base64 library";
  license = lib.licenses.bsd3;
}
;
}
;
  bytebuild = {
  meta = {
    sha256 = "0r14dmwywpr91qrnck3lb269hn8nmfmfwww11yglggn6fmjv6ks7";
    url = "https://hackage.haskell.org";
    ver = "0.3.16.2";
  };
  drv = { mkDerivation, base, byteslice, bytestring, gauge
, haskell-src-meta, integer-logarithms, lib, natural-arithmetic
, primitive, primitive-offset, QuickCheck, quickcheck-instances
, run-st, tasty, tasty-hunit, tasty-quickcheck, template-haskell
, text, text-short, wide-word, zigzag
}:
mkDerivation {
  pname = "bytebuild";
  version = "0.3.16.2";
  src = /nix/store/ix1p89jz53pyk7jr4xsli40z05hx31jr-source;
  libraryHaskellDepends = [
    base byteslice bytestring haskell-src-meta integer-logarithms
    natural-arithmetic primitive primitive-offset run-st
    template-haskell text text-short wide-word zigzag
  ];
  testHaskellDepends = [
    base byteslice bytestring natural-arithmetic primitive QuickCheck
    quickcheck-instances tasty tasty-hunit tasty-quickcheck text
    text-short wide-word
  ];
  benchmarkHaskellDepends = [
    base byteslice gauge natural-arithmetic primitive text-short
  ];
  homepage = "https://github.com/byteverse/bytebuild";
  description = "Build byte arrays";
  license = lib.licenses.bsd3;
}
;
}
;
  cabal-doctest = {
  meta = {
    sha256 = "152rqpicqpvigjpy4rf1kjlwny1c7ys1r0r123wdjafvv1igflii";
    url = "https://hackage.haskell.org";
    ver = "1.0.11";
  };
  drv = { mkDerivation, base, Cabal, directory, filepath, lib }:
mkDerivation {
  pname = "cabal-doctest";
  version = "1.0.11";
  src = /nix/store/jq5gnm6hwmylv7wndgd4v11z6hv30y0g-source;
  libraryHaskellDepends = [ base Cabal directory filepath ];
  homepage = "https://github.com/ulidtko/cabal-doctest";
  description = "A Setup.hs helper for running doctests";
  license = lib.licenses.bsd3;
}
;
}
;
  chronos = {
  meta = {
    sha256 = "0kazqi6adm7ph19gm830cm44jy7zqiwib53gk495zghiz0rinhsr";
    url = "https://hackage.haskell.org";
    ver = "1.1.7.0";
  };
  drv = { mkDerivation, aeson, attoparsec, base, bytebuild, byteslice
, bytesmith, bytestring, criterion, deepseq, hashable, HUnit, lib
, natural-arithmetic, old-locale, primitive, QuickCheck
, test-framework, test-framework-hunit, test-framework-quickcheck2
, text, text-short, thyme, time, torsor, vector
}:
mkDerivation {
  pname = "chronos";
  version = "1.1.7.0";
  src = /nix/store/8q5xhxw250c994vjcqhm0iz5d4w2mhbc-source;
  libraryHaskellDepends = [
    aeson attoparsec base bytebuild byteslice bytesmith bytestring
    deepseq hashable natural-arithmetic primitive text text-short
    torsor vector
  ];
  testHaskellDepends = [
    aeson attoparsec base bytestring HUnit QuickCheck test-framework
    test-framework-hunit test-framework-quickcheck2 text torsor
  ];
  benchmarkHaskellDepends = [
    attoparsec base bytestring criterion deepseq old-locale QuickCheck
    text text-short thyme time
  ];
  homepage = "https://github.com/byteverse/chronos";
  description = "A high-performance time library";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-asn1-encoding = {
  meta = {
    sha256 = "0h4cxk9yz2xgmx0kl3gg9lixhnhvxqk85gvkwldp0mlfm3mgccvm";
    url = "https://hackage.haskell.org";
    ver = "0.10.0";
  };
  drv = { mkDerivation, base, bytestring, crypton-asn1-types, lib, tasty
, tasty-quickcheck, time-hourglass
}:
mkDerivation {
  pname = "crypton-asn1-encoding";
  version = "0.10.0";
  src = /nix/store/3jdjbk8fmcwf3h6jvj6fh3zljk2pjk7g-source;
  libraryHaskellDepends = [
    base bytestring crypton-asn1-types time-hourglass
  ];
  testHaskellDepends = [
    base bytestring crypton-asn1-types tasty tasty-quickcheck
    time-hourglass
  ];
  homepage = "https://github.com/mpilgrem/crypton-asn1";
  description = "ASN.1 data (raw, BER or DER) readers and writers";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-asn1-parse = {
  meta = {
    sha256 = "0dsyslbb9a3f6wj0na52qc7iimjs9xljhi6wjfch61nb9m33l1kb";
    url = "https://hackage.haskell.org";
    ver = "0.10.0";
  };
  drv = { mkDerivation, base, bytestring, crypton-asn1-types, lib }:
mkDerivation {
  pname = "crypton-asn1-parse";
  version = "0.10.0";
  src = /nix/store/cb3kc94gqjn5dalrynzkc71pgqz34jkl-source;
  libraryHaskellDepends = [ base bytestring crypton-asn1-types ];
  homepage = "https://github.com/mpilgrem/crypton-asn1";
  description = "A monadic parser combinator for a ASN.1 stream.";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-asn1-types = {
  meta = {
    sha256 = "01zvf9vn5a0jyaq5l6mmzv7ya35sxjrk10k06rmi31x128sfqs7s";
    url = "https://hackage.haskell.org";
    ver = "0.4.1";
  };
  drv = { mkDerivation, base, base16, bytestring, lib, time-hourglass }:
mkDerivation {
  pname = "crypton-asn1-types";
  version = "0.4.1";
  src = /nix/store/4sfp0div3z38kr9k7i316sq8cnp6rn3p-source;
  libraryHaskellDepends = [ base base16 bytestring time-hourglass ];
  homepage = "http://github.com/mpilgrem/crypton-asn1";
  description = "ASN.1 types";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-connection = {
  meta = {
    sha256 = "1l5yr5nck4vyi55pyc7j1zarfcs196gbxjlwljs7s7v2r3h43jcc";
    url = "https://hackage.haskell.org";
    ver = "0.4.5";
  };
  drv = { mkDerivation, base, bytestring, containers, crypton-socks
, crypton-x509-store, crypton-x509-system, data-default, lib
, network, tls
}:
mkDerivation {
  pname = "crypton-connection";
  version = "0.4.5";
  src = /nix/store/19svh548rwpqfdj2wqjwb2d7vc5jnr8z-source;
  libraryHaskellDepends = [
    base bytestring containers crypton-socks crypton-x509-store
    crypton-x509-system data-default network tls
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-connection";
  description = "Simple and easy network connection API";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-pem = {
  meta = {
    sha256 = "1bvcl2brlgqbb1kmjzlfspmm47n1g441qgsmyhz9ql3zlcz1s524";
    url = "https://hackage.haskell.org";
    ver = "0.3.0";
  };
  drv = { mkDerivation, base, base64, bytestring, deepseq, HUnit, lib
, QuickCheck, test-framework, test-framework-hunit
, test-framework-quickcheck2, text
}:
mkDerivation {
  pname = "crypton-pem";
  version = "0.3.0";
  src = /nix/store/sgn1akgqiiyq4s4w6wm02fi2w8bvi7ii-source;
  libraryHaskellDepends = [ base base64 bytestring deepseq text ];
  testHaskellDepends = [
    base bytestring HUnit QuickCheck test-framework
    test-framework-hunit test-framework-quickcheck2
  ];
  homepage = "http://github.com/mpilgrem/crypton-pem";
  description = "Privacy Enhanced Mail (PEM) file format reader and writer";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-x509 = {
  meta = {
    sha256 = "0f35689cbxdv25b0xjlla4hmxjxjraiwc6v89y12nl3nxqx3q5f3";
    url = "https://hackage.haskell.org";
    ver = "1.8.0";
  };
  drv = { mkDerivation, base, bytestring, containers, crypton
, crypton-asn1-encoding, crypton-asn1-parse, crypton-asn1-types
, crypton-pem, lib, memory, mtl, tasty, tasty-quickcheck
, time-hourglass, transformers
}:
mkDerivation {
  pname = "crypton-x509";
  version = "1.8.0";
  src = /nix/store/42j4g7hiyrixw85p2y35vcx7yw0nr0xq-source;
  libraryHaskellDepends = [
    base bytestring containers crypton crypton-asn1-encoding
    crypton-asn1-parse crypton-asn1-types crypton-pem memory
    time-hourglass transformers
  ];
  testHaskellDepends = [
    base bytestring crypton crypton-asn1-types mtl tasty
    tasty-quickcheck time-hourglass
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
  description = "X509 reader and writer";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-x509-store = {
  meta = {
    sha256 = "1irrrgm6jmw0irjgwk877smg381wlv72rcgacqrp09dplzjcg82k";
    url = "https://hackage.haskell.org";
    ver = "1.8.0";
  };
  drv = { mkDerivation, base, bytestring, containers, crypton
, crypton-asn1-encoding, crypton-asn1-types, crypton-pem
, crypton-x509, directory, filepath, lib, mtl, tasty, tasty-hunit
, unix
}:
mkDerivation {
  pname = "crypton-x509-store";
  version = "1.8.0";
  src = /nix/store/kavc11csyrxdfnqsgg79q5kj5mlr3c9m-source;
  libraryHaskellDepends = [
    base bytestring containers crypton crypton-asn1-encoding
    crypton-asn1-types crypton-pem crypton-x509 directory filepath mtl
    unix
  ];
  testHaskellDepends = [
    base bytestring crypton-x509 tasty tasty-hunit
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
  description = "X.509 collection accessing and storing methods";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-x509-system = {
  meta = {
    sha256 = "0d0rrjm8xxcp3vkxxskgzs9wi8b09532v6gpsmfyagnk170n2hxr";
    url = "https://hackage.haskell.org";
    ver = "1.8.0";
  };
  drv = { mkDerivation, base, bytestring, containers, crypton-pem
, crypton-x509, crypton-x509-store, directory, filepath, lib, mtl
, process
}:
mkDerivation {
  pname = "crypton-x509-system";
  version = "1.8.0";
  src = /nix/store/a023pr9yq4c3j011jcazssd2i1aj0lfj-source;
  libraryHaskellDepends = [
    base bytestring containers crypton-pem crypton-x509
    crypton-x509-store directory filepath mtl process
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
  description = "Handle per-operating-system X.509 accessors and storage";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-x509-validation = {
  meta = {
    sha256 = "1dxvbkxwlk6qhg0id65fwssda04pn9y7glq7jpakqlww8d6nl90b";
    url = "https://hackage.haskell.org";
    ver = "1.8.0";
  };
  drv = { mkDerivation, base, bytestring, containers, crypton
, crypton-asn1-encoding, crypton-asn1-types, crypton-pem
, crypton-x509, crypton-x509-store, data-default, iproute, lib
, memory, mtl, tasty, tasty-hunit, time-hourglass
}:
mkDerivation {
  pname = "crypton-x509-validation";
  version = "1.8.0";
  src = /nix/store/k2rsrn79l69qc8wlahz6dp28bk8b33f3-source;
  libraryHaskellDepends = [
    base bytestring containers crypton crypton-asn1-encoding
    crypton-asn1-types crypton-pem crypton-x509 crypton-x509-store
    data-default iproute memory mtl time-hourglass
  ];
  testHaskellDepends = [
    base bytestring crypton crypton-asn1-encoding crypton-asn1-types
    crypton-x509 crypton-x509-store data-default memory tasty
    tasty-hunit time-hourglass
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
  description = "X.509 Certificate and CRL validation";
  license = lib.licenses.bsd3;
}
;
}
;
  ech-config = {
  meta = {
    sha256 = "0sxxxd9rlc3x14mgh92ic8s9hjncf38f9s7p3ic284mvnzj0l3s2";
    url = "https://hackage.haskell.org";
    ver = "0.0.1";
  };
  drv = { mkDerivation, base, base16-bytestring, bytestring, filepath, lib
, network-byte-order
}:
mkDerivation {
  pname = "ech-config";
  version = "0.0.1";
  src = /nix/store/3wgqsr9lf46xpizkjd7s95bp03fjmiib-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base base16-bytestring bytestring filepath network-byte-order
  ];
  description = "Config for TLS Encrypted Client Hello";
  license = lib.licenses.bsd3;
}
;
}
;
  exon = {
  meta = {
    sha256 = "0hg271cvjqm4ps75qpnirq9nvjwpwb03mcbn1a364jrysrj6bg3b";
    url = "https://hackage.haskell.org";
    ver = "1.7.2.0";
  };
  drv = { mkDerivation, base, criterion, ghc, hedgehog, incipit-base, lib
, parsec, tasty, tasty-hedgehog, template-haskell
}:
mkDerivation {
  pname = "exon";
  version = "1.7.2.0";
  src = /nix/store/scamv6qgdfzmlicp6wsk76vg2ls6kznd-source;
  libraryHaskellDepends = [
    base ghc incipit-base parsec template-haskell
  ];
  testHaskellDepends = [
    base hedgehog incipit-base tasty tasty-hedgehog template-haskell
  ];
  benchmarkHaskellDepends = [ base criterion incipit-base ];
  homepage = "https://github.com/tek/exon#readme";
  description = "Customizable quasiquote interpolation";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  hpke = {
  meta = {
    sha256 = "0vyny5gqw8rk0s75088ggs3q78fgmas9mnxnwjpny4h9nw6dysr9";
    url = "https://hackage.haskell.org";
    ver = "0.0.0";
  };
  drv = { mkDerivation, base, base16-bytestring, bytestring, crypton, hspec
, hspec-discover, lib, memory, QuickCheck
}:
mkDerivation {
  pname = "hpke";
  version = "0.0.0";
  src = /nix/store/j6d3w4z0zlmxa8dh7408mgych17x7v6c-source;
  libraryHaskellDepends = [
    base base16-bytestring bytestring crypton memory
  ];
  testHaskellDepends = [
    base base16-bytestring bytestring hspec QuickCheck
  ];
  testToolDepends = [ hspec-discover ];
  description = "Hybrid Public Key Encryption";
  license = lib.licenses.bsd3;
}
;
}
;
  http-client = {
  meta = {
    sha256 = "1qciglcaik1a96flj07fhqx2h692kgcv63hinffr35ka22wrg3i9";
    url = "https://hackage.haskell.org";
    ver = "0.7.19";
  };
  drv = { mkDerivation, array, async, base, base64-bytestring
, blaze-builder, bytestring, case-insensitive, containers, cookie
, deepseq, directory, exceptions, filepath, ghc-prim, hspec
, hspec-discover, http-types, iproute, lib, mime-types
, monad-control, network, network-uri, random, stm
, streaming-commons, text, time, transformers, zlib
}:
mkDerivation {
  pname = "http-client";
  version = "0.7.19";
  src = /nix/store/62hi01g26a69zq8zj61cx5xhbg3fdy1g-source;
  libraryHaskellDepends = [
    array async base base64-bytestring blaze-builder bytestring
    case-insensitive containers cookie deepseq exceptions filepath
    ghc-prim http-types iproute mime-types network network-uri random
    stm streaming-commons text time transformers
  ];
  testHaskellDepends = [
    async base blaze-builder bytestring case-insensitive containers
    cookie deepseq directory hspec http-types monad-control network
    network-uri streaming-commons text time transformers zlib
  ];
  testToolDepends = [ hspec-discover ];
  doCheck = false;
  homepage = "https://github.com/snoyberg/http-client";
  description = "An HTTP client engine";
  license = lib.licenses.mit;
}
;
}
;
  http-client-tls = {
  meta = {
    sha256 = "1f8br94l5kywpsfvpmw54b1v6nx1yapslzrwiswsf6vf8kwfjjzg";
    url = "https://hackage.haskell.org";
    ver = "0.3.6.4";
  };
  drv = { mkDerivation, base, bytestring, case-insensitive, containers
, crypton, crypton-connection, data-default, exceptions, gauge
, hspec, http-client, http-types, lib, memory, network, network-uri
, text, tls, transformers
}:
mkDerivation {
  pname = "http-client-tls";
  version = "0.3.6.4";
  src = /nix/store/8r1b74si7yr0bxiw2wp65ypxzrdsmsxk-source;
  libraryHaskellDepends = [
    base bytestring case-insensitive containers crypton
    crypton-connection data-default exceptions http-client http-types
    memory network network-uri text tls transformers
  ];
  testHaskellDepends = [
    base crypton-connection hspec http-client http-types
  ];
  benchmarkHaskellDepends = [ base gauge http-client ];
  doCheck = false;
  homepage = "https://github.com/snoyberg/http-client";
  description = "http-client backend using the connection package and tls library";
  license = lib.licenses.mit;
}
;
}
;
  http-semantics = {
  meta = {
    sha256 = "0p9qb38z9khk91cy78lv8f66693xyxn9yy87mnwwpghaa7kk67df";
    url = "https://hackage.haskell.org";
    ver = "0.4.0";
  };
  drv = { mkDerivation, array, base, bytestring, case-insensitive
, http-types, lib, network, network-byte-order, time-manager
, utf8-string
}:
mkDerivation {
  pname = "http-semantics";
  version = "0.4.0";
  src = /nix/store/35kaqbzwiimp8g5wrmr0kcb3sbzxrg6a-source;
  libraryHaskellDepends = [
    array base bytestring case-insensitive http-types network
    network-byte-order time-manager utf8-string
  ];
  homepage = "https://github.com/kazu-yamamoto/http-semantics";
  description = "HTTP semantics library";
  license = lib.licenses.bsd3;
}
;
}
;
  http2 = {
  meta = {
    sha256 = "1wa88jb5hk64g4v320jsj4sfldcpwkjjvpxvxh30yvdmvraidq9x";
    url = "https://hackage.haskell.org";
    ver = "5.4.0";
  };
  drv = { mkDerivation, aeson, aeson-pretty, array, async, base
, base16-bytestring, bytestring, case-insensitive, containers
, criterion, crypton, directory, filepath, Glob, hspec
, hspec-discover, http-semantics, http-types, iproute, lib, network
, network-byte-order, network-control, network-run, random, stm
, text, time-manager, typed-process, unix-time
, unordered-containers, utf8-string, vector
}:
mkDerivation {
  pname = "http2";
  version = "5.4.0";
  src = /nix/store/4pzq6yz3cn52w31fqnd99jx3fdxhrmrl-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    array async base bytestring case-insensitive containers
    http-semantics http-types iproute network network-byte-order
    network-control stm time-manager unix-time utf8-string
  ];
  testHaskellDepends = [
    aeson aeson-pretty async base base16-bytestring bytestring crypton
    directory filepath Glob hspec http-semantics http-types network
    network-byte-order network-run random text typed-process
    unordered-containers vector
  ];
  testToolDepends = [ hspec-discover ];
  benchmarkHaskellDepends = [
    array base bytestring case-insensitive containers criterion
    network-byte-order stm
  ];
  homepage = "https://github.com/kazu-yamamoto/http2";
  description = "HTTP/2 library";
  license = lib.licenses.bsd3;
}
;
}
;
  incipit = {
  meta = {
    sha256 = "0vr1balwy6v9l15pjlyy372w0scli1wcl6395jqdkjncqm3ymdin";
    url = "https://hackage.haskell.org";
    ver = "0.10.0.1";
  };
  drv = { mkDerivation, base, incipit-core, lib, polysemy-conc
, polysemy-log, polysemy-resume, polysemy-time
}:
mkDerivation {
  pname = "incipit";
  version = "0.10.0.1";
  src = /nix/store/y9k0f8365246qsr7ina7c2v88sg90zqd-source;
  libraryHaskellDepends = [
    base incipit-core polysemy-conc polysemy-log polysemy-resume
    polysemy-time
  ];
  homepage = "https://github.com/tek/incipit#readme";
  description = "A Prelude for Polysemy";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  mime-types = {
  meta = {
    sha256 = "0mdfiq304yrqb15lh4ajs7mp3wd4ingc5f0bqry9ig0pfj4kcdvn";
    url = "https://hackage.haskell.org";
    ver = "0.1.2.2";
  };
  drv = { mkDerivation, base, bytestring, containers, lib, text }:
mkDerivation {
  pname = "mime-types";
  version = "0.1.2.2";
  src = /nix/store/1wf66yc8zr47bb7imw36syj2gys6advg-source;
  libraryHaskellDepends = [ base bytestring containers text ];
  homepage = "https://github.com/yesodweb/wai";
  description = "Basic mime-type handling types and functions";
  license = lib.licenses.mit;
}
;
}
;
  optparse-applicative = {
  meta = {
    sha256 = "0cs8fqipakad38lvm75nz98hmvf881mgjhnc7icblxfzh92ay6kn";
    url = "https://hackage.haskell.org";
    ver = "0.19.0.0";
  };
  drv = { mkDerivation, base, lib, prettyprinter
, prettyprinter-ansi-terminal, process, QuickCheck, text
, transformers
}:
mkDerivation {
  pname = "optparse-applicative";
  version = "0.19.0.0";
  src = /nix/store/l5z3gyf61qdyda9hmv5fqdq6svb2g7wh-source;
  libraryHaskellDepends = [
    base prettyprinter prettyprinter-ansi-terminal process text
    transformers
  ];
  testHaskellDepends = [ base QuickCheck ];
  homepage = "https://github.com/pcapriotti/optparse-applicative";
  description = "Utilities and combinators for parsing command line options";
  license = lib.licenses.bsd3;
}
;
}
;
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    url = "https://hackage.haskell.org";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-conc = {
  meta = {
    sha256 = "1xli6ja9f7qx2k9956lw4h9y5ywdglhgw769afxw9d4w9avclx28";
    url = "https://hackage.haskell.org";
    ver = "0.14.1.1";
  };
  drv = { mkDerivation, async, base, hedgehog, incipit-core, lib, polysemy
, polysemy-plugin, polysemy-resume, polysemy-test, polysemy-time
, stm, stm-chans, tasty, tasty-hedgehog, time, torsor, unagi-chan
}:
mkDerivation {
  pname = "polysemy-conc";
  version = "0.14.1.1";
  src = /nix/store/j8i858l0kb1zddk8w5g2swga6cfmd2ap-source;
  libraryHaskellDepends = [
    async base incipit-core polysemy polysemy-resume polysemy-time stm
    stm-chans torsor unagi-chan
  ];
  testHaskellDepends = [
    async base hedgehog incipit-core polysemy polysemy-plugin
    polysemy-test polysemy-time tasty tasty-hedgehog time torsor
  ];
  homepage = "https://github.com/tek/polysemy-conc#readme";
  description = "Polysemy effects for concurrency";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    url = "https://hackage.haskell.org";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-log = {
  meta = {
    sha256 = "09jdy3jzry31knaydjqka0mj8jwscdys5wq2xij21lxbxr5msy1m";
    url = "https://hackage.haskell.org";
    ver = "0.11.1.0";
  };
  drv = { mkDerivation, ansi-terminal, async, base, incipit-core, lib
, polysemy, polysemy-conc, polysemy-plugin, polysemy-test
, polysemy-time, stm, tasty, time
}:
mkDerivation {
  pname = "polysemy-log";
  version = "0.11.1.0";
  src = /nix/store/5j242iz4v4jac7f008bm2fwy4rrrpij7-source;
  libraryHaskellDepends = [
    ansi-terminal async base incipit-core polysemy polysemy-conc
    polysemy-time stm time
  ];
  testHaskellDepends = [
    base incipit-core polysemy polysemy-conc polysemy-plugin
    polysemy-test polysemy-time tasty time
  ];
  benchmarkHaskellDepends = [
    base incipit-core polysemy polysemy-conc polysemy-plugin
  ];
  homepage = "https://github.com/tek/polysemy-log#readme";
  description = "Polysemy effects for logging";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-process = {
  meta = {
    sha256 = "1qvbkldhai77r2pr7wbznsb9pr0pawynmvcd31v3v8jpki3xaycr";
    url = "https://hackage.haskell.org";
    ver = "0.14.1.1";
  };
  drv = { mkDerivation, async, base, hedgehog, incipit-core, lib, path
, path-io, polysemy, polysemy-conc, polysemy-plugin
, polysemy-resume, polysemy-test, polysemy-time, posix-pty, process
, stm-chans, tasty, tasty-expected-failure, tasty-hedgehog
, typed-process, unix
}:
mkDerivation {
  pname = "polysemy-process";
  version = "0.14.1.1";
  src = /nix/store/87gas7qy1x5y4p06cqm4s4n5r594wk1k-source;
  libraryHaskellDepends = [
    async base incipit-core path path-io polysemy polysemy-conc
    polysemy-resume polysemy-time posix-pty process stm-chans
    typed-process unix
  ];
  testHaskellDepends = [
    async base hedgehog incipit-core polysemy polysemy-conc
    polysemy-plugin polysemy-resume polysemy-test polysemy-time tasty
    tasty-expected-failure tasty-hedgehog typed-process unix
  ];
  homepage = "https://github.com/tek/polysemy-conc#readme";
  description = "Polysemy effects for system processes";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-resume = {
  meta = {
    sha256 = "1i2bnpd3l357jhln8xl92z65b3mskz9y8z1xlha4lm0m855qyk15";
    url = "https://hackage.haskell.org";
    ver = "0.9.0.1";
  };
  drv = { mkDerivation, base, incipit-core, lib, polysemy, polysemy-plugin
, polysemy-test, stm, tasty, transformers
}:
mkDerivation {
  pname = "polysemy-resume";
  version = "0.9.0.1";
  src = /nix/store/mxw7kjiqx9gr4p06crj2j0f34rkdrdqn-source;
  libraryHaskellDepends = [
    base incipit-core polysemy transformers
  ];
  testHaskellDepends = [
    base incipit-core polysemy polysemy-plugin polysemy-test stm tasty
  ];
  homepage = "https://github.com/tek/polysemy-resume#readme";
  description = "Polysemy error tracking";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-test = {
  meta = {
    sha256 = "1sp9iag1brknmdy0qvmgnmynwc4gbg1jy21w584x1m2hpqi25p6j";
    url = "https://hackage.haskell.org";
    ver = "0.10.0.1";
  };
  drv = { mkDerivation, base, hedgehog, incipit-core, lib, path, path-io
, polysemy, tasty, tasty-hedgehog, transformers
}:
mkDerivation {
  pname = "polysemy-test";
  version = "0.10.0.1";
  src = /nix/store/lxl8vyrvmkpdf7j78dcxapzlzvk9vbwk-source;
  enableSeparateDataOutput = true;
  libraryHaskellDepends = [
    base hedgehog incipit-core path path-io polysemy tasty
    tasty-hedgehog transformers
  ];
  testHaskellDepends = [
    base hedgehog incipit-core path polysemy tasty
  ];
  homepage = "https://github.com/tek/polysemy-test#readme";
  description = "Polysemy effects for testing";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-time = {
  meta = {
    sha256 = "0cw39gvmr9rgh3hc0gd55wimm4lxzw9nyrczixk42nw170bpls40";
    url = "https://hackage.haskell.org";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, aeson, base, incipit-core, lib, polysemy-test
, tasty, template-haskell, time, torsor
}:
mkDerivation {
  pname = "polysemy-time";
  version = "0.7.0.1";
  src = /nix/store/akynivsc8xs0v3cf06g7jlcch86xsapw-source;
  libraryHaskellDepends = [
    aeson base incipit-core template-haskell time torsor
  ];
  testHaskellDepends = [
    base incipit-core polysemy-test tasty time
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for time";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  servant-client = {
  meta = {
    sha256 = "0xlf354mcvg3cg8nqfi1aqfym686qcyy1yv46fg9fxchms9njczr";
    url = "https://hackage.haskell.org";
    ver = "0.20.3.0";
  };
  drv = { mkDerivation, aeson, base, base-compat, bytestring, containers
, deepseq, entropy, exceptions, generics-sop, hspec, hspec-discover
, http-api-data, http-client, http-media, http-types, HUnit
, kan-extensions, lib, markdown-unlit, monad-control, mtl, network
, QuickCheck, semigroupoids, servant, servant-client-core
, servant-server, sop-core, stm, text, time, transformers
, transformers-base, wai, warp
}:
mkDerivation {
  pname = "servant-client";
  version = "0.20.3.0";
  src = /nix/store/y0azgrrnkv9wq5wy4fz962k9v9s0ck3z-source;
  libraryHaskellDepends = [
    base base-compat bytestring containers deepseq exceptions
    http-client http-media http-types kan-extensions monad-control mtl
    semigroupoids servant servant-client-core stm time transformers
    transformers-base
  ];
  testHaskellDepends = [
    aeson base base-compat bytestring entropy generics-sop hspec
    http-api-data http-client http-types HUnit markdown-unlit mtl
    network QuickCheck servant servant-client-core servant-server
    sop-core stm text transformers wai warp
  ];
  testToolDepends = [ hspec-discover markdown-unlit ];
  homepage = "http://docs.servant.dev/";
  description = "Automatic derivation of querying functions for servant";
  license = lib.licenses.bsd3;
}
;
}
;
  servant-client-core = {
  meta = {
    sha256 = "0yv0asv77zjclnvadjb2hxjghnmz5rnba4akg237x3ssh50i52ca";
    url = "https://hackage.haskell.org";
    ver = "0.20.3.0";
  };
  drv = { mkDerivation, aeson, attoparsec, base, base-compat
, base64-bytestring, bytestring, constraints, containers, deepseq
, exceptions, free, hspec, hspec-discover, http-media, http-types
, lib, network-uri, QuickCheck, safe, servant, sop-core
, template-haskell, text, transformers
}:
mkDerivation {
  pname = "servant-client-core";
  version = "0.20.3.0";
  src = /nix/store/9dr7w7j8242pv1aypymsml7z4bh17jyf-source;
  libraryHaskellDepends = [
    aeson attoparsec base base-compat base64-bytestring bytestring
    constraints containers deepseq exceptions free http-media
    http-types network-uri safe servant sop-core template-haskell text
  ];
  testHaskellDepends = [
    base base-compat bytestring deepseq hspec QuickCheck servant
    transformers
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://docs.servant.dev/";
  description = "Core functionality and class for client function generation for servant APIs";
  license = lib.licenses.bsd3;
}
;
}
;
  servant-server = {
  meta = {
    sha256 = "053d5j5sxki31v8d5b73jx53bfhz76pm8xyb99n0rk1gxc8rg18x";
    url = "https://hackage.haskell.org";
    ver = "0.20.3.0";
  };
  drv = { mkDerivation, aeson, base, base-compat, base64-bytestring
, bytestring, constraints, containers, directory, exceptions
, filepath, hspec, hspec-discover, hspec-wai, http-api-data
, http-media, http-types, lib, monad-control, mtl, network
, resourcet, safe, servant, should-not-typecheck, sop-core, tagged
, temporary, text, transformers, transformers-base, wai
, wai-app-static, wai-extra, warp, word8
}:
mkDerivation {
  pname = "servant-server";
  version = "0.20.3.0";
  src = /nix/store/bzxi418yskly16zwlrcbxfk8cw38mzfz-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base base64-bytestring bytestring constraints containers exceptions
    filepath http-api-data http-media http-types monad-control mtl
    network resourcet servant sop-core tagged text transformers
    transformers-base wai wai-app-static word8
  ];
  executableHaskellDepends = [
    aeson base base-compat text wai warp
  ];
  testHaskellDepends = [
    aeson base base-compat base64-bytestring bytestring directory hspec
    hspec-wai http-types mtl resourcet safe servant
    should-not-typecheck temporary text wai wai-extra
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://docs.servant.dev/";
  description = "A family of combinators for defining webservices APIs and serving them";
  license = lib.licenses.bsd3;
  mainProgram = "greet";
}
;
}
;
  tasty = {
  meta = {
    sha256 = "1xjlmgsww34asjl9rcwbziw5l4qqbvi5l4b7qvzf4dc7hqkpq1rs";
    url = "https://hackage.haskell.org";
    ver = "1.5.3";
  };
  drv = { mkDerivation, ansi-terminal, base, containers, lib
, optparse-applicative, stm, tagged, transformers, unix
}:
mkDerivation {
  pname = "tasty";
  version = "1.5.3";
  src = /nix/store/9028fgac7afc6vw6is37lvq4p8gqpa7m-source;
  libraryHaskellDepends = [
    ansi-terminal base containers optparse-applicative stm tagged
    transformers unix
  ];
  homepage = "https://github.com/UnkindPartition/tasty";
  description = "Modern and extensible testing framework";
  license = lib.licenses.mit;
}
;
}
;
  tasty-expected-failure = {
  meta = {
    sha256 = "1dplg5n7rv8azy7xysl0z85inicvcxwprf5n9lh5k12lki5i1hdc";
    url = "https://hackage.haskell.org";
    ver = "0.12.3";
  };
  drv = { mkDerivation, base, hedgehog, lib, tagged, tasty, tasty-golden
, tasty-hedgehog, tasty-hunit, unbounded-delays
}:
mkDerivation {
  pname = "tasty-expected-failure";
  version = "0.12.3";
  src = /nix/store/qrh487167vrz6d983f0kxwkgicvf4nj9-source;
  libraryHaskellDepends = [ base tagged tasty unbounded-delays ];
  testHaskellDepends = [
    base hedgehog tasty tasty-golden tasty-hedgehog tasty-hunit
  ];
  homepage = "http://github.com/nomeata/tasty-expected-failure";
  description = "Mark tasty tests as failure expected";
  license = lib.licenses.mit;
}
;
}
;
  tasty-hedgehog = {
  meta = {
    sha256 = "04kg2qdnsqzzmj3xggy2jcgidlp21lsjkz4sfnbq7b1yhrv2vbbc";
    url = "https://hackage.haskell.org";
    ver = "1.4.0.2";
  };
  drv = { mkDerivation, base, hedgehog, lib, tagged, tasty
, tasty-expected-failure
}:
mkDerivation {
  pname = "tasty-hedgehog";
  version = "1.4.0.2";
  src = /nix/store/b9mxq4fh65sif22q9a4g041jvp847cyc-source;
  libraryHaskellDepends = [ base hedgehog tagged tasty ];
  testHaskellDepends = [
    base hedgehog tasty tasty-expected-failure
  ];
  homepage = "https://github.com/qfpl/tasty-hedgehog";
  description = "Integration for tasty and hedgehog";
  license = lib.licenses.bsd3;
}
;
}
;
  time-hourglass = {
  meta = {
    sha256 = "11fm4wywl0q5g0q34d049x7wxlp80rycp7hqrp2m7l7dmhihnn6d";
    url = "https://hackage.haskell.org";
    ver = "0.3.0";
  };
  drv = { mkDerivation, base, deepseq, lib, tasty, tasty-bench, tasty-hunit
, tasty-quickcheck, time
}:
mkDerivation {
  pname = "time-hourglass";
  version = "0.3.0";
  src = /nix/store/2pj6dfsarzxk33vvfpgk4x9gmdbybrm2-source;
  libraryHaskellDepends = [ base deepseq ];
  testHaskellDepends = [
    base deepseq tasty tasty-hunit tasty-quickcheck time
  ];
  benchmarkHaskellDepends = [ base deepseq tasty-bench time ];
  homepage = "https://github.com/mpilgrem/time-hourglass";
  description = "A simple and efficient time library";
  license = lib.licenses.bsd3;
}
;
}
;
  time-manager = {
  meta = {
    sha256 = "1lw1xx9p5qqznrg04s7phki2rljxzx29z2xcd9qa46wjhhg54fds";
    url = "https://hackage.haskell.org";
    ver = "0.3.1.1";
  };
  drv = { mkDerivation, base, containers, hspec, HUnit, lib, stm }:
mkDerivation {
  pname = "time-manager";
  version = "0.3.1.1";
  src = /nix/store/1k5zhmfykz5ll7wsixwccd6l2vsd1j65-source;
  libraryHaskellDepends = [ base containers stm ];
  testHaskellDepends = [ base hspec HUnit ];
  homepage = "http://github.com/yesodweb/wai";
  description = "Scalable timer";
  license = lib.licenses.mit;
}
;
}
;
  tls = {
  meta = {
    sha256 = "1arnw38a3x70264sags3yrq4c01nfcy17sjq3ycasfb2yq6fiflm";
    url = "https://hackage.haskell.org";
    ver = "2.2.2";
  };
  drv = { mkDerivation, async, base, base16-bytestring, base64-bytestring
, bytestring, cereal, containers, crypton, crypton-asn1-encoding
, crypton-asn1-types, crypton-x509, crypton-x509-store
, crypton-x509-validation, data-default, ech-config, hpke, hspec
, hspec-discover, lib, memory, mtl, network, network-run
, QuickCheck, random, serialise, tasty-bench, time-hourglass
, transformers, unix-time, zlib
}:
mkDerivation {
  pname = "tls";
  version = "2.2.2";
  src = /nix/store/lip2w07ws42rrgwsns0izz82jyi9sdhr-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base base16-bytestring bytestring cereal crypton
    crypton-asn1-encoding crypton-asn1-types crypton-x509
    crypton-x509-store crypton-x509-validation data-default ech-config
    hpke memory mtl network random serialise transformers unix-time
    zlib
  ];
  testHaskellDepends = [
    async base base64-bytestring bytestring crypton crypton-asn1-types
    crypton-x509 crypton-x509-validation ech-config hspec QuickCheck
    serialise time-hourglass
  ];
  testToolDepends = [ hspec-discover ];
  benchmarkHaskellDepends = [
    async base base64-bytestring bytestring containers crypton
    crypton-asn1-types crypton-x509 crypton-x509-store
    crypton-x509-validation data-default ech-config hspec network
    network-run QuickCheck serialise tasty-bench time-hourglass
  ];
  homepage = "https://github.com/haskell-tls/hs-tls";
  description = "TLS protocol native implementation";
  license = lib.licenses.bsd3;
}
;
}
;
  wai-app-static = {
  meta = {
    sha256 = "1kwvzy9w4v76q5bk4xwq7kz9q9l8867my6zvsv731x6xkhy7wr2c";
    url = "https://hackage.haskell.org";
    ver = "3.1.9";
  };
  drv = { mkDerivation, base, blaze-html, blaze-markup, bytestring
, containers, crypton, directory, file-embed, filepath, hspec
, http-date, http-types, lib, memory, mime-types, mockery
, old-locale, optparse-applicative, template-haskell, temporary
, text, time, transformers, unix-compat, unordered-containers, wai
, wai-extra, warp, zlib
}:
mkDerivation {
  pname = "wai-app-static";
  version = "3.1.9";
  src = /nix/store/k3rzn1agy7w5d6qw9254ymn7caq4b8l4-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base blaze-html blaze-markup bytestring containers crypton
    directory file-embed filepath http-date http-types memory
    mime-types old-locale optparse-applicative template-haskell text
    time transformers unix-compat unordered-containers wai wai-extra
    warp zlib
  ];
  executableHaskellDepends = [ base ];
  testHaskellDepends = [
    base bytestring filepath hspec http-date http-types mime-types
    mockery temporary text transformers unix-compat wai wai-extra zlib
  ];
  homepage = "http://www.yesodweb.com/book/web-application-interface";
  description = "WAI application for static serving";
  license = lib.licenses.mit;
  mainProgram = "warp";
}
;
}
;
  wai-extra = {
  meta = {
    sha256 = "0ba54l3hbpv66lysdp3s7jhyry554ksc5a2f9fps9q7phl3gzak9";
    url = "https://hackage.haskell.org";
    ver = "3.1.18";
  };
  drv = { mkDerivation, aeson, ansi-terminal, base, base64-bytestring
, bytestring, call-stack, case-insensitive, containers, cookie
, data-default, directory, fast-logger, hspec, hspec-discover
, http-types, HUnit, iproute, lib, network, resourcet
, streaming-commons, temporary, text, time, transformers, unix
, vault, wai, wai-logger, warp, word8, zlib
}:
mkDerivation {
  pname = "wai-extra";
  version = "3.1.18";
  src = /nix/store/9c5pxsjb2nx2d0b1i271mx5nvj9q91s9-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson ansi-terminal base base64-bytestring bytestring call-stack
    case-insensitive containers cookie data-default directory
    fast-logger http-types HUnit iproute network resourcet
    streaming-commons text time transformers unix vault wai wai-logger
    warp word8
  ];
  testHaskellDepends = [
    aeson base bytestring case-insensitive cookie directory fast-logger
    hspec http-types HUnit iproute resourcet temporary text time wai
    warp word8 zlib
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://github.com/yesodweb/wai";
  description = "Provides some basic WAI handlers and middleware";
  license = lib.licenses.mit;
}
;
}
;
  warp = {
  meta = {
    sha256 = "0m4wj459j7fhav4i05df5nmbnzb1j8qwjdxcwacx81jv03bm1p33";
    url = "https://hackage.haskell.org";
    ver = "3.4.12";
  };
  drv = { mkDerivation, array, async, auto-update, base, bsb-http-chunked
, bytestring, case-insensitive, containers, criterion, crypton-x509
, directory, ghc-prim, hashable, hspec, hspec-discover, http-client
, http-date, http-types, http2, iproute, lib, network, process
, QuickCheck, recv, simple-sendfile, stm, streaming-commons, text
, time-manager, unix, vault, wai, word8
}:
mkDerivation {
  pname = "warp";
  version = "3.4.12";
  src = /nix/store/kq79facjidfd5zmkkmfv9ng9wsz42vw2-source;
  libraryHaskellDepends = [
    array async auto-update base bsb-http-chunked bytestring
    case-insensitive containers crypton-x509 ghc-prim hashable
    http-date http-types http2 iproute network recv simple-sendfile stm
    streaming-commons text time-manager unix vault wai word8
  ];
  testHaskellDepends = [
    array async auto-update base bsb-http-chunked bytestring
    case-insensitive containers crypton-x509 directory ghc-prim
    hashable hspec http-client http-date http-types http2 iproute
    network process QuickCheck recv simple-sendfile stm
    streaming-commons text time-manager unix vault wai word8
  ];
  testToolDepends = [ hspec-discover ];
  benchmarkHaskellDepends = [
    array auto-update base bytestring case-insensitive containers
    criterion crypton-x509 ghc-prim hashable http-date http-types
    network recv stm streaming-commons text time-manager unix vault wai
    word8
  ];
  homepage = "http://github.com/yesodweb/wai";
  description = "A fast, light-weight web server for WAI applications";
  license = lib.licenses.mit;
}
;
}
;
  zeugma = {
  meta = {
    sha256 = "14k0lq3ghanvxw47g43vvzfw4d9cm04bmc2fn5cp4y3vslflaknj";
    url = "https://hackage.haskell.org";
    ver = "0.10.0.1";
  };
  drv = { mkDerivation, base, chronos, hedgehog, incipit, lib, polysemy
, polysemy-chronos, polysemy-process, polysemy-test, tasty
, tasty-expected-failure, tasty-hedgehog
}:
mkDerivation {
  pname = "zeugma";
  version = "0.10.0.1";
  src = /nix/store/m96zcriwkbli759fplm7hk85amz929pr-source;
  libraryHaskellDepends = [
    base chronos hedgehog incipit polysemy polysemy-chronos
    polysemy-process polysemy-test tasty tasty-expected-failure
    tasty-hedgehog
  ];
  homepage = "https://github.com/tek/incipit#readme";
  description = "Polysemy effects for testing";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
leak-test-extends-ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
lower = {
  auto-update = {
  meta = {
    sha256 = "1fp45qcivbkk97n03dq5n233wvyd39ldajs7apdqg70pd76178sa";
    url = "https://hackage.haskell.org";
    ver = "0.1.6";
  };
  drv = { mkDerivation, base, exceptions, hspec, HUnit, lib, retry }:
mkDerivation {
  pname = "auto-update";
  version = "0.1.6";
  src = /nix/store/l0kf513n5lqjwykyfp3sqsvgbg0r85vh-source;
  libraryHaskellDepends = [ base ];
  testHaskellDepends = [ base exceptions hspec HUnit retry ];
  homepage = "https://github.com/yesodweb/wai";
  description = "Efficiently run periodic, on-demand actions";
  license = lib.licenses.mit;
}
;
}
;
  cabal-doctest = {
  meta = {
    sha256 = "094mvqgh9bhx5v9xanzkhcm8pcxzmkaa68lr3bqpjzkdxydx81nk";
    url = "https://hackage.haskell.org";
    ver = "1.0.12";
  };
  drv = { mkDerivation, base, Cabal, directory, filepath, lib }:
mkDerivation {
  pname = "cabal-doctest";
  version = "1.0.12";
  src = /nix/store/dh7hx0wqn5821ds0dfsrahz1vyib9xi9-source;
  libraryHaskellDepends = [ base Cabal directory filepath ];
  homepage = "https://github.com/ulidtko/cabal-doctest";
  description = "A Setup.hs helper for running doctests";
  license = lib.licenses.bsd3;
}
;
}
;
  case-insensitive = {
  meta = {
    sha256 = "0nn4hffa6i3sf6n1cg69br7qiwsc3shw26ay9bkwhkff6lfpw1bj";
    url = "https://hackage.haskell.org";
    ver = "1.2.0.11";
  };
  drv = { mkDerivation, base, bytestring, criterion, deepseq, hashable
, HUnit, lib, test-framework, test-framework-hunit, text
}:
mkDerivation {
  pname = "case-insensitive";
  version = "1.2.0.11";
  src = /nix/store/9wizbr4d8zvvh4mr1h3grzrvwkvhy3hm-source;
  libraryHaskellDepends = [ base bytestring deepseq hashable text ];
  testHaskellDepends = [
    base bytestring HUnit test-framework test-framework-hunit text
  ];
  benchmarkHaskellDepends = [ base bytestring criterion deepseq ];
  homepage = "https://github.com/basvandijk/case-insensitive";
  description = "Case insensitive string comparison";
  license = lib.licenses.bsd3;
}
;
}
;
  chronos = {
  meta = {
    sha256 = "1pbfp25py682d17visa4i9rjxmiim8aykrgs7nv2q9anajv88kdx";
    url = "https://hackage.haskell.org";
    ver = "1.1.6.2";
  };
  drv = { mkDerivation, aeson, attoparsec, base, bytebuild, byteslice
, bytesmith, bytestring, criterion, deepseq, hashable, HUnit, lib
, natural-arithmetic, old-locale, primitive, QuickCheck
, test-framework, test-framework-hunit, test-framework-quickcheck2
, text, text-short, thyme, time, torsor, vector
}:
mkDerivation {
  pname = "chronos";
  version = "1.1.6.2";
  src = /nix/store/4lqja84257d3yzxlf1vsz8687hydv3aj-source;
  libraryHaskellDepends = [
    aeson attoparsec base bytebuild byteslice bytesmith bytestring
    deepseq hashable natural-arithmetic primitive text text-short
    torsor vector
  ];
  testHaskellDepends = [
    aeson attoparsec base bytestring HUnit QuickCheck test-framework
    test-framework-hunit test-framework-quickcheck2 text torsor
  ];
  benchmarkHaskellDepends = [
    attoparsec base bytestring criterion deepseq old-locale QuickCheck
    text text-short thyme time
  ];
  homepage = "https://github.com/byteverse/chronos";
  description = "A high-performance time library";
  license = lib.licenses.bsd3;
}
;
}
;
  composition = {
  meta = {
    sha256 = "1mywrzizfj7740ybww2fxc3q6v6wp8yxsnv6hs3b30ps2jr4mds0";
    url = "https://hackage.haskell.org";
    ver = "1.0.2.2";
  };
  drv = { mkDerivation, lib }:
mkDerivation {
  pname = "composition";
  version = "1.0.2.2";
  src = /nix/store/aw0b14qvf59vlgd1ijrzq6gjvk2a2n3c-source;
  description = "Combinators for unorthodox function composition";
  license = lib.licenses.bsd3;
}
;
}
;
  concurrent-output = {
  meta = {
    sha256 = "1w87rrf337s8wc4z3dkh2mk990003jsk18ry5yawv4465k4yvamw";
    url = "https://hackage.haskell.org";
    ver = "1.10.21";
  };
  drv = { mkDerivation, ansi-terminal, async, base, directory, exceptions
, lib, process, stm, terminal-size, text, transformers, unix
}:
mkDerivation {
  pname = "concurrent-output";
  version = "1.10.21";
  src = /nix/store/kwz3gmjbrzcw4iccsx2d0cyn85klblqy-source;
  libraryHaskellDepends = [
    ansi-terminal async base directory exceptions process stm
    terminal-size text transformers unix
  ];
  description = "Ungarble output from several threads or commands";
  license = lib.licenses.bsd2;
}
;
}
;
  crypton = {
  meta = {
    sha256 = "0kk6sl42q3fw9l9xv4h8jsxvhl9535r00x1gw0l7y7mjav0pcjj5";
    url = "https://hackage.haskell.org";
    ver = "1.0.0";
  };
  drv = { mkDerivation, base, basement, bytestring, deepseq, gauge
, ghc-prim, integer-gmp, lib, memory, random, tasty, tasty-hunit
, tasty-kat, tasty-quickcheck
}:
mkDerivation {
  pname = "crypton";
  version = "1.0.0";
  src = /nix/store/jkrprx72jnsxryazz1vsfj2g0nscc7ja-source;
  libraryHaskellDepends = [
    base basement bytestring deepseq ghc-prim integer-gmp memory
  ];
  testHaskellDepends = [
    base bytestring memory tasty tasty-hunit tasty-kat tasty-quickcheck
  ];
  benchmarkHaskellDepends = [
    base bytestring deepseq gauge memory random
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton";
  description = "Cryptography Primitives sink";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-box = {
  meta = {
    sha256 = "04q7r3sjbclja4g2diiah45953kh3wi9502q55xdr19na71my6zn";
    url = "https://hackage.haskell.org";
    ver = "1.1.0";
  };
  drv = { mkDerivation, base, bytestring, crypton, hspec, hspec-discover
, lib, memory
}:
mkDerivation {
  pname = "crypton-box";
  version = "1.1.0";
  src = /nix/store/h3vm0xkdpn4rdshlsqfz6lvmbnd8p9d3-source;
  libraryHaskellDepends = [ base bytestring crypton memory ];
  testHaskellDepends = [ base bytestring crypton hspec memory ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/yutotakano/crypton-box#readme";
  description = "NaCl crypto/secret box implementations based on crypton primitives";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-connection = {
  meta = {
    sha256 = "1l5yr5nck4vyi55pyc7j1zarfcs196gbxjlwljs7s7v2r3h43jcc";
    url = "https://hackage.haskell.org";
    ver = "0.4.5";
  };
  drv = { mkDerivation, base, bytestring, containers, crypton-socks
, crypton-x509-store, crypton-x509-system, data-default, lib
, network, tls
}:
mkDerivation {
  pname = "crypton-connection";
  version = "0.4.5";
  src = /nix/store/19svh548rwpqfdj2wqjwb2d7vc5jnr8z-source;
  libraryHaskellDepends = [
    base bytestring containers crypton-socks crypton-x509-store
    crypton-x509-system data-default network tls
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-connection";
  description = "Simple and easy network connection API";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-x509 = {
  meta = {
    sha256 = "0fvg9jwllhgbjafsy41q938yz1s4z3g7cjnar79g95gvkv8m6byn";
    url = "https://hackage.haskell.org";
    ver = "1.7.7";
  };
  drv = { mkDerivation, asn1-encoding, asn1-parse, asn1-types, base
, bytestring, containers, crypton, hourglass, lib, memory, mtl, pem
, tasty, tasty-quickcheck, transformers
}:
mkDerivation {
  pname = "crypton-x509";
  version = "1.7.7";
  src = /nix/store/ir8b20hrv371i90bgvbini9j90k8jc7n-source;
  libraryHaskellDepends = [
    asn1-encoding asn1-parse asn1-types base bytestring containers
    crypton hourglass memory pem transformers
  ];
  testHaskellDepends = [
    asn1-types base bytestring crypton hourglass mtl tasty
    tasty-quickcheck
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
  description = "X509 reader and writer";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-x509-store = {
  meta = {
    sha256 = "1kivql51byld49nbyn9zy1wmmi4b7qnbr7crffwf7swfljiif3y1";
    url = "https://hackage.haskell.org";
    ver = "1.6.14";
  };
  drv = { mkDerivation, asn1-encoding, asn1-types, base, bytestring
, containers, crypton, crypton-x509, directory, filepath, lib, mtl
, pem, tasty, tasty-hunit, unix
}:
mkDerivation {
  pname = "crypton-x509-store";
  version = "1.6.14";
  src = /nix/store/jpb26rbymy6d9yx7lszipqlgn1mm8hc2-source;
  libraryHaskellDepends = [
    asn1-encoding asn1-types base bytestring containers crypton
    crypton-x509 directory filepath mtl pem unix
  ];
  testHaskellDepends = [
    base bytestring crypton-x509 tasty tasty-hunit
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
  description = "X.509 collection accessing and storing methods";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-x509-system = {
  meta = {
    sha256 = "02awppmcad9nr3srwjz5hj8fzilj05178cqvlhvl01chs5w0msm9";
    url = "https://hackage.haskell.org";
    ver = "1.6.8";
  };
  drv = { mkDerivation, base, bytestring, containers, crypton-x509
, crypton-x509-store, directory, filepath, lib, mtl, pem, process
}:
mkDerivation {
  pname = "crypton-x509-system";
  version = "1.6.8";
  src = /nix/store/v8vbwgiqcg43i5sbp5892bhcwvg1ysg2-source;
  libraryHaskellDepends = [
    base bytestring containers crypton-x509 crypton-x509-store
    directory filepath mtl pem process
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
  description = "Handle per-operating-system X.509 accessors and storage";
  license = lib.licenses.bsd3;
}
;
}
;
  crypton-x509-validation = {
  meta = {
    sha256 = "1z262xxkjsnwfzaiklxr62baayvwxg22xyf1h8g027s9a1h89wlb";
    url = "https://hackage.haskell.org";
    ver = "1.6.14";
  };
  drv = { mkDerivation, asn1-encoding, asn1-types, base, bytestring
, containers, crypton, crypton-x509, crypton-x509-store
, data-default, hourglass, iproute, lib, memory, mtl, pem, tasty
, tasty-hunit
}:
mkDerivation {
  pname = "crypton-x509-validation";
  version = "1.6.14";
  src = /nix/store/ff2z6d86fih99yl7a3l1sd4hn16lv43h-source;
  libraryHaskellDepends = [
    asn1-encoding asn1-types base bytestring containers crypton
    crypton-x509 crypton-x509-store data-default hourglass iproute
    memory mtl pem
  ];
  testHaskellDepends = [
    asn1-encoding asn1-types base bytestring crypton crypton-x509
    crypton-x509-store data-default hourglass memory tasty tasty-hunit
  ];
  homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
  description = "X.509 Certificate and CRL validation";
  license = lib.licenses.bsd3;
}
;
}
;
  cryptonite = {
  meta = {
    sha256 = "04wq8lh300dng87n59a37ngjqbwjlxpd62vz6ifvz0gpyx0pnhy7";
    url = "https://hackage.haskell.org";
    ver = "0.30";
  };
  drv = { mkDerivation, base, basement, bytestring, deepseq, gauge
, ghc-prim, integer-gmp, lib, memory, random, tasty, tasty-hunit
, tasty-kat, tasty-quickcheck
}:
mkDerivation {
  pname = "cryptonite";
  version = "0.30";
  src = /nix/store/vg0dva7p4r7zaz2x2pb79psj4i8azlns-source;
  libraryHaskellDepends = [
    base basement bytestring deepseq ghc-prim integer-gmp memory
  ];
  testHaskellDepends = [
    base bytestring memory tasty tasty-hunit tasty-kat tasty-quickcheck
  ];
  benchmarkHaskellDepends = [
    base bytestring deepseq gauge memory random
  ];
  homepage = "https://github.com/haskell-crypto/cryptonite";
  description = "Cryptography Primitives sink";
  license = lib.licenses.bsd3;
}
;
}
;
  either = {
  meta = {
    sha256 = "02gw0b0h42qwwlx2h1xk2ayhdw4abl6p1zji75cqs60x85x2a414";
    url = "https://hackage.haskell.org";
    ver = "5.0.3";
  };
  drv = { mkDerivation, base, bifunctors, lib, mtl, profunctors, QuickCheck
, semigroupoids, tasty, tasty-quickcheck
}:
mkDerivation {
  pname = "either";
  version = "5.0.3";
  src = /nix/store/d6skdklmmbgbgnw4r1ll1dpahhlkj0y3-source;
  libraryHaskellDepends = [
    base bifunctors mtl profunctors semigroupoids
  ];
  testHaskellDepends = [ base QuickCheck tasty tasty-quickcheck ];
  homepage = "http://github.com/ekmett/either/";
  description = "Combinators for working with sums";
  license = lib.licenses.bsd3;
}
;
}
;
  exon = {
  meta = {
    sha256 = "1sl4micbw42s3mbyhbyb3h28jjk1sb537crlai9h9c3p7ddn6dvd";
    url = "https://hackage.haskell.org";
    ver = "1.6.1.1";
  };
  drv = { mkDerivation, base, criterion, ghc, hedgehog, incipit-base, lib
, parsec, tasty, tasty-hedgehog, template-haskell
}:
mkDerivation {
  pname = "exon";
  version = "1.6.1.1";
  src = /nix/store/386fd70mbhlwhs88s83xwca7aqlrrvkz-source;
  libraryHaskellDepends = [
    base ghc incipit-base parsec template-haskell
  ];
  testHaskellDepends = [
    base hedgehog incipit-base tasty tasty-hedgehog template-haskell
  ];
  benchmarkHaskellDepends = [ base criterion incipit-base ];
  homepage = "https://github.com/tek/exon#readme";
  description = "Customizable quasiquote interpolation";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  fast-logger = {
  meta = {
    sha256 = "0xa52lm4js6w5sxry4iyjd9iz4r23p1z19nwf4s8kk0scw9ks8pz";
    url = "https://hackage.haskell.org";
    ver = "3.1.2";
  };
  drv = { mkDerivation, array, auto-update, base, bytestring, directory
, easy-file, filepath, hspec, hspec-discover, lib, text
, unix-compat, unix-time
}:
mkDerivation {
  pname = "fast-logger";
  version = "3.1.2";
  src = /nix/store/5mbr4m75kmnqn9q0j2mkmdn4frvqkb37-source;
  libraryHaskellDepends = [
    array auto-update base bytestring directory easy-file filepath text
    unix-compat unix-time
  ];
  testHaskellDepends = [ base bytestring directory hspec ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/kazu-yamamoto/logger";
  description = "A fast logging system";
  license = lib.licenses.bsd3;
}
;
}
;
  hedgehog = {
  meta = {
    sha256 = "1hz8xrg5p6vplvcj8c7pgidqnwqjmqahs9dla50nqpbcbdh932ll";
    url = "https://hackage.haskell.org";
    ver = "1.5";
  };
  drv = { mkDerivation, ansi-terminal, async, barbies, base, bytestring
, concurrent-output, containers, deepseq, directory, erf
, exceptions, lib, lifted-async, mmorph, monad-control, mtl
, pretty-show, primitive, random, resourcet, safe-exceptions, stm
, template-haskell, text, time, transformers, transformers-base
, wl-pprint-annotated
}:
mkDerivation {
  pname = "hedgehog";
  version = "1.5";
  src = /nix/store/asphc2qzd1cykd892r5fnhflbd8cwana-source;
  libraryHaskellDepends = [
    ansi-terminal async barbies base bytestring concurrent-output
    containers deepseq directory erf exceptions lifted-async mmorph
    monad-control mtl pretty-show primitive random resourcet
    safe-exceptions stm template-haskell text time transformers
    transformers-base wl-pprint-annotated
  ];
  testHaskellDepends = [
    base containers mmorph mtl pretty-show text transformers
  ];
  homepage = "https://hedgehog.qa";
  description = "Release with confidence";
  license = lib.licenses.bsd3;
}
;
}
;
  hsc2hs = {
  meta = {
    sha256 = "0wdg17kicnp6qbgynha216vihx7nnsglvhn5c089dqpa14hg35zw";
    url = "https://hackage.haskell.org";
    ver = "0.68.10";
  };
  drv = { mkDerivation, base, containers, directory, filepath, HUnit, lib
, process, test-framework, test-framework-hunit
}:
mkDerivation {
  pname = "hsc2hs";
  version = "0.68.10";
  src = /nix/store/14zlpg12331kakcpz0pn3f05xyg8ql8l-source;
  isLibrary = false;
  isExecutable = true;
  enableSeparateDataOutput = true;
  executableHaskellDepends = [
    base containers directory filepath process
  ];
  testHaskellDepends = [
    base HUnit test-framework test-framework-hunit
  ];
  description = "A preprocessor that helps with writing Haskell bindings to C code";
  license = lib.licenses.bsd3;
  mainProgram = "hsc2hs";
}
;
}
;
  http-api-data = {
  meta = {
    sha256 = "126vifb8gq49kffjqz2cx10zv674ag9l7qjsc1p5i60d46apr4f5";
    url = "https://hackage.haskell.org";
    ver = "0.6.3";
  };
  drv = { mkDerivation, base, bytestring, containers, cookie, hashable
, hspec, hspec-discover, http-types, lib, QuickCheck
, quickcheck-instances, tagged, text, text-iso8601, time-compat
, unordered-containers, uuid-types
}:
mkDerivation {
  pname = "http-api-data";
  version = "0.6.3";
  src = /nix/store/7ss13qjhj786ncgjkv061ginlg9iv4fw-source;
  libraryHaskellDepends = [
    base bytestring containers cookie hashable http-types tagged text
    text-iso8601 time-compat unordered-containers uuid-types
  ];
  testHaskellDepends = [
    base bytestring cookie hspec QuickCheck quickcheck-instances text
    time-compat unordered-containers uuid-types
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://github.com/fizruk/http-api-data";
  description = "Converting to/from HTTP API data like URL pieces, headers and query parameters";
  license = lib.licenses.bsd3;
}
;
}
;
  http-client = {
  meta = {
    sha256 = "1ddx0x74kgqxa84fv5m9k7c5pg34n6b7snrj9kss3ahc4k3p8s1l";
    url = "https://hackage.haskell.org";
    ver = "0.7.14";
  };
  drv = { mkDerivation, array, async, base, base64-bytestring
, blaze-builder, bytestring, case-insensitive, containers, cookie
, deepseq, directory, exceptions, filepath, ghc-prim, hspec
, hspec-discover, http-types, iproute, lib, mime-types
, monad-control, network, network-uri, random, stm
, streaming-commons, text, time, transformers, zlib
}:
mkDerivation {
  pname = "http-client";
  version = "0.7.14";
  src = /nix/store/f2awq20ndbl7nnb9x7pl8z53idq02yvk-source;
  libraryHaskellDepends = [
    array async base base64-bytestring blaze-builder bytestring
    case-insensitive containers cookie deepseq exceptions filepath
    ghc-prim http-types iproute mime-types network network-uri random
    stm streaming-commons text time transformers
  ];
  testHaskellDepends = [
    async base blaze-builder bytestring case-insensitive containers
    cookie deepseq directory hspec http-types monad-control network
    network-uri streaming-commons text time transformers zlib
  ];
  testToolDepends = [ hspec-discover ];
  doCheck = false;
  homepage = "https://github.com/snoyberg/http-client";
  description = "An HTTP client engine";
  license = lib.licenses.mit;
}
;
}
;
  http-client-tls = {
  meta = {
    sha256 = "1f8br94l5kywpsfvpmw54b1v6nx1yapslzrwiswsf6vf8kwfjjzg";
    url = "https://hackage.haskell.org";
    ver = "0.3.6.4";
  };
  drv = { mkDerivation, base, bytestring, case-insensitive, containers
, crypton, crypton-connection, data-default, exceptions, gauge
, hspec, http-client, http-types, lib, memory, network, network-uri
, text, tls, transformers
}:
mkDerivation {
  pname = "http-client-tls";
  version = "0.3.6.4";
  src = /nix/store/8r1b74si7yr0bxiw2wp65ypxzrdsmsxk-source;
  libraryHaskellDepends = [
    base bytestring case-insensitive containers crypton
    crypton-connection data-default exceptions http-client http-types
    memory network network-uri text tls transformers
  ];
  testHaskellDepends = [
    base crypton-connection hspec http-client http-types
  ];
  benchmarkHaskellDepends = [ base gauge http-client ];
  doCheck = false;
  homepage = "https://github.com/snoyberg/http-client";
  description = "http-client backend using the connection package and tls library";
  license = lib.licenses.mit;
}
;
}
;
  http-media = {
  meta = {
    sha256 = "10rxh1brpi9gsjrhgf5227z1gxrliipmiagp6j300jdgpf3rk8f3";
    url = "https://hackage.haskell.org";
    ver = "0.8.1.1";
  };
  drv = { mkDerivation, base, bytestring, case-insensitive, containers, lib
, QuickCheck, tasty, tasty-quickcheck, utf8-string
}:
mkDerivation {
  pname = "http-media";
  version = "0.8.1.1";
  src = /nix/store/c8a025lc33zcddnmgcbyzncykdi89zzi-source;
  libraryHaskellDepends = [
    base bytestring case-insensitive containers utf8-string
  ];
  testHaskellDepends = [
    base bytestring case-insensitive containers QuickCheck tasty
    tasty-quickcheck utf8-string
  ];
  homepage = "https://github.com/zmthy/http-media";
  description = "Processing HTTP Content-Type and Accept headers";
  license = lib.licenses.mit;
}
;
}
;
  http-types = {
  meta = {
    sha256 = "010mdxfymajc6zkvh3bchs8v4z7fdjkmazisaxfzjp4b5qga3ds8";
    url = "https://hackage.haskell.org";
    ver = "0.12.4";
  };
  drv = { mkDerivation, array, base, bytestring, case-insensitive, doctest
, hspec, lib, QuickCheck, quickcheck-instances, text
}:
mkDerivation {
  pname = "http-types";
  version = "0.12.4";
  src = /nix/store/id8vj31g3j68ww892rvgxn9yj14svmcg-source;
  libraryHaskellDepends = [
    array base bytestring case-insensitive text
  ];
  testHaskellDepends = [
    base bytestring doctest hspec QuickCheck quickcheck-instances text
  ];
  homepage = "https://github.com/Vlix/http-types";
  description = "Generic HTTP types for Haskell (for both client and server code)";
  license = lib.licenses.bsd3;
}
;
}
;
  http2 = {
  meta = {
    sha256 = "1skyjg31v4s7yhpnk9p8l419nd5kapi3sp7d0hja7b1fzb96x05g";
    url = "https://hackage.haskell.org";
    ver = "4.1.4";
  };
  drv = { mkDerivation, aeson, aeson-pretty, array, async, base
, base16-bytestring, bytestring, case-insensitive, containers
, crypton, directory, filepath, gauge, Glob, hspec, hspec-discover
, http-types, lib, network, network-byte-order, network-run
, psqueues, stm, text, time-manager, typed-process, unix-time
, unliftio, unordered-containers, vector
}:
mkDerivation {
  pname = "http2";
  version = "4.1.4";
  src = /nix/store/02i7h9k8ymaqh6dgg0cs9m7988rkjapg-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    array async base bytestring case-insensitive containers http-types
    network network-byte-order psqueues stm time-manager unix-time
    unliftio
  ];
  testHaskellDepends = [
    aeson aeson-pretty async base base16-bytestring bytestring crypton
    directory filepath Glob hspec http-types network network-byte-order
    network-run text typed-process unordered-containers vector
  ];
  testToolDepends = [ hspec-discover ];
  benchmarkHaskellDepends = [
    array base bytestring case-insensitive containers gauge
    network-byte-order stm
  ];
  homepage = "https://github.com/kazu-yamamoto/http2";
  description = "HTTP/2 library";
  license = lib.licenses.bsd3;
}
;
}
;
  incipit = {
  meta = {
    sha256 = "0vr1balwy6v9l15pjlyy372w0scli1wcl6395jqdkjncqm3ymdin";
    url = "https://hackage.haskell.org";
    ver = "0.10.0.1";
  };
  drv = { mkDerivation, base, incipit-core, lib, polysemy-conc
, polysemy-log, polysemy-resume, polysemy-time
}:
mkDerivation {
  pname = "incipit";
  version = "0.10.0.1";
  src = /nix/store/y9k0f8365246qsr7ina7c2v88sg90zqd-source;
  libraryHaskellDepends = [
    base incipit-core polysemy-conc polysemy-log polysemy-resume
    polysemy-time
  ];
  homepage = "https://github.com/tek/incipit#readme";
  description = "A Prelude for Polysemy";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  incipit-base = {
  meta = {
    sha256 = "0iyyvxpyyybn5ygr875pav6g5hbs00wa9jbr7qslszqpkfpy5x33";
    url = "https://hackage.haskell.org";
    ver = "0.6.1.0";
  };
  drv = { mkDerivation, base, bytestring, containers, data-default, lib
, stm, text
}:
mkDerivation {
  pname = "incipit-base";
  version = "0.6.1.0";
  src = /nix/store/2k1isywgqm3pcbzdhwyp97n9250g044k-source;
  libraryHaskellDepends = [
    base bytestring containers data-default stm text
  ];
  homepage = "https://github.com/tek/incipit-core#readme";
  description = "A Prelude for Polysemy – Base Reexports";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  incipit-core = {
  meta = {
    sha256 = "144c239nxl8zi2ik3ycic3901gxn8rccij3g609n2zgnn3b6zilj";
    url = "https://hackage.haskell.org";
    ver = "0.6.1.0";
  };
  drv = { mkDerivation, base, incipit-base, lib, polysemy }:
mkDerivation {
  pname = "incipit-core";
  version = "0.6.1.0";
  src = /nix/store/7bfdjb94bzganyaybhhjmxjcwypnsasp-source;
  libraryHaskellDepends = [ base incipit-base polysemy ];
  homepage = "https://github.com/tek/incipit-core#readme";
  description = "A Prelude for Polysemy";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  lens = {
  meta = {
    sha256 = "17g77mqcyy83lxrhb9lnjnp6m38mgphyzkaajy8kf00c0a41lyya";
    url = "https://hackage.haskell.org";
    ver = "5.3.6";
  };
  drv = { mkDerivation, array, assoc, base, base-orphans, bifunctors
, bytestring, call-stack, comonad, containers, contravariant
, criterion, deepseq, distributive, exceptions, filepath, free
, generic-deriving, hashable, indexed-traversable
, indexed-traversable-instances, kan-extensions, lib, mtl, parallel
, profunctors, QuickCheck, reflection, semigroupoids
, simple-reflect, strict, tagged, tasty, tasty-hunit
, tasty-quickcheck, template-haskell, text, th-abstraction, these
, transformers, unordered-containers, vector
}:
mkDerivation {
  pname = "lens";
  version = "5.3.6";
  src = /nix/store/ghi10m7md4bbhlfs1zvi93xwpsz42pjq-source;
  libraryHaskellDepends = [
    array assoc base base-orphans bifunctors bytestring call-stack
    comonad containers contravariant distributive exceptions filepath
    free hashable indexed-traversable indexed-traversable-instances
    kan-extensions mtl parallel profunctors reflection semigroupoids
    strict tagged template-haskell text th-abstraction these
    transformers unordered-containers vector
  ];
  testHaskellDepends = [
    base bytestring containers deepseq mtl QuickCheck simple-reflect
    tasty tasty-hunit tasty-quickcheck text transformers
  ];
  benchmarkHaskellDepends = [
    base bytestring comonad containers criterion deepseq
    generic-deriving transformers unordered-containers vector
  ];
  homepage = "http://github.com/ekmett/lens/";
  description = "Lenses, Folds and Traversals";
  license = lib.licenses.bsd2;
}
;
}
;
  mime-types = {
  meta = {
    sha256 = "14648bjr219wk3a2v6fnma7xwkcna80ir93yng05r4ljp675wdbc";
    url = "https://hackage.haskell.org";
    ver = "0.1.0.0";
  };
  drv = { mkDerivation, base, bytestring, containers, lib, text }:
mkDerivation {
  pname = "mime-types";
  version = "0.1.0.0";
  src = /nix/store/2frvy87wyfgihc2iv6jclyyym92d4zmi-source;
  libraryHaskellDepends = [ base bytestring containers text ];
  homepage = "https://github.com/yesodweb/wai";
  description = "Basic mime-type handling types and functions";
  license = lib.licenses.mit;
}
;
}
;
  parallel = {
  meta = {
    sha256 = "1pcaz12k48m5wcnl2vifkxg8miadridfzbn2l6a0mhfgnwjwk6pd";
    url = "https://hackage.haskell.org";
    ver = "3.3.0.0";
  };
  drv = { mkDerivation, array, base, containers, deepseq, lib }:
mkDerivation {
  pname = "parallel";
  version = "3.3.0.0";
  src = /nix/store/k3i91k58y4jj6ad9nf1ivi5jqzm31w1p-source;
  libraryHaskellDepends = [ array base containers deepseq ];
  description = "Parallel programming library";
  license = lib.licenses.bsd3;
}
;
}
;
  path-io = {
  meta = {
    sha256 = "05hcxgyf6kkz36mazd0fqwb6mjy2049gx3vh8qq9h93gfjkpp2vc";
    url = "https://hackage.haskell.org";
    ver = "1.6.3";
  };
  drv = { mkDerivation, base, containers, directory, dlist, exceptions
, filepath, hspec, lib, path, temporary, time, transformers
, unix-compat
}:
mkDerivation {
  pname = "path-io";
  version = "1.6.3";
  src = /nix/store/vgfbjck2brpd6zb090ljasw6z2xgvif9-source;
  libraryHaskellDepends = [
    base containers directory dlist exceptions filepath path temporary
    time transformers unix-compat
  ];
  testHaskellDepends = [
    base directory exceptions filepath hspec path transformers
    unix-compat
  ];
  homepage = "https://github.com/mrkkrp/path-io";
  description = "Interface to ‘directory’ package for users of ‘path’";
  license = lib.licenses.bsd3;
}
;
}
;
  polysemy = {
  meta = {
    sha256 = "0y339fh1jvjdjmw6xkwizd3m9bqsgnhaj56xgkz1pcmv00pmj275";
    url = "https://hackage.haskell.org";
    ver = "1.9.1.3";
  };
  drv = { mkDerivation, async, base, Cabal, cabal-doctest, containers
, doctest, first-class-families, hspec, hspec-discover
, inspection-testing, lib, mtl, stm, syb, template-haskell
, th-abstraction, transformers, type-errors, unagi-chan
}:
mkDerivation {
  pname = "polysemy";
  version = "1.9.1.3";
  src = /nix/store/184xbj3g4w50pz6q56cslj0sd7lwr60s-source;
  setupHaskellDepends = [ base Cabal cabal-doctest ];
  libraryHaskellDepends = [
    async base containers first-class-families mtl stm syb
    template-haskell th-abstraction transformers type-errors unagi-chan
  ];
  testHaskellDepends = [
    async base containers doctest first-class-families hspec
    hspec-discover inspection-testing mtl stm syb template-haskell
    th-abstraction transformers type-errors unagi-chan
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/polysemy-research/polysemy#readme";
  description = "Higher-order, low-boilerplate free monads";
  license = lib.licenses.bsd3;
}
;
}
;
  polysemy-chronos = {
  meta = {
    sha256 = "1h5rqyxpmjslqz145y5qa75fww9iqlrnilpvp6bbk5kz2sz935rz";
    url = "https://hackage.haskell.org";
    ver = "0.5.0.0";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.5.0.0";
  src = /nix/store/j66sgvfj60p0x1687k307997j6hlnxh9-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "Polysemy effects for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-conc = {
  meta = {
    sha256 = "0lzgw6dqhw0dv00bn9aasys2v8iddxyck5vmpglrp92chba55jxv";
    url = "https://hackage.haskell.org";
    ver = "0.14.1.0";
  };
  drv = { mkDerivation, async, base, hedgehog, incipit-core, lib, polysemy
, polysemy-plugin, polysemy-resume, polysemy-test, polysemy-time
, stm, stm-chans, tasty, tasty-hedgehog, time, torsor, unagi-chan
}:
mkDerivation {
  pname = "polysemy-conc";
  version = "0.14.1.0";
  src = /nix/store/xi7sav0g2qpr85z5k0ds7k7f5w5b16gj-source;
  libraryHaskellDepends = [
    async base incipit-core polysemy polysemy-resume polysemy-time stm
    stm-chans torsor unagi-chan
  ];
  testHaskellDepends = [
    async base hedgehog incipit-core polysemy polysemy-plugin
    polysemy-test polysemy-time tasty tasty-hedgehog time torsor
  ];
  homepage = "https://github.com/tek/polysemy-conc#readme";
  description = "Polysemy effects for concurrency";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "12kzq6910qwj7n1rwym3zibjm5cv7llfgk9iagcwd16vfysag6wp";
    url = "https://hackage.haskell.org";
    ver = "0.5.0.0";
  };
  drv = { mkDerivation, aeson, ansi-terminal, base, bytestring
, case-insensitive, composition, containers, data-default, either
, hedgehog, http-client, http-client-tls, http-types, lens, lib
, network, polysemy, polysemy-log, polysemy-plugin, relude, servant
, servant-client, servant-server, string-interpolate, tasty
, tasty-hedgehog, template-haskell, text, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.5.0.0";
  src = /nix/store/ifrq4jlfz4k7m424xji5dml9ni6c11g7-source;
  libraryHaskellDepends = [
    aeson ansi-terminal base bytestring case-insensitive composition
    containers data-default either http-client http-client-tls
    http-types lens polysemy polysemy-log polysemy-plugin relude
    string-interpolate template-haskell text time
  ];
  testHaskellDepends = [
    aeson ansi-terminal base bytestring case-insensitive composition
    containers data-default either hedgehog http-client http-client-tls
    http-types lens network polysemy polysemy-log polysemy-plugin
    relude servant servant-client servant-server string-interpolate
    tasty tasty-hedgehog template-haskell text time warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy Effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-log = {
  meta = {
    sha256 = "09jdy3jzry31knaydjqka0mj8jwscdys5wq2xij21lxbxr5msy1m";
    url = "https://hackage.haskell.org";
    ver = "0.11.1.0";
  };
  drv = { mkDerivation, ansi-terminal, async, base, incipit-core, lib
, polysemy, polysemy-conc, polysemy-plugin, polysemy-test
, polysemy-time, stm, tasty, time
}:
mkDerivation {
  pname = "polysemy-log";
  version = "0.11.1.0";
  src = /nix/store/5j242iz4v4jac7f008bm2fwy4rrrpij7-source;
  libraryHaskellDepends = [
    ansi-terminal async base incipit-core polysemy polysemy-conc
    polysemy-time stm time
  ];
  testHaskellDepends = [
    base incipit-core polysemy polysemy-conc polysemy-plugin
    polysemy-test polysemy-time tasty time
  ];
  benchmarkHaskellDepends = [
    base incipit-core polysemy polysemy-conc polysemy-plugin
  ];
  homepage = "https://github.com/tek/polysemy-log#readme";
  description = "Polysemy effects for logging";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-plugin = {
  meta = {
    sha256 = "18y0nfx7x7am7cvj9wwhzal9bqv6sj7ckvmkd16blx4c2nqyikp9";
    url = "https://hackage.haskell.org";
    ver = "0.4.5.2";
  };
  drv = { mkDerivation, base, Cabal, cabal-doctest, containers, doctest
, ghc, ghc-tcplugins-extra, hspec, hspec-discover
, inspection-testing, lib, polysemy, should-not-typecheck, syb
, transformers
}:
mkDerivation {
  pname = "polysemy-plugin";
  version = "0.4.5.2";
  src = /nix/store/l68cq0g74sq0ws1plbgva2ry1psk5s21-source;
  setupHaskellDepends = [ base Cabal cabal-doctest ];
  libraryHaskellDepends = [
    base containers ghc ghc-tcplugins-extra polysemy syb transformers
  ];
  testHaskellDepends = [
    base containers doctest ghc ghc-tcplugins-extra hspec
    hspec-discover inspection-testing polysemy should-not-typecheck syb
    transformers
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/polysemy-research/polysemy#readme";
  description = "Disambiguate obvious uses of effects";
  license = lib.licenses.bsd3;
}
;
}
;
  polysemy-process = {
  meta = {
    sha256 = "125fiwq30ybncmc0pb25ki3k2sxbhkjz4k2i53bcj9y026xgvjyi";
    url = "https://hackage.haskell.org";
    ver = "0.14.1.0";
  };
  drv = { mkDerivation, async, base, hedgehog, incipit-core, lib, path
, path-io, polysemy, polysemy-conc, polysemy-plugin
, polysemy-resume, polysemy-test, polysemy-time, posix-pty, process
, stm-chans, tasty, tasty-expected-failure, tasty-hedgehog
, typed-process, unix
}:
mkDerivation {
  pname = "polysemy-process";
  version = "0.14.1.0";
  src = /nix/store/y60m0pnnmkma31bwwjzx3hrpa9jy136f-source;
  libraryHaskellDepends = [
    async base incipit-core path path-io polysemy polysemy-conc
    polysemy-resume polysemy-time posix-pty process stm-chans
    typed-process unix
  ];
  testHaskellDepends = [
    async base hedgehog incipit-core polysemy polysemy-conc
    polysemy-plugin polysemy-resume polysemy-test polysemy-time tasty
    tasty-expected-failure tasty-hedgehog typed-process unix
  ];
  homepage = "https://github.com/tek/polysemy-conc#readme";
  description = "Polysemy effects for system processes";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-resume = {
  meta = {
    sha256 = "1i2bnpd3l357jhln8xl92z65b3mskz9y8z1xlha4lm0m855qyk15";
    url = "https://hackage.haskell.org";
    ver = "0.9.0.1";
  };
  drv = { mkDerivation, base, incipit-core, lib, polysemy, polysemy-plugin
, polysemy-test, stm, tasty, transformers
}:
mkDerivation {
  pname = "polysemy-resume";
  version = "0.9.0.1";
  src = /nix/store/mxw7kjiqx9gr4p06crj2j0f34rkdrdqn-source;
  libraryHaskellDepends = [
    base incipit-core polysemy transformers
  ];
  testHaskellDepends = [
    base incipit-core polysemy polysemy-plugin polysemy-test stm tasty
  ];
  homepage = "https://github.com/tek/polysemy-resume#readme";
  description = "Polysemy error tracking";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-test = {
  meta = {
    sha256 = "1m6ncbihr742765rshz6w7dn450f3d2ip6ci3qah27lnz7yrwmp6";
    url = "https://hackage.haskell.org";
    ver = "0.7.0.0";
  };
  drv = { mkDerivation, base, hedgehog, incipit-core, lib, path, path-io
, polysemy, tasty, tasty-hedgehog, transformers
}:
mkDerivation {
  pname = "polysemy-test";
  version = "0.7.0.0";
  src = /nix/store/sfg27fyv2wgz98lnh6p89krb5sz21dzn-source;
  enableSeparateDataOutput = true;
  libraryHaskellDepends = [
    base hedgehog incipit-core path path-io polysemy tasty
    tasty-hedgehog transformers
  ];
  testHaskellDepends = [
    base hedgehog incipit-core path polysemy tasty
  ];
  homepage = "https://github.com/tek/polysemy-test#readme";
  description = "Polysemy Effects for Testing";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-time = {
  meta = {
    sha256 = "1ay0ym01wznk98km2ksw8slj52gc7rav6n16z4sndzsw7cdwdq2y";
    url = "https://hackage.haskell.org";
    ver = "0.6.0.0";
  };
  drv = { mkDerivation, aeson, base, incipit-core, lib, polysemy-test
, tasty, template-haskell, time, torsor
}:
mkDerivation {
  pname = "polysemy-time";
  version = "0.6.0.0";
  src = /nix/store/cpli49vw3sc8vdh8vc747jvidvaag1d4-source;
  libraryHaskellDepends = [
    aeson base incipit-core template-haskell time torsor
  ];
  testHaskellDepends = [
    base incipit-core polysemy-test tasty time
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "Polysemy effects for time";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    url = "https://hackage.haskell.org";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  reflection = {
  meta = {
    sha256 = "0xiivs8grfnp896hznp6rfx09d86mfyaaxvnslgmjl626520ac8p";
    url = "https://hackage.haskell.org";
    ver = "2.1.9";
  };
  drv = { mkDerivation, base, containers, hspec, hspec-discover, lib
, QuickCheck, template-haskell
}:
mkDerivation {
  pname = "reflection";
  version = "2.1.9";
  src = /nix/store/7m41a6nyd52mk5dbmvm25dp9d4w0kg85-source;
  libraryHaskellDepends = [ base template-haskell ];
  testHaskellDepends = [ base containers hspec QuickCheck ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://github.com/ekmett/reflection";
  description = "Reifies arbitrary terms into types that can be reflected back into terms";
  license = lib.licenses.bsd3;
}
;
}
;
  relude = {
  meta = {
    sha256 = "0nv2cp8wngzi1yszp0pvqi35ii0l63x7y78h5ha938qc8shza2ap";
    url = "https://hackage.haskell.org";
    ver = "1.2.2.2";
  };
  drv = { mkDerivation, base, bytestring, containers, deepseq, doctest
, ghc-prim, Glob, hashable, hedgehog, lib, mtl, stm, tasty-bench
, text, transformers, unordered-containers
}:
mkDerivation {
  pname = "relude";
  version = "1.2.2.2";
  src = /nix/store/1nqd3r57pm9fxn1nlp6yshirngsnzyj1-source;
  libraryHaskellDepends = [
    base bytestring containers deepseq ghc-prim hashable mtl stm text
    transformers unordered-containers
  ];
  testHaskellDepends = [
    base bytestring containers doctest Glob hedgehog text
  ];
  benchmarkHaskellDepends = [
    base tasty-bench unordered-containers
  ];
  homepage = "https://github.com/kowainik/relude";
  description = "Safe, performant, user-friendly and lightweight Haskell Standard Library";
  license = lib.licenses.mit;
}
;
}
;
  servant = {
  meta = {
    sha256 = "0w01g2vnawsk5gpf8sw4p7wss650jg60kglmp93bnfqzyc8i1awh";
    url = "https://hackage.haskell.org";
    ver = "0.20.2";
  };
  drv = { mkDerivation, aeson, attoparsec, base, bifunctors, bytestring
, case-insensitive, constraints, containers, deepseq, hspec
, hspec-discover, http-api-data, http-media, http-types, lib
, mmorph, mtl, network-uri, QuickCheck, quickcheck-instances
, singleton-bool, sop-core, text, transformers, vault
}:
mkDerivation {
  pname = "servant";
  version = "0.20.2";
  src = /nix/store/a5i4g6vf8n6bhbv88qni5bwn61xmn6bp-source;
  libraryHaskellDepends = [
    aeson attoparsec base bifunctors bytestring case-insensitive
    constraints containers deepseq http-api-data http-media http-types
    mmorph mtl network-uri QuickCheck singleton-bool sop-core text
    transformers vault
  ];
  testHaskellDepends = [
    aeson base bytestring hspec http-media mtl QuickCheck
    quickcheck-instances text
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://docs.servant.dev/";
  description = "A family of combinators for defining webservices APIs";
  license = lib.licenses.bsd3;
}
;
}
;
  servant-client = {
  meta = {
    sha256 = "0iv254h277vfmmwq14807bcdwyi0xccs6dl5k75gqgwn3aawza11";
    url = "https://hackage.haskell.org";
    ver = "0.20";
  };
  drv = { mkDerivation, aeson, base, base-compat, bytestring, containers
, deepseq, entropy, exceptions, hspec, hspec-discover
, http-api-data, http-client, http-media, http-types, HUnit
, kan-extensions, lib, markdown-unlit, monad-control, mtl, network
, QuickCheck, semigroupoids, servant, servant-client-core
, servant-server, sop-core, stm, text, time, transformers
, transformers-base, transformers-compat, wai, warp
}:
mkDerivation {
  pname = "servant-client";
  version = "0.20";
  src = /nix/store/7bvfhl7ya7gw94xpz2wgjfsfznkgcsjw-source;
  libraryHaskellDepends = [
    base base-compat bytestring containers deepseq exceptions
    http-client http-media http-types kan-extensions monad-control mtl
    semigroupoids servant servant-client-core stm text time
    transformers transformers-base transformers-compat
  ];
  testHaskellDepends = [
    aeson base base-compat bytestring entropy hspec http-api-data
    http-client http-types HUnit kan-extensions markdown-unlit mtl
    network QuickCheck servant servant-client-core servant-server
    sop-core stm text transformers transformers-compat wai warp
  ];
  testToolDepends = [ hspec-discover markdown-unlit ];
  homepage = "http://docs.servant.dev/";
  description = "Automatic derivation of querying functions for servant";
  license = lib.licenses.bsd3;
}
;
}
;
  servant-client-core = {
  meta = {
    sha256 = "0wwla0yxrs9q7f9lmlifhmx2ph49isagd2mpz6pxnw9nfvnpvdns";
    url = "https://hackage.haskell.org";
    ver = "0.20.2";
  };
  drv = { mkDerivation, aeson, base, base-compat, base64-bytestring
, bytestring, constraints, containers, deepseq, exceptions, free
, hspec, hspec-discover, http-media, http-types, lib, network-uri
, QuickCheck, safe, servant, sop-core, template-haskell, text
}:
mkDerivation {
  pname = "servant-client-core";
  version = "0.20.2";
  src = /nix/store/w7rapa7zsz27bjayyg36n1858901mwhi-source;
  libraryHaskellDepends = [
    aeson base base-compat base64-bytestring bytestring constraints
    containers deepseq exceptions free http-media http-types
    network-uri safe servant sop-core template-haskell text
  ];
  testHaskellDepends = [ base base-compat deepseq hspec QuickCheck ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://docs.servant.dev/";
  description = "Core functionality and class for client function generation for servant APIs";
  license = lib.licenses.bsd3;
}
;
}
;
  servant-server = {
  meta = {
    sha256 = "1xp86ha73fkqbsxyycr0wga0k106vfb4kpjyzh055l2qb47kyj9j";
    url = "https://hackage.haskell.org";
    ver = "0.20.2";
  };
  drv = { mkDerivation, aeson, base, base-compat, base64-bytestring
, bytestring, constraints, containers, directory, exceptions
, filepath, hspec, hspec-discover, hspec-wai, http-api-data
, http-media, http-types, lib, monad-control, mtl, network
, resourcet, safe, servant, should-not-typecheck, sop-core, tagged
, temporary, text, transformers, transformers-base, wai
, wai-app-static, wai-extra, warp, word8
}:
mkDerivation {
  pname = "servant-server";
  version = "0.20.2";
  src = /nix/store/1h5crkb17rn2sswhf313f28ngk7chpfz-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base base64-bytestring bytestring constraints containers exceptions
    filepath http-api-data http-media http-types monad-control mtl
    network resourcet servant sop-core tagged text transformers
    transformers-base wai wai-app-static word8
  ];
  executableHaskellDepends = [
    aeson base base-compat text wai warp
  ];
  testHaskellDepends = [
    aeson base base-compat base64-bytestring bytestring directory hspec
    hspec-wai http-types mtl resourcet safe servant
    should-not-typecheck temporary text wai wai-extra
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://docs.servant.dev/";
  description = "A family of combinators for defining webservices APIs and serving them";
  license = lib.licenses.bsd3;
  mainProgram = "greet";
}
;
}
;
  string-interpolate = {
  meta = {
    sha256 = "0vvcdd9m7z6rxqcf39xdjaz7hv0hbkkxvcpnyxcvldrsqzlhy3r8";
    url = "https://hackage.haskell.org";
    ver = "0.3.4.0";
  };
  drv = { mkDerivation, base, bytestring, criterion, deepseq, formatting
, haskell-src-exts, haskell-src-meta, hspec, hspec-core
, interpolate, lib, neat-interpolation, QuickCheck
, quickcheck-instances, quickcheck-text, quickcheck-unicode, split
, template-haskell, text, text-conversions, unordered-containers
, utf8-string
}:
mkDerivation {
  pname = "string-interpolate";
  version = "0.3.4.0";
  src = /nix/store/igp843v0k826h11znzsjqlig3sbk4as6-source;
  libraryHaskellDepends = [
    base bytestring haskell-src-exts haskell-src-meta split
    template-haskell text text-conversions utf8-string
  ];
  testHaskellDepends = [
    base bytestring hspec hspec-core QuickCheck quickcheck-instances
    quickcheck-text quickcheck-unicode template-haskell text
    unordered-containers
  ];
  benchmarkHaskellDepends = [
    base bytestring criterion deepseq formatting interpolate
    neat-interpolation QuickCheck text
  ];
  homepage = "https://gitlab.com/williamyaoh/string-interpolate/blob/master/README.md";
  description = "Haskell string/text/bytestring interpolation that just works";
  license = lib.licenses.bsd3;
}
;
}
;
  tasty = {
  meta = {
    sha256 = "1jqrcmibqv03109qc6lhi2jnip4mxygcd0j4j0g1n0q0akcplica";
    url = "https://hackage.haskell.org";
    ver = "1.5.2";
  };
  drv = { mkDerivation, ansi-terminal, base, containers, lib
, optparse-applicative, stm, tagged, transformers, unix
}:
mkDerivation {
  pname = "tasty";
  version = "1.5.2";
  src = /nix/store/ly5d0sscd0dwlyr06nqhyscj3a99j8np-source;
  libraryHaskellDepends = [
    ansi-terminal base containers optparse-applicative stm tagged
    transformers unix
  ];
  homepage = "https://github.com/UnkindPartition/tasty";
  description = "Modern and extensible testing framework";
  license = lib.licenses.mit;
}
;
}
;
  tasty-expected-failure = {
  meta = {
    sha256 = "1dplg5n7rv8azy7xysl0z85inicvcxwprf5n9lh5k12lki5i1hdc";
    url = "https://hackage.haskell.org";
    ver = "0.12.3";
  };
  drv = { mkDerivation, base, hedgehog, lib, tagged, tasty, tasty-golden
, tasty-hedgehog, tasty-hunit, unbounded-delays
}:
mkDerivation {
  pname = "tasty-expected-failure";
  version = "0.12.3";
  src = /nix/store/qrh487167vrz6d983f0kxwkgicvf4nj9-source;
  libraryHaskellDepends = [ base tagged tasty unbounded-delays ];
  testHaskellDepends = [
    base hedgehog tasty tasty-golden tasty-hedgehog tasty-hunit
  ];
  homepage = "http://github.com/nomeata/tasty-expected-failure";
  description = "Mark tasty tests as failure expected";
  license = lib.licenses.mit;
}
;
}
;
  tasty-hedgehog = {
  meta = {
    sha256 = "04kg2qdnsqzzmj3xggy2jcgidlp21lsjkz4sfnbq7b1yhrv2vbbc";
    url = "https://hackage.haskell.org";
    ver = "1.4.0.2";
  };
  drv = { mkDerivation, base, hedgehog, lib, tagged, tasty
, tasty-expected-failure
}:
mkDerivation {
  pname = "tasty-hedgehog";
  version = "1.4.0.2";
  src = /nix/store/b9mxq4fh65sif22q9a4g041jvp847cyc-source;
  libraryHaskellDepends = [ base hedgehog tagged tasty ];
  testHaskellDepends = [
    base hedgehog tasty tasty-expected-failure
  ];
  homepage = "https://github.com/qfpl/tasty-hedgehog";
  description = "Integration for tasty and hedgehog";
  license = lib.licenses.bsd3;
}
;
}
;
  terminal-size = {
  meta = {
    sha256 = "0rc3z6nf8189zk014nna568sg2hpxmyqlv6ha1y0fhpw9m8872bk";
    url = "https://hackage.haskell.org";
    ver = "0.3.0";
  };
  drv = { mkDerivation, base, lib }:
mkDerivation {
  pname = "terminal-size";
  version = "0.3.0";
  src = /nix/store/30gxy9s75lhldcjbg7h55ql3x21538ln-source;
  libraryHaskellDepends = [ base ];
  description = "Get terminal window height and width";
  license = lib.licenses.bsd3;
}
;
}
;
  text-conversions = {
  meta = {
    sha256 = "0lfcp2f8ld46cry5wm2afcn362mb7fp28ii3afji7bns1fvhh6lf";
    url = "https://hackage.haskell.org";
    ver = "0.3.1.1";
  };
  drv = { mkDerivation, base, base16-bytestring, base64-bytestring
, bytestring, hspec, hspec-discover, lib, text
}:
mkDerivation {
  pname = "text-conversions";
  version = "0.3.1.1";
  src = /nix/store/jwh6vj5a4l3kbhlvicra77pg738sskrv-source;
  libraryHaskellDepends = [
    base base16-bytestring base64-bytestring bytestring text
  ];
  testHaskellDepends = [ base bytestring hspec text ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/cjdev/text-conversions";
  description = "Safe conversions between textual types";
  license = lib.licenses.isc;
}
;
}
;
  time-manager = {
  meta = {
    sha256 = "1lw1xx9p5qqznrg04s7phki2rljxzx29z2xcd9qa46wjhhg54fds";
    url = "https://hackage.haskell.org";
    ver = "0.3.1.1";
  };
  drv = { mkDerivation, base, containers, hspec, HUnit, lib, stm }:
mkDerivation {
  pname = "time-manager";
  version = "0.3.1.1";
  src = /nix/store/1k5zhmfykz5ll7wsixwccd6l2vsd1j65-source;
  libraryHaskellDepends = [ base containers stm ];
  testHaskellDepends = [ base hspec HUnit ];
  homepage = "http://github.com/yesodweb/wai";
  description = "Scalable timer";
  license = lib.licenses.mit;
}
;
}
;
  tls = {
  meta = {
    sha256 = "11rxsmwhv6g4298a0355v6flz4n6gw64qw3iha7z0ka3nv7vq4vv";
    url = "https://hackage.haskell.org";
    ver = "2.1.6";
  };
  drv = { mkDerivation, asn1-encoding, asn1-types, async, base
, base16-bytestring, bytestring, cereal, crypton, crypton-x509
, crypton-x509-store, crypton-x509-validation, data-default
, hourglass, hspec, hspec-discover, lib, memory, mtl, network
, QuickCheck, serialise, transformers, unix-time
}:
mkDerivation {
  pname = "tls";
  version = "2.1.6";
  src = /nix/store/4g184asmh7zbkamx91k1s3r6mflsvh8w-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    asn1-encoding asn1-types base base16-bytestring bytestring cereal
    crypton crypton-x509 crypton-x509-store crypton-x509-validation
    data-default memory mtl network serialise transformers unix-time
  ];
  testHaskellDepends = [
    asn1-types async base bytestring crypton crypton-x509
    crypton-x509-validation hourglass hspec QuickCheck serialise
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/haskell-tls/hs-tls";
  description = "TLS protocol native implementation";
  license = lib.licenses.bsd3;
}
;
}
;
  torsor = {
  meta = {
    sha256 = "07p05f7j6h99pxx1v4j0ya5py4nc93gnbj09pdhl23i2zc75064f";
    url = "https://hackage.haskell.org";
    ver = "0.1";
  };
  drv = { mkDerivation, base, lib }:
mkDerivation {
  pname = "torsor";
  version = "0.1";
  src = /nix/store/320q6gfv9fnpxnxcrckmsblkqvirm8bp-source;
  libraryHaskellDepends = [ base ];
  homepage = "https://github.com/andrewthad/torsor#readme";
  description = "Torsor Typeclass";
  license = lib.licenses.bsd3;
}
;
}
;
  unliftio = {
  meta = {
    sha256 = "0cp92d9f2hzya636y7w8m0gw7ik6ri2clzpdnz5klh917nnbd7ii";
    url = "https://hackage.haskell.org";
    ver = "0.2.25.1";
  };
  drv = { mkDerivation, async, base, bytestring, containers, deepseq
, directory, filepath, gauge, hspec, lib, process, QuickCheck
, safe-exceptions, stm, time, transformers, unix, unliftio-core
}:
mkDerivation {
  pname = "unliftio";
  version = "0.2.25.1";
  src = /nix/store/ijkdj9swchdhsz5dg7vsvzwpfh5kinfc-source;
  libraryHaskellDepends = [
    async base bytestring deepseq directory filepath process
    safe-exceptions stm time transformers unix unliftio-core
  ];
  testHaskellDepends = [
    async base bytestring containers deepseq directory filepath hspec
    process QuickCheck safe-exceptions stm time transformers unix
    unliftio-core
  ];
  benchmarkHaskellDepends = [
    async base bytestring deepseq directory filepath gauge process
    safe-exceptions stm time transformers unix unliftio-core
  ];
  homepage = "https://github.com/fpco/unliftio/tree/master/unliftio#readme";
  description = "The MonadUnliftIO typeclass for unlifting monads to IO (batteries included)";
  license = lib.licenses.mit;
}
;
}
;
  wai = {
  meta = {
    sha256 = "1vxagql34hjvnrw0116kx6z5wnj4gcddf36kfs65f6zr2ib6c11l";
    url = "https://hackage.haskell.org";
    ver = "3.2.4";
  };
  drv = { mkDerivation, base, bytestring, hspec, hspec-discover, http-types
, lib, network, text, vault
}:
mkDerivation {
  pname = "wai";
  version = "3.2.4";
  src = /nix/store/7h7d6p4j6rf8rh6mkgqxh05dmb88mwdl-source;
  libraryHaskellDepends = [
    base bytestring http-types network text vault
  ];
  testHaskellDepends = [ base bytestring hspec ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/yesodweb/wai";
  description = "Web Application Interface";
  license = lib.licenses.mit;
}
;
}
;
  wai-app-static = {
  meta = {
    sha256 = "1kwvzy9w4v76q5bk4xwq7kz9q9l8867my6zvsv731x6xkhy7wr2c";
    url = "https://hackage.haskell.org";
    ver = "3.1.9";
  };
  drv = { mkDerivation, base, blaze-html, blaze-markup, bytestring
, containers, crypton, directory, file-embed, filepath, hspec
, http-date, http-types, lib, memory, mime-types, mockery
, old-locale, optparse-applicative, template-haskell, temporary
, text, time, transformers, unix-compat, unordered-containers, wai
, wai-extra, warp, zlib
}:
mkDerivation {
  pname = "wai-app-static";
  version = "3.1.9";
  src = /nix/store/k3rzn1agy7w5d6qw9254ymn7caq4b8l4-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base blaze-html blaze-markup bytestring containers crypton
    directory file-embed filepath http-date http-types memory
    mime-types old-locale optparse-applicative template-haskell text
    time transformers unix-compat unordered-containers wai wai-extra
    warp zlib
  ];
  executableHaskellDepends = [ base ];
  testHaskellDepends = [
    base bytestring filepath hspec http-date http-types mime-types
    mockery temporary text transformers unix-compat wai wai-extra zlib
  ];
  homepage = "http://www.yesodweb.com/book/web-application-interface";
  description = "WAI application for static serving";
  license = lib.licenses.mit;
  mainProgram = "warp";
}
;
}
;
  wai-extra = {
  meta = {
    sha256 = "19arbw49dz0fbyv5ybyx8v30b340d47p1nwbpp61dfdd71wkvhn0";
    url = "https://hackage.haskell.org";
    ver = "3.1.14";
  };
  drv = { mkDerivation, aeson, ansi-terminal, base, base64-bytestring
, bytestring, call-stack, case-insensitive, containers, cookie
, data-default-class, directory, fast-logger, hspec, hspec-discover
, http-types, HUnit, iproute, lib, network, resourcet
, streaming-commons, temporary, text, time, transformers, unix
, vault, wai, wai-logger, warp, word8, zlib
}:
mkDerivation {
  pname = "wai-extra";
  version = "3.1.14";
  src = /nix/store/r7wq7nw8yn291b1n43gl9d3bn8r4pama-source;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson ansi-terminal base base64-bytestring bytestring call-stack
    case-insensitive containers cookie data-default-class directory
    fast-logger http-types HUnit iproute network resourcet
    streaming-commons text time transformers unix vault wai wai-logger
    warp word8
  ];
  testHaskellDepends = [
    aeson base bytestring case-insensitive cookie directory fast-logger
    hspec http-types HUnit iproute resourcet temporary text time wai
    warp word8 zlib
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "http://github.com/yesodweb/wai";
  description = "Provides some basic WAI handlers and middleware";
  license = lib.licenses.mit;
}
;
}
;
  wai-logger = {
  meta = {
    sha256 = "1l0gspzbwkrs1dqay2rv5wz1gg49a31l3vyl741b2j2apkgamf3p";
    url = "https://hackage.haskell.org";
    ver = "2.5.0";
  };
  drv = { mkDerivation, base, byteorder, bytestring, fast-logger
, http-types, lib, network, wai
}:
mkDerivation {
  pname = "wai-logger";
  version = "2.5.0";
  src = /nix/store/80ds0alfmnajyql6zb5yrw2wqfa0hp48-source;
  libraryHaskellDepends = [
    base byteorder bytestring fast-logger http-types network wai
  ];
  description = "A logging system for WAI";
  license = lib.licenses.bsd3;
}
;
}
;
  warp = {
  meta = {
    sha256 = "0n937l9dfb77mh0rjah72gsiclar7wbn9fcr09x19hx1nnmwcfda";
    url = "https://hackage.haskell.org";
    ver = "3.3.25";
  };
  drv = { mkDerivation, array, auto-update, base, bsb-http-chunked
, bytestring, case-insensitive, containers, directory, gauge
, ghc-prim, hashable, hspec, hspec-discover, http-client, http-date
, http-types, http2, iproute, lib, network, process, QuickCheck
, recv, simple-sendfile, stm, streaming-commons, text, time-manager
, unix, unix-compat, unliftio, vault, wai, word8, x509
}:
mkDerivation {
  pname = "warp";
  version = "3.3.25";
  src = /nix/store/bllclrs9ffqwflv6c8g46vas76vlvzz9-source;
  libraryHaskellDepends = [
    array auto-update base bsb-http-chunked bytestring case-insensitive
    containers ghc-prim hashable http-date http-types http2 iproute
    network recv simple-sendfile stm streaming-commons text
    time-manager unix unix-compat unliftio vault wai word8 x509
  ];
  testHaskellDepends = [
    array auto-update base bsb-http-chunked bytestring case-insensitive
    containers directory ghc-prim hashable hspec http-client http-date
    http-types http2 iproute network process QuickCheck recv
    simple-sendfile stm streaming-commons text time-manager unix
    unix-compat unliftio vault wai word8 x509
  ];
  testToolDepends = [ hspec-discover ];
  benchmarkHaskellDepends = [
    auto-update base bytestring containers gauge hashable http-date
    http-types network recv time-manager unix unix-compat unliftio x509
  ];
  homepage = "http://github.com/yesodweb/wai";
  description = "A fast, light-weight web server for WAI applications";
  license = lib.licenses.mit;
}
;
}
;
  x509 = {
  meta = {
    sha256 = "1pld1yx0fl6g4bzqfx147xipl3kzfx6pz8q4difw2k0kg0qj6xar";
    url = "https://hackage.haskell.org";
    ver = "1.7.7";
  };
  drv = { mkDerivation, asn1-encoding, asn1-parse, asn1-types, base
, bytestring, containers, cryptonite, hourglass, lib, memory, mtl
, pem, tasty, tasty-quickcheck, transformers
}:
mkDerivation {
  pname = "x509";
  version = "1.7.7";
  src = /nix/store/s399rqyyqzq4xjqbyc6lc4585191crgq-source;
  libraryHaskellDepends = [
    asn1-encoding asn1-parse asn1-types base bytestring containers
    cryptonite hourglass memory pem transformers
  ];
  testHaskellDepends = [
    asn1-types base bytestring cryptonite hourglass mtl tasty
    tasty-quickcheck
  ];
  homepage = "http://github.com/vincenthz/hs-certificate";
  description = "X509 reader and writer";
  license = lib.licenses.bsd3;
}
;
}
;
  zeugma = {
  meta = {
    sha256 = "14k0lq3ghanvxw47g43vvzfw4d9cm04bmc2fn5cp4y3vslflaknj";
    url = "https://hackage.haskell.org";
    ver = "0.10.0.1";
  };
  drv = { mkDerivation, base, chronos, hedgehog, incipit, lib, polysemy
, polysemy-chronos, polysemy-process, polysemy-test, tasty
, tasty-expected-failure, tasty-hedgehog
}:
mkDerivation {
  pname = "zeugma";
  version = "0.10.0.1";
  src = /nix/store/m96zcriwkbli759fplm7hk85amz929pr-source;
  libraryHaskellDepends = [
    base chronos hedgehog incipit polysemy polysemy-chronos
    polysemy-process polysemy-test tasty tasty-expected-failure
    tasty-hedgehog
  ];
  homepage = "https://github.com/tek/incipit#readme";
  description = "Polysemy effects for testing";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
min-extends-ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
profiled-extends-ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
wayland-test-extends-ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
x11-extends-ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
x11-test-extends-ghc912 = {
  polysemy-chronos = {
  meta = {
    sha256 = "1gc17p8xj77y0b8hjkbmsgw2ih5396mzlc6cjw5jmrviigsw726k";
    ver = "0.7.0.1";
  };
  drv = { mkDerivation, base, chronos, incipit-core, lib, polysemy-test
, polysemy-time, tasty
}:
mkDerivation {
  pname = "polysemy-chronos";
  version = "0.7.0.1";
  src = /nix/store/9ak6ggpj2yvh253phy9vdy62gylf8xci-source;
  libraryHaskellDepends = [
    base chronos incipit-core polysemy-time
  ];
  testHaskellDepends = [
    base chronos incipit-core polysemy-test polysemy-time tasty
  ];
  homepage = "https://github.com/tek/polysemy-time#readme";
  description = "A Polysemy effect for Chronos";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  polysemy-http = {
  meta = {
    sha256 = "0ii0ldlr2j4mby6x9l04jxwnf06r71kb8smnqk2hwjhaapai37pq";
    ver = "0.13.1.0";
  };
  drv = { mkDerivation, aeson, base, case-insensitive, exon, hedgehog
, http-client, http-client-tls, http-types, lib, network, polysemy
, polysemy-plugin, prelate, servant, servant-client, servant-server
, tasty, tasty-hedgehog, time, warp
}:
mkDerivation {
  pname = "polysemy-http";
  version = "0.13.1.0";
  src = /nix/store/7bb0n2i5c8cgf3xyjvki147vw3kcmz4h-source;
  libraryHaskellDepends = [
    aeson base case-insensitive exon http-client http-client-tls
    http-types polysemy polysemy-plugin prelate time
  ];
  testHaskellDepends = [
    aeson base exon hedgehog http-client network polysemy
    polysemy-plugin prelate servant servant-client servant-server tasty
    tasty-hedgehog warp
  ];
  homepage = "https://github.com/tek/polysemy-http#readme";
  description = "Polysemy effects for HTTP clients";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  prelate = {
  meta = {
    sha256 = "0id72rbynmbb15ld8pv8nijll3k50x2mrpcqsv8dkbs7q05fn9vg";
    ver = "0.8.0.0";
  };
  drv = { mkDerivation, aeson, base, exon, extra, generic-lens, incipit
, lib, microlens, microlens-ghc, polysemy-chronos, polysemy-conc
, polysemy-log, polysemy-process, polysemy-resume, polysemy-time
, template-haskell
}:
mkDerivation {
  pname = "prelate";
  version = "0.8.0.0";
  src = /nix/store/lcscd0phqsi00p0x86vhkpd8krkwf5bz-source;
  libraryHaskellDepends = [
    aeson base exon extra generic-lens incipit microlens microlens-ghc
    polysemy-chronos polysemy-conc polysemy-log polysemy-process
    polysemy-resume polysemy-time template-haskell
  ];
  homepage = "https://github.com/tek/prelate#readme";
  description = "A Prelude";
  license = "BSD-2-Clause-Patent";
}
;
}
;
};
}