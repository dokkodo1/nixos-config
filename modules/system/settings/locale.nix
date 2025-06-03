{ config, lib, pkgs, userSettings, ... }:

{

  time.timeZone = userSettings.timezone; # time zone
  i18n.defaultLocale = userSettings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = userSettings.locale;
    LC_IDENTIFICATION = userSettings.locale;
    LC_MEASUREMENT = userSettings.locale;
    LC_MONETARY = userSettings.locale;
    LC_NAME = userSettings.locale;
    LC_NUMERIC = userSettings.locale;
    LC_PAPER = userSettings.locale;
    LC_TELEPHONE = userSettings.locale;
    LC_TIME = userSettings.locale;
  };
}
