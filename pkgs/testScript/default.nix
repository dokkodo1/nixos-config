{ pkgs, ... }:

pkgs.writeShellScriptBin "testScript" ''
  #!/bin/bash
  echo "Hello from my custom script!"
  ${pkgs.neovim}/bin/nvim "$@"
''