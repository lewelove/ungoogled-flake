# ungoogled-flake

Ungoogled Chromium with declarative instances and managed extensions.

## Usage

```nix
{
  inputs.ungoogled = {
    url = "github:lewelove/ungoogled-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

```nix
{ inputs, pkgs, lib, ... }:
let
  extensions = inputs.ungoogled.lib.mkExtensions {
    inherit pkgs lib;
    settings.sponsorblock = { alreadyInstalled = true; };
  };
in
{
  imports = [ inputs.ungoogled.nixosModules.default ];

  chromium = {
    enable = true;

    instances.default = {
      extensions = [
        extensions.ublock-origin
        extensions.sponsorblock
      ];
    };

    instances.lan = { };
  };
}
```

## Outputs

| output | purpose |
| --- | --- |
| `nixosModules.default` | options, instance wrappers, managed policies, home-manager wiring |
| `lib.mkChromium` | `{ pkgs, lib } -> args -> package`, one wrapped browser |
| `lib.mkExtensions` | `{ pkgs, lib, settings ? {} } -> extension records` |
| `packages.<system>.<name>` | unpacked extension, `nix build .#ublock-origin` |
| `checks.<system>.<name>` | extension manifest validation |

## Extensions

Each `extensions/<name>/default.nix` takes `{ pkgs, lib }` and returns:

| field | meaning |
| --- | --- |
| `name` | policy file stem, `<name>.json` under `/etc/chromium/policies/managed` |
| `version` | informational |
| `extension` | derivation whose outPath is the unpacked extension |
| `id` | extension ID the managed policy is keyed by, optional |
| `policy` | managed policy document, optional |

Policies are collected from the instances' extensions automatically. Bare
packages are accepted too and load without a managed policy.

`lib.mkExtensions` accepts `settings.<name>` for extensions with knobs, e.g.
`settings.sponsorblock = { alreadyInstalled = true; }`.
