{ pkgs, hostVars, ... }:

{
  users.users.${hostVars.username} = {
    description = "${hostVars.username}";
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$URFMsTnfViKbG3CrNGoIt1$OhNNXxGab2ec8fIPomqP/nQrsAfzwRP2bZWEooL5s1C";
 		shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsKo172kR/4LdraCvjeeQbeTCv7LHm7p5L9w7Ih2CQ0 callum.dokkodo@gmail.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDd84Rfiov8cODuIRDFDCIlOrJ6oumWeslCkSKK1O8TeTNb+Qq4sS3bDQlGfzPxCqYMPJ46YhhGIcgz0GEKhAeBi2oAsZlsUsiB2q9DujTSpS8Tn/I+JjtHOiP5ITZUL/F8iLzSYDNQYRJtnhxNIe7J+ulCVIgumMFCAg1tefDkONHdyE4wXaPMDD363lnNFFO7DgsGr9EW8a4ULT1AIWxPaZ/HKF99P61NduZHU8JJS+RNkAuHbURjEU9IVNvLPmwZVMcHgBkGGDIVklhQPGAI80vYEebExfbxsGPE5vgTdkxjqtVkmzWMldTXB+bMExJBw0k/j+sWB+BG9QjQwgcEm+Cjvuth2v1O30fdAXQNGD127JgUHNjBnoePtTYlukaBRtRSCuxcz3cSncNweDdAmj40wpLiFQfKA2edYZbHP3iibWq1sPYEdFD26cUOCAtgtXJQ14JgwW8rE7cT070LaGsPq5i1wOqOGbZUzHWPejZgQaLB3c4VKkT9aeuQC81Ay/6/b/kHKDIwvqzJCd2IwdZV5hY80zVO83Naeyehzvi/gwkdKB51B/Y3wn5P48bWMN/Am2dVl3nwVq41fT3A1ApfuoUkB3NVIzOYcM9Wc3jhJMzXkwF51B8tBD4zBYQoawPrUEJjLaTQMp74d74mdOTIC4A7gob/nnLRV/Y1Bw== dokkodo1@proton.me"
    ];
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

  i18n.defaultLocale = "${hostVars.locale}";
  i18n.extraLocaleSettings.LC_ALL = "${hostVars.locale}";
  time.timeZone = "${hostVars.timezone}";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

	environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
	};
}
