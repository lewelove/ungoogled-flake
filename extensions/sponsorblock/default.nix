{
  pkgs,
  lib,
  settings ? { },
}:
let
  version = "6.1.7";

  rev = "321b1b29a4c2d818d5267ec8a446ab6f8c56c649";

  # Public key pinned in the built manifest, so the extension keeps one ID
  # across versions and does not lose its storage on every bump.
  manifestKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu6pNMR0EXOyD8g9UoF4dchTTed/hIiCVZza04RgYh/aw+RwBvWmdsy61O/xQq8duv4xxPQtO5VYtH7oodM5qJjNbN7e4xIru2DLZH8tTkhDV8QfI3rysHde/GxuJZhElun5k/Cz58Fo49AX/F6ir+OloVtkuOkbvi8vP7+rpKyjJLSY9sKj4vxUxerC2pEM69z9NrGA+zMt38yBco1ZGejqp/sm+QAMPYhcVO07z0+VCOlJab7hfLAT6tB+SW824lnqg3nEdVBtIr6rmVnwbPLhZUlBOSeg5KDU3tDrcYJ3u6uTisAs7tibS/O2g9MFtUZ/WP7ldm8b98Tbv5oD4CQIDAQAB";

  # sha256 of the DER public key, first 128 bits, hex mapped 0-f to a-p
  extensionId = "iccialjkhcgnfhjeealnglajhcabhmbm";

  # Browser export, revisit with the extension's export button. Values passed
  # as `settings` win over it, e.g. { settings = { showUpsells = false; }; }
  imported = builtins.fromJSON (builtins.readFile ./config.json);

  src = pkgs.fetchgit {
    url = "https://github.com/lewelove/SponsorBlock";
    inherit rev;
    fetchSubmodules = true;
    hash = "sha256-tdeRJ2jU/D8VbzDxMRfdYqysr80dla8AIq20v3QB8zc=";
  };

  build = pkgs.buildNpmPackage {
    pname = "sponsorblock";
    inherit version src;

    npmDepsHash = "sha256-Bu4zFSe1UU/bp/pdfwR6379SPPOQr7FO3RWRMzeCwME=";

    # chromedriver downloads a binary at rebuild time; only selenium tests need it
    npmRebuildFlags = [ "--ignore-scripts" ];

    postPatch = ''
      cp config.json.example config.json
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/. $out/

      runHook postInstall
    '';
  };

  # The extension ships its own managed schema. It is the allowlist: identity,
  # server state, progress and device data are absent from it, so `settings`
  # and stale export keys cannot reach the policy.
  schema = builtins.fromJSON (builtins.readFile "${build}/managed_schema.json");

  unsupported = lib.subtractLists (lib.attrNames schema.properties) (lib.attrNames settings);

  managed =
    if unsupported == [ ] then
      declared
    else
      lib.warn "sponsorblock: settings not declarable by the managed schema: ${toString unsupported}" declared;

  declared = lib.filterAttrs (_: value: value != null) (
    lib.intersectAttrs schema.properties (imported // settings)
  );

  extension =
    pkgs.runCommand "sponsorblock-${version}"
      {
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        cp -r ${build}/. $out
        chmod -R u+w $out

        ${pkgs.jq}/bin/jq --arg key "${manifestKey}" \
          '. + {key: $key}' $out/manifest.json > manifest.json
        mv manifest.json $out/manifest.json
      '';
in
{
  name = "sponsorblock";
  inherit version;

  inherit extension;
  id = extensionId;

  policy = {
    "3rdparty".extensions.${extensionId} = managed;
  };
}
