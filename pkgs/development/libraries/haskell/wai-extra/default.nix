{ cabal, ansiTerminal, blazeBuilder, blazeBuilderConduit
, caseInsensitive, conduit, dataDefault, dateCache, fastLogger
, httpTypes, network, resourcet, stringsearch, text, time
, transformers, void, wai, waiLogger, zlibConduit
}:

cabal.mkDerivation (self: {
  pname = "wai-extra";
  version = "1.3.0.2";
  sha256 = "0w69wjfbzgg523n0rcs700qx0gsdhvlr0qjvqg1hppvi188llpwl";
  buildDepends = [
    ansiTerminal blazeBuilder blazeBuilderConduit caseInsensitive
    conduit dataDefault dateCache fastLogger httpTypes network
    resourcet stringsearch text time transformers void wai waiLogger
    zlibConduit
  ];
  meta = {
    homepage = "http://github.com/yesodweb/wai";
    description = "Provides some basic WAI handlers and middleware";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
