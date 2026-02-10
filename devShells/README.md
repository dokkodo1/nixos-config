# Dev Shells

Development environments that work both directly from this flake and as importable templates for other projects.

## Direct use

```bash
nix develop ~/configurations#dwl
```

## Using in another project

### With project's own nixpkgs

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dokkodo.url = "github:dokkodo1/nixos-config";
  };

  outputs = { nixpkgs, dokkodo, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = dokkodo.lib.mkShell.dwl pkgs;
    };
}
```

### Reusing the main flake's nixpkgs (saves rebuilds)

```nix
{
  inputs = {
    dokkodo.url = "github:dokkodo1/nixos-config"; # or "path:~/to/this/clone";
    nixpkgs.follows = "dokkodo/nixpkgs";
  };

  outputs = { nixpkgs, dokkodo, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = dokkodo.lib.mkShell.dwl pkgs;
    };
}
```

## Adding a new shell

1. Create `devShells/myshell.nix`:
```nix
{ pkgs }:

pkgs.mkShell {
  packages = with pkgs; [ ... ];
  shellHook = ''
    echo "ready"
  '';
}
```

2. Add to `devShells/default.nix`:
```nix
templates = {
  dwl = pkgs: import ./dwl.nix { inherit pkgs; };
  myshell = pkgs: import ./myshell.nix { inherit pkgs; };
};
```

3. Wire it up in `mkShellsForSystem`:
```nix
# Linux-only (uses glibc, wayland, etc)
myshell = if isLinux then templates.myshell pkgs else null;

# Cross-platform (works on darwin too)
myshell = templates.myshell pkgs;
```

## Available shells

| Shell | Platforms | What's in it |
|-------|-----------|--------------|
| `dwl` | linux | wayland compositor dev (wlroots, etc) |
| `c` | linux | clang, make, gdb, clangd |
| `rust` | all | cargo, rustc, rust-analyzer, clippy |
| `haskell` | all | ghc, cabal, hls, hoogle, hlint |
