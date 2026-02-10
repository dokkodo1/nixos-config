{ pkgs, lib, hostVars, ... }:

let
  hasGitConfig = hostVars.gitUsername != null;
  hasGhConfig = hostVars.githubUsername != null;
in
{
  environment.systemPackages = lib.optionals hasGhConfig [ pkgs.gh ];

  home-manager.users.${hostVars.username} = lib.mkMerge [
    (lib.mkIf hasGitConfig {
      programs.git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user = {
            name = hostVars.gitUsername;
            email = lib.mkIf (hostVars.gitEmail != null) hostVars.gitEmail;
          };
          init.defaultBranch = "main";
          pull.rebase = false;
          push.autoSetupRemote = true;
          core.editor = "nvim";
        };
      };
    })

    (lib.mkIf hasGhConfig {
      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
          aliases = {
            co = "pr checkout";
            pv = "pr view";
          };
        };
      };
    })
  ];
}
