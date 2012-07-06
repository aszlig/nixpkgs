{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "c-ares-${version}";
  version = "1.9.1";

  src = fetchurl {
    url = "http://c-ares.haxx.se/download/c-ares-${version}.tar.gz";
    sha256 = "0dir6y3rsm6720axkpbk1jarh48138wqf0bhr12rd0rg3w02hgq2";
  };

  meta = {
    homepage = http://c-ares.haxx.se/;
    license = stdenv.lib.licenses.mit;
    description = "C library that performs DNS requests and name resolves asynchronously.";
  };
}
