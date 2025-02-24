{ pkgs , ... }:
{
 environment.systemPackages = [
	pkgs.remmina
	pkgs.freerdp
	pkgs.ungoogled-chromium

	pkgs.openfortivpn
  ];
}
