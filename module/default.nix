{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.chromium;

  declaredPolicy =
    extension:
    lib.optionalAttrs (lib.isAttrs extension && extension.policy != null) {
      ${extension.name} = extension.policy;
    };

  instanceExtensionPolicies = lib.concatMap (instance: map declaredPolicy instance.extensions) (
    lib.attrValues cfg.instances
  );

  policies = lib.mergeAttrsList (instanceExtensionPolicies ++ [ cfg.policies ]);
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            dirs = lib.filter (dir: dir != null) (lib.catAttrs "profileDir" (lib.attrValues cfg.instances));
          in
          lib.length dirs == lib.length (lib.unique dirs);
        message = "chromium.instances: profileDir values must be unique";
      }
    ];

    environment.etc = lib.mapAttrs' (
      name: policy:
      lib.nameValuePair "chromium/policies/managed/${name}.json" {
        text = builtins.toJSON policy;
      }
    ) policies;

    home-manager.sharedModules = lib.mkIf (options ? home-manager) [ ./home.nix ];
  };
}
