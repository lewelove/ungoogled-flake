{
  pkgs,
  lib,
}:
let
  version = "1.0";

  extension = pkgs.runCommand "youtube-theater-${version}" { } ''
    mkdir -p $out
    cp ${./manifest.json} $out/manifest.json
    cp ${./background.js} $out/background.js

    ${pkgs.jq}/bin/jq -e . $out/manifest.json > /dev/null
  '';
in
{
  name = "youtube-theater";
  inherit version;

  inherit extension;
}
