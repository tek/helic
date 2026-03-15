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
  chronos = {
  meta = {
    sha256 = "037h68ji0f362irn9n9qwvr7d1ff6inpbc8d5wa4d63223713k9m";
    url = "https://hackage.haskell.org";
    ver = "1.1.6.1";
  };
  drv = { mkDerivation, aeson, attoparsec, base, bytebuild, byteslice
, bytesmith, bytestring, criterion, deepseq, hashable, HUnit, lib
, natural-arithmetic, old-locale, primitive, QuickCheck
, test-framework, test-framework-hunit, test-framework-quickcheck2
, text, text-short, thyme, time, torsor, vector
}:
mkDerivation {
  pname = "chronos";
  version = "1.1.6.1";
  src = /nix/store/94b0vp25iyp98kyinilv23im02h4xkpx-source;
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
  exon = {
  meta = {
    sha256 = "1m4i3a14wip985ncblfy2ikcy7gw5rryj9z497ah218d1nmwj7rl";
    url = "https://hackage.haskell.org";
    ver = "1.4.0.0";
  };
  drv = { mkDerivation, base, criterion, flatparse, generics-sop
, ghc-hs-meta, hedgehog, incipit-base, lib, tasty, tasty-hedgehog
, template-haskell
}:
mkDerivation {
  pname = "exon";
  version = "1.4.0.0";
  src = /nix/store/rrbiqj1v72nbkwd2nqkd303sczq1h63y-source;
  libraryHaskellDepends = [
    base flatparse generics-sop ghc-hs-meta incipit-base
    template-haskell
  ];
  testHaskellDepends = [
    base hedgehog incipit-base tasty tasty-hedgehog template-haskell
  ];
  benchmarkHaskellDepends = [ base criterion incipit-base ];
  homepage = "https://git.tryp.io/tek/exon";
  description = "Customizable Quasiquote Interpolation";
  license = "BSD-2-Clause-Patent";
}
;
}
;
  flatparse = {
  meta = {
    sha256 = "0z9q5qb3yz4phvj1wq06dld745m98yk4gvkmj1vkq7hda0mn182a";
    url = "https://hackage.haskell.org";
    ver = "0.4.1.0";
  };
  drv = { mkDerivation, attoparsec, base, bytestring, containers, gauge
, hspec, HUnit, integer-gmp, lib, megaparsec, parsec, primitive
, QuickCheck, quickcheck-instances, template-haskell, utf8-string
}:
mkDerivation {
  pname = "flatparse";
  version = "0.4.1.0";
  src = /nix/store/8cqbb3d6f4x8g2knirf5v3fcjjydqxmy-source;
  libraryHaskellDepends = [
    base bytestring containers integer-gmp template-haskell utf8-string
  ];
  testHaskellDepends = [
    base bytestring hspec HUnit QuickCheck quickcheck-instances
    utf8-string
  ];
  benchmarkHaskellDepends = [
    attoparsec base bytestring gauge integer-gmp megaparsec parsec
    primitive utf8-string
  ];
  homepage = "https://github.com/AndrasKovacs/flatparse#readme";
  description = "High-performance parsing from strict bytestrings";
  license = lib.licenses.mit;
}
;
}
;
  generics-sop = {
  meta = {
    sha256 = "0ai089kly1cajn4djqnplkg2jmnapqlb3crrsyvfnadcyzc9h3km";
    url = "https://hackage.haskell.org";
    ver = "0.5.1.4";
  };
  drv = { mkDerivation, base, criterion, deepseq, ghc-prim, lib, sop-core
, template-haskell, th-abstraction
}:
mkDerivation {
  pname = "generics-sop";
  version = "0.5.1.4";
  src = /nix/store/qky7s4rv2qdyxl5wx3jbd5c46j7bglrx-source;
  libraryHaskellDepends = [
    base ghc-prim sop-core template-haskell th-abstraction
  ];
  testHaskellDepends = [ base ];
  benchmarkHaskellDepends = [
    base criterion deepseq template-haskell
  ];
  description = "Generic Programming using True Sums of Products";
  license = lib.licenses.bsd3;
}
;
}
;
  ghc-hs-meta = {
  meta = {
    sha256 = "19z2704dl6x4lkgfaynhn550wdghpj9qdwh5xr96drp3nkh012dl";
    url = "https://hackage.haskell.org";
    ver = "0.1.5.0";
  };
  drv = { mkDerivation, base, bytestring, ghc, ghc-boot, hspec, lib
, template-haskell
}:
mkDerivation {
  pname = "ghc-hs-meta";
  version = "0.1.5.0";
  src = /nix/store/7abpm6lm194m0f4xd576kc9lf2qp7py3-source;
  libraryHaskellDepends = [
    base bytestring ghc ghc-boot template-haskell
  ];
  testHaskellDepends = [
    base bytestring ghc ghc-boot hspec template-haskell
  ];
  description = "Translate Haskell source to Template Haskell expression";
  license = lib.licenses.bsd3;
}
;
}
;
  incipit = {
  meta = {
    sha256 = "1r3y2wp8wz1ii28a6wb76z6w3sgiah158kwsadrr13w6iryhq047";
    url = "https://hackage.haskell.org";
    ver = "0.10.0.0";
  };
  drv = { mkDerivation, base, incipit-core, lib, polysemy-conc
, polysemy-log, polysemy-resume, polysemy-time
}:
mkDerivation {
  pname = "incipit";
  version = "0.10.0.0";
  src = /nix/store/vsgx9m5cgsyvd8hvznamavar6ca2q0x8-source;
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
    sha256 = "1phzwj2ig0vx1anscg3qv53ysa0f7gks37pc8gfkh2aws3qp6cda";
    url = "https://hackage.haskell.org";
    ver = "0.11.0.0";
  };
  drv = { mkDerivation, ansi-terminal, async, base, incipit-core, lib
, polysemy, polysemy-conc, polysemy-plugin, polysemy-test
, polysemy-time, stm, tasty, time
}:
mkDerivation {
  pname = "polysemy-log";
  version = "0.11.0.0";
  src = /nix/store/gw84zb1ni89amkmir10g2mp458hbpqan-source;
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
    sha256 = "1c2agk21jj7fwdj6xkagq0prvxknp3zr6q1f480wizssibcvm7y6";
    url = "https://hackage.haskell.org";
    ver = "0.4.5.3";
  };
  drv = { mkDerivation, base, Cabal, cabal-doctest, containers, doctest
, ghc, ghc-tcplugins-extra, hspec, hspec-discover
, inspection-testing, lib, polysemy, should-not-typecheck, syb
, transformers
}:
mkDerivation {
  pname = "polysemy-plugin";
  version = "0.4.5.3";
  src = /nix/store/vhdv7p7lqiarmgai5l0n44yqgczljkb5-source;
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
  zeugma = {
  meta = {
    sha256 = "16rv92l40bhrpf4mdj3f39wqb483jgj3jzkgckanfy4z6nfglirm";
    url = "https://hackage.haskell.org";
    ver = "0.10.0.0";
  };
  drv = { mkDerivation, base, chronos, hedgehog, incipit, lib, polysemy
, polysemy-chronos, polysemy-process, polysemy-test, tasty
, tasty-expected-failure, tasty-hedgehog
}:
mkDerivation {
  pname = "zeugma";
  version = "0.10.0.0";
  src = /nix/store/8cwd9ai48728lyhx9x09k2pbb4p0zjap-source;
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
min = {
};
profiled = {
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