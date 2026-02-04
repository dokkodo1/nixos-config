{ pkgs, userVars, ... }:

{
  users.users.${userVars.username} = {
    description = "${userVars.username}";
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$URFMsTnfViKbG3CrNGoIt1$OhNNXxGab2ec8fIPomqP/nQrsAfzwRP2bZWEooL5s1C";
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

  i18n.defaultLocale = "${userVars.locale}";
  i18n.extraLocaleSettings.LC_ALL = "${userVars.locale}";
  time.timeZone = "${userVars.timezone}";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

	environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
	};
}
