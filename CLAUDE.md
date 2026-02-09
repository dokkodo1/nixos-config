# NixOS Multi-Host Flake Configuration

## Repo Structure
```
flake.nix                          # Entry point - auto-discovers hosts, builds NixOS/Darwin systems
hosts/
  default/                         # Template host (username=CHANGEME, repoName=nixos-config)
  desktop/                         # Gaming desktop - AMD GPU, dwl (was KDE), gaming+starCitizen
  nixtop/                          # Laptop - Intel GPU, dwl, gaming, remote builders, tailscale
  hpl-tower/                       # Server - gitlab, tailscale, remote builder server
  hpl-macmini/                     # macOS Darwin host (username=callummcdonald)
modules/
  nixos/
    default.nix                    # Imports: dotfiles, options, settings, systemPackages
    options/                       # control.* option modules (display, gaming, gpu, audio, etc.)
    settings/                      # Always-applied: users, networking, ssh, bluetooth, nix, etc.
  darwin/                          # macOS-specific (mirrors nixos/ structure)
  dotfiles/                        # Shared dotfiles: nvim, zsh, tmux, vim, qutebrowser, waybar, foot
  programs/                        # Standalone program modules (NOT auto-imported): blender, llm, podman, qbt, vscode
  systemPackages.nix               # Common packages for all hosts (tree, git, gh, nh, gcc, etc.)
pkgs/                              # Custom packages: tmux-default, tmux-powerkit
secrets/                           # sops-encrypted secrets (secrets.yaml)
```

## Key Architecture
- **Flake**: Auto-discovers hosts via `builtins.readDir ./hosts`, filters Linux vs Darwin by `meta.nix` system field
- **Host vars**: Each host has `meta.nix` with `{ system, username, locale, timezone, repoName }`
- **specialArgs**: `{ inputs, hostVars, modPath }` passed to all modules
- **control.\* options**: Custom option tree under `config.control` for toggling features
- **home-manager**: Integrated via `home-manager.users.${hostVars.username}` throughout modules
- **Rebuilds**: Uses `nh` (NH_FLAKE env var set to ~/configurations)
- **Username**: `dokkodo` on all Linux hosts

## control.* Option Map
| Option | File | What it does |
|--------|------|-------------|
| `control.display.dwl.enable` | `options/display.nix` | DWL wayland compositor + foot + waybar + wmenu |
| `control.display.kde.enable` | `options/display.nix` | Plasma 6 + SDDM + kitty terminal |
| `control.display.i3wm.enable` | `options/display.nix` | i3wm X11 + startx (no DM) + xterm |
| `control.audio.enable` | `options/audio.nix` | Pipewire (pulse+jack), 48kHz/256q |
| `control.audio.pavucontrol.enable` | `options/audio.nix` | pavucontrol GUI |
| `control.audio.proAudio.*` | `options/audio.nix` | REAPER, yabridge, musnix RT kernel |
| `control.gaming.enable` | `options/gaming.nix` | Steam, gamescope, gamemode, wine, protonup |
| `control.gaming.starCitizen.enable` | `options/gaming.nix` | nix-citizen + lug-helper |
| `control.gaming.launchers.{heroic,lutris}` | `options/gaming.nix` | Game launchers |
| `control.gpuVendor` | `options/gpu.nix` | "amd"/"nvidia"/"intel"/null - driver setup |
| `control.virtualization.*` | `options/virtualization.nix` | libvirt/QEMU/KVM, GPU passthrough, Looking Glass |
| `control.tailscale.*` | `options/tailscale.nix` | Tailscale VPN with sops auth key |
| `control.gitlab.*` | `options/gitlab.nix` | Self-hosted GitLab + cloudflared tunnel + nginx |
| `control.remoteBuilders.*` | `options/remote-builders.nix` | Nix distributed builds (client/server) |

## Desktop Host (Current Focus)
File: `hosts/desktop/configuration.nix`
- AMD GPU (`control.gpuVendor = "amd"`)
- DWL enabled (`control.display.dwl.enable = true`) - was previously KDE
- Gaming + Star Citizen + Lutris
- `services.xserver.enable = true` with modesetting (in host config)
- `programs.firefox.enable = true`
- caps:swapescape via XKB_DEFAULT_OPTIONS
- systemd-boot, EFI

## Known Issues / Active Context
- **DWL mod key**: DWL defaults to Alt (Mod1). User wants Super (Mod4). Requires custom build with patched config.h. User tried and failed before - shelved for now.
- **DWL on desktop**: Desktop host has `services.xserver.enable = true` in host config. If switching back to DWL, need to handle/disable display managers explicitly or gamescope sessions could hijack boot.
- Desktop host `services.xserver.videoDrivers = ["modesetting"]` conflicts with `gpu.nix` setting `services.xserver.videoDrivers = ["amdgpu"]` when `gpuVendor = "amd"`. Both use mkMerge so NixOS will merge the lists, but this is likely unintentional - modesetting in host config is probably leftover from before the gpu module existed.

## Nixtop Host (Reference for DWL)
File: `hosts/nixtop/configuration.nix`
- Same DWL setup, no gaming display manager conflict (no xserver.enable in host config)
- Intel GPU (i915 kernel modules, intel-vaapi-driver)
- Uses qutebrowser as default browser (xdg.mime)
- Has remote builders configured (uses hpl-tower)

## Module Notes
- `modules/programs/` files are NOT auto-imported - they must be explicitly imported by hosts
- `modules/dotfiles/` IS auto-imported by both nixos and darwin via their default.nix
- Waybar config at `dotfiles/waybar/config.jsonc` has hardcoded width=1366 (laptop resolution)
- Foot terminal config at `dotfiles/foot/foot.ini` is minimal (font + alpha)
- The flake overlay references `inputs.nixpkgs-local` which is commented out in inputs - will cause eval error if overlay is reached
