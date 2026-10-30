{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [ "x86_64-linux" ];

      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      nixosModules.default = import ./module/default.nix;

      lib.mkChromium =
        { pkgs, lib }:
        import ./module/wrapper.nix { inherit pkgs lib; };

      lib.mkExtensions =
        {
          pkgs,
          lib,
          settings ? { },
        }:
        import ./extensions { inherit pkgs lib settings; };

      packages = eachSystem (
        pkgs:
        nixpkgs.lib.mapAttrs (_: extension: extension.extension) (
          self.lib.mkExtensions {
            inherit pkgs;
            lib = pkgs.lib;
          }
        )
      );

      checks = eachSystem (
        pkgs:
        nixpkgs.lib.mapAttrs'
          (
            name: extension:
            nixpkgs.lib.nameValuePair name (
              pkgs.runCommand "check-${name}-${extension.version}" { } ''
                ${pkgs.jq}/bin/jq -e .manifest_version ${extension.extension}/manifest.json > /dev/null
                touch $out
              ''
            )
          )
          (
            self.lib.mkExtensions {
              inherit pkgs;
              lib = pkgs.lib;
            }
          )
      );
    };
}
