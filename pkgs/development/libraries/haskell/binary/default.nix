{ cabal }:

cabal.mkDerivation (self: {
  pname = "binary";
  version = "0.6.1.0";
  sha256 = "0d423k37973f5v9mz9401zmsfdgspnf9h6s9xgr3zh19giz7c3js";
  meta = {
    homepage = "https://github.com/kolmodin/binary";
    description = "Binary serialisation for Haskell values using lazy ByteStrings";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
