{
  pkgs,
  lib,
  settings ? { },
}:

{
  ublock-origin = import ./ublock-origin {
    inherit pkgs lib;
    settings = settings.ublock-origin or { };
  };

  sponsorblock = import ./sponsorblock {
    inherit pkgs lib;
    settings = settings.sponsorblock or { };
  };

  youtube-theater = import ./youtube-theater { inherit pkgs lib; };
}
