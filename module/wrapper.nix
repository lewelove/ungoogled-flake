{ pkgs, lib }:
{
  name,
  package ? pkgs.ungoogled-chromium,
  binary ? "chromium",
  args ? [ ],
  extensions ? [ ],
  profileDir ? null,
  profileName ? null,
  logOutput ? "discard",
}:
assert lib.assertMsg (lib.elem logOutput [
  "discard"
  "inherit"
]) "chromium: logOutput must be \"discard\" or \"inherit\"";
assert lib.assertMsg (
  profileDir == null || profileName == null
) "chromium: profileDir and profileName are mutually exclusive";
let
  xdgConfig = "\${XDG_CONFIG_HOME:-$HOME/.config}";

  defaultProfile =
    if profileDir != null then
      profileDir
    else if profileName != null then
      "${xdgConfig}/${profileName}"
    else
      "${xdgConfig}/chromium";

  derivesProfile = profileDir != null || profileName != null;

  preseed = ''
    prefs="$profile/Default/Preferences"
    mkdir -p "$(dirname "$prefs")"

    # --load-extension extensions register as unpacked, which Chromium disables
    # (DISABLE_UNSUPPORTED_DEVELOPER_EXTENSION) unless the
    # extensions.ui.developer_mode pref is set: extension_service.cc:595.
    # The ExtensionDeveloperModeSettings policy can only disallow, never
    # allow, so preseed the pref. Idempotent: no write once it is true.
    if [ -f "$prefs" ]; then
      if ! ${pkgs.jq}/bin/jq -e '.extensions.ui.developer_mode == true' "$prefs" >/dev/null 2>&1; then
        preseed="$(mktemp "$prefs.XXXXXX")"
        ${pkgs.jq}/bin/jq '.extensions.ui.developer_mode = true' "$prefs" > "$preseed"
        mv "$preseed" "$prefs"
      fi
    else
      printf '%s\n' '{"extensions":{"ui":{"developer_mode":true}}}' > "$prefs"
    fi
  '';

  script = ''
    set -euo pipefail

    profile="${defaultProfile}"

    args=(${lib.escapeShellArgs args})
    ${lib.optionalString derivesProfile ''
      args+=("--user-data-dir=$profile")
    ''}
    for arg in "''${args[@]}" "$@"; do
      case "$arg" in
        --user-data-dir=*) profile="''${arg#--user-data-dir=}" ;;
      esac
    done
    ${lib.optionalString (extensions != [ ]) ''

      ${preseed}''}
    exec ${package}/bin/${binary} "''${args[@]}" "$@"${
      lib.optionalString (logOutput == "discard") " >/dev/null 2>&1"
    }
  '';
in
pkgs.writeShellScriptBin name script
