{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.chromium;

  mkChromium = import ./wrapper.nix { inherit pkgs lib; };

  extensionType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Policy file stem, e.g. ublock-origin";
      };

      version = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Extension version, informational";
      };

      extension = lib.mkOption {
        type = lib.types.package;
        description = "Unpacked extension directory";
      };

      id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Extension ID the managed policy is keyed by";
      };

      policy = lib.mkOption {
        type = lib.types.nullOr lib.types.attrs;
        default = null;
        description = "Managed policy document for this extension";
      };
    };
  };

  binaryName = name: if name == cfg.defaultInstance then "chromium" else "chromium-${name}";

  deriveProfileName = name: if name == cfg.defaultInstance then null else "chromium-${name}";

  globalArgs =
    cfg.baseArgs
    ++ lib.optional (
      cfg.trustedOrigins != [ ]
    ) "--unsafely-treat-insecure-origin-as-secure=${lib.concatStringsSep "," cfg.trustedOrigins}"
    ++ lib.optional (
      cfg.disableFeatures != [ ]
    ) "--disable-features=${lib.concatStringsSep "," cfg.disableFeatures}";

  extensionPath = extension: if lib.isAttrs extension then extension.extension else extension;

  instanceArgs =
    instance:
    lib.optionals (instance.extensions != [ ]) [
      "--load-extension=${
        lib.concatMapStringsSep "," (extension: toString (extensionPath extension)) instance.extensions
      }"
    ]
    ++ lib.optional (instance.proxy != null) "--proxy-server=${instance.proxy}";
in
{
  options.chromium = {
    enable = lib.mkEnableOption "Chromium instances";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ungoogled-chromium;
      description = "Chromium package the instances wrap";
    };

    defaultInstance = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = ''
        Instance whose binary is `chromium` and whose profile is Chromium's own.
        Every other instance is `chromium-<name>` with `~/.config/chromium-<name>`.
      '';
    };

    baseArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Command-line arguments passed to every instance";
    };

    trustedOrigins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Origins treated as secure, e.g. http://host.localhost";
    };

    disableFeatures = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Chromium features to disable, merged into a single --disable-features";
    };

    policies = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = { };
      description = "Policy documents, one file per attribute, under /etc/chromium/policies/managed";
    };

    instances = lib.mkOption {
      default = { };
      description = "Chromium instances, each with its own profile and flags";
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, config, ... }: {
            options = {
              profileDir = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Absolute profile directory; null derives one from the instance name";
              };

              extensions = lib.mkOption {
                type = lib.types.listOf (lib.types.either lib.types.package extensionType);
                default = [ ];
                description = ''
                  Extensions loaded via --load-extension; empty loads none.
                  Records carry their own managed policy, bare packages load without one.
                '';
              };

              proxy = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Proxy to force, e.g. socks5://host:port; null adds no flag";
              };

              extraArgs = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Additional command-line arguments";
              };

              install = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Add this instance's wrapper to home.packages";
              };

              desktopEntry = lib.mkOption {
                type = lib.types.bool;
                default = name == cfg.defaultInstance;
                description = "Render a desktop entry for this instance";
              };

              backgroundService = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Run this instance with --silent-launch as a systemd user service";
              };

              serviceEnvironment = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Environment variables for the background service";
              };

              logOutput = lib.mkOption {
                type = lib.types.enum [
                  "discard"
                  "inherit"
                ];
                default = "discard";
                description = "Whether the browser's stdout/stderr is discarded or inherited";
              };

              package = lib.mkOption {
                type = lib.types.package;
                readOnly = true;
                description = "Browser package with this instance's flags baked in";
              };

              binary = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                description = "Binary name of the wrapped browser";
              };
            };

            config = {
              package = mkChromium {
                inherit (config) extensions profileDir logOutput;
                name = binaryName name;
                package = cfg.package;
                profileName = deriveProfileName name;
                args = globalArgs ++ instanceArgs config ++ config.extraArgs;
              };

              binary = binaryName name;
            };
          }
        )
      );
    };
  };
}
