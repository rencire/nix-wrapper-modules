{
  pkgs,
  self,
  ...
}:
let
  fakeWofr = pkgs.writeShellApplication {
    name = "wofr";
    text = ''
      printf '%s\n' "$@"
    '';
  };

  wrapped = self.wrappers.wofr.wrap {
    inherit pkgs;
    package = fakeWofr;
    settings = {
      entire = {
        agents = [ "opencode" "codex" ];
        checkpoint_remote = "github:rencire/test-checkpoints";
      };
    };
  };
in
pkgs.runCommand "wofr-wrapper-test" { } ''
  output="$(${wrapped}/bin/wofr entire-init)"

  test "$(printf '%s' "$output" | sed -n '1p')" = "--config"
  config_path="$(printf '%s' "$output" | sed -n '2p')"
  test "$(printf '%s' "$output" | sed -n '3p')" = "entire-init"

  test -f "$config_path"
  grep -F 'agents = ["opencode", "codex"]' "$config_path"
  grep -F 'checkpoint_remote = "github:rencire/test-checkpoints"' "$config_path"

  touch "$out"
''
