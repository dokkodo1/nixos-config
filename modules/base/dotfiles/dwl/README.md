# DWL Configuration

This directory contains your DWL (Dynamic Window Manager for Wayland) configuration.

## Files

- `config.h` - Main DWL configuration (keybindings, colors, rules)
- `flake.nix` - Nix flake for hot reloading DWL builds
- `README.md` - This file

## Hot Reloading

### Quick Changes (Waybar only)
```bash
waybar-reload
```

### DWL Changes (requires recompilation)
1. Edit `config.h` 
2. Run `dwl-reload` to recompile (~10 seconds)
3. Restart your session to use the new binary

### Full System Rebuild
```bash
sudo nixos-rebuild switch
```

## Default Keybindings

- `Super + Enter` - Terminal
- `Super + d` - Application launcher  
- `Super + q` - Quit window
- `Super + 1-9` - Switch to workspace
- `Super + Shift + 1-9` - Move window to workspace
- `Super + h/j/k/l` - Focus window
- `Super + Shift + h/j/k/l` - Move window

## Customization

Edit `config.h` to customize:
- Keybindings
- Colors and borders
- Window rules
- Layouts
- Monitor configuration

The configuration uses standard DWL syntax. See the [DWL documentation](https://codeberg.org/dwl/dwl) for details.