{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
let
  tomlFmt = pkgs.formats.toml { };
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    type = tomlFmt.type;
    default = { };
    description = ''
      Configuration for `wofr`.

      This is written to a TOML file and passed to `wofr --config`.
    '';
    example = {
      entire = {
        agents = [ "opencode" ];
        checkpoint_remote = "github:rencire/wofr-checkpoints";
      };
    };
  };

  config = {
    flags."--config" = config.constructFiles.generatedConfig.path;
    constructFiles.generatedConfig = {
      content = builtins.toJSON config.settings;
      relPath = "${config.binName}-config.toml";
      builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
    };
    meta.maintainers = [ wlib.maintainers.birdee ];
  };
}
