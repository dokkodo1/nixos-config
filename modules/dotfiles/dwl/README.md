# DWL Local Build

This is dwl 0.8-dev with XWayland enabled. Edit `config.h` and recompile - that's the suckless way.

## What's what

- `config.h` - your config, edit this one
- `config.def.h` - upstream defaults, useful for reference when things break
- `config.mk` - build flags (XWayland is enabled here)

## Editing and testing

Get into the dev shell first (has all the build deps):

```bash
nix develop ~/configurations#dwl
cd ~/configurations/modules/dotfiles/dwl
```

Then the usual:

```bash
vim config.h
make clean && make
```

To test, you'll need to run `./dwl` from a different TTY (Ctrl+Alt+F2) since you can't nest dwl inside itself.

## Deploying for real

Once you're happy:

```bash
nh os switch
```

Then log out and back in. The rebuild uses this same `config.h`.

## Common things to change

In `config.h`:
- `MODKEY` - modifier key (default is Super)
- `termcmd` - terminal command
- `keys[]` - keybindings
- `bordercolor`, `focuscolor` - colors
- `monrules[]` - monitor setup

## If things go wrong

**Build fails after pulling upstream changes?**
Your `config.h` probably has outdated options. Diff it against the new `config.def.h`.

**"Cannot open display"?**
You're trying to run dwl from inside dwl. Use a different TTY.

**Missing headers?**
You're not in the dev shell. Run `nix develop ~/configurations#dwl` first.

## Patches

Check [codeberg.org/dwl/dwl-patches](https://codeberg.org/dwl/dwl-patches) for community patches (gaps, bar, IPC, etc).

Apply with `patch -p1 < whatever.patch`, rebuild, test, commit if it works.
