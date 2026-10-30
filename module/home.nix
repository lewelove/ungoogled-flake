{ lib, osConfig, ... }:
let
  cfg = osConfig.chromium;

  installed = lib.filterAttrs (_: instance: instance.install) cfg.instances;

  withEntry = lib.filterAttrs (_: instance: instance.desktopEntry) cfg.instances;

  withService = lib.filterAttrs (_: instance: instance.backgroundService) cfg.instances;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = lib.mapAttrsToList (_: instance: instance.package) installed;

    xdg.desktopEntries = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair instance.binary {
        name = if name == cfg.defaultInstance then "Chromium" else "Chromium (${name})";
        genericName = "Web Browser";
        exec = "${instance.binary} %U";
        icon = "chromium";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
      }
    ) withEntry;

    systemd.user.services = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair "${instance.binary}-service" {
        Unit = {
          Description = "Chromium Background Service (${name})";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${instance.package}/bin/${instance.binary} --silent-launch";
          Restart = "on-failure";
          RestartSec = "5s";
        }
        // lib.optionalAttrs (instance.serviceEnvironment != [ ]) {
          Environment = instance.serviceEnvironment;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      }
    ) withService;
  };
}
