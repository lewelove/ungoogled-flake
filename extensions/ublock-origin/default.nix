{
  pkgs,
  lib,
  settings ? { },
}:
let
  version = "1.75.0";

  filterText =
    raw:
    if builtins.isPath raw then builtins.readFile raw else raw;

  normalizeFilters =
    raw:
    if builtins.isList raw then
      raw
    else
      lib.filter (line: line != "") (lib.splitString "\n" (filterText raw));

  userFilters = normalizeFilters (settings.userFilters or "");

  adminSettingsPolicy = lib.optionalAttrs (settings ? adminSettings) {
    adminSettings = builtins.toJSON settings.adminSettings;
  };

  toOverwrite =
    lib.optionalAttrs (settings ? filterLists) {
      inherit (settings) filterLists;
    }
    // lib.optionalAttrs (settings ? userFilters) {
      filters = userFilters;
    };

  managedSettings = adminSettingsPolicy // lib.optionalAttrs (toOverwrite != { }) {
    inherit toOverwrite;
  };

  chromiumExtension = pkgs.stdenv.mkDerivation {
    pname = "ublock-origin";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
      hash = "sha256-OTz5VwnRB01AIpcOkBTkNDlcU6giOH8eJfQ76Xz0tYI=";
    };

    nativeBuildInputs = [ pkgs.unzip ];
    unpackPhase = "unzip $src -d .";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r uBlock0.chromium/* $out/

      substituteInPlace $out/js/vapi-background.js \
        --replace-fail \
          "bin = await vAPI.storage.get('cachedManagedStorage') || {};" \
          "bin = {};"

      runHook postInstall
    '';
  };

  chromiumExtensionId =
    let
      hex = builtins.substring 0 32 (builtins.hashString "sha256" "${chromiumExtension}");

      hexDigit =
        c:
        builtins.head (
          builtins.filter (i: builtins.substring i 1 "0123456789abcdef" == c) (builtins.genList (i: i) 16)
        );
    in
    builtins.concatStringsSep "" (
      builtins.genList (
        i: builtins.substring (hexDigit (builtins.substring i 1 hex)) 1 "abcdefghijklmnop"
      ) 32
    );

  policy = {
    "3rdparty".extensions.${chromiumExtensionId} = managedSettings;
  };
in
{
  name = "ublock-origin";
  inherit version;

  extension = chromiumExtension;
  id = chromiumExtensionId;
  inherit policy;
}
