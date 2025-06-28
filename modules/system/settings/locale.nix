{ config, lib, pkgs, userSettings, ... }:

{

  time.timeZone = "Africa/Johannesburg";#userSettings.timezone; # time zone
  i18n.defaultLocale = "en_US.UTF-8";#userSettings.locale;
  #i18n.extraLocaleSettings = {
  #};
}
