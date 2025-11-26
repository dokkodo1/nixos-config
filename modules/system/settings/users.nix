{ pkgs, username, ... }:

{
  users.users.${username} = {
    description = "${username}";
    isNormalUser = true;
 		shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "users"
      "networkmanager"
    ];
  };

  i18n.defaultLocale = "en_ZA.UTF-8";
  i18n.extraLocaleSettings.LC_ALL = "en_US.UTF-8"; 
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

	environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
	};
}
