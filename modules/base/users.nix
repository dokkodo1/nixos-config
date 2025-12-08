{ pkgs, username, locale, ... }:

{
  users.users.${username} = {
    description = "${username}";
    isNormalUser = true;
 		shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "users"
      "networkmanager"
      "audio"
      "video"
      "input"
      "cpu"
    ];
  };

  i18n.defaultLocale = "${locale}";
  i18n.extraLocaleSettings.LC_ALL = "${locale}"; 
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

	environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
	};
}
