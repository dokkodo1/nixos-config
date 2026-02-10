{ pkgs, ... }:

pkgs.writeShellScriptBin "tmux-default" ''
  #!/usr/bin/env bash
  
  SESSION="default"
  
  ${pkgs.tmux}/bin/tmux has-session -t $SESSION 2>/dev/null
  
  if [ $? != 0 ]; then
    ${pkgs.tmux}/bin/tmux new-session -d -s $SESSION
    
    ${pkgs.tmux}/bin/tmux rename-window -t $SESSION:1 'btop'
    ${pkgs.tmux}/bin/tmux send-keys -t $SESSION:1 'btop' C-m
    
    ${pkgs.tmux}/bin/tmux new-window -t $SESSION:2 -n 'nvim'
    ${pkgs.tmux}/bin/tmux send-keys -t $SESSION:2 'cd ~/configurations && nvim' C-m
    
    ${pkgs.tmux}/bin/tmux new-window -t $SESSION:3 -n 'home'
    ${pkgs.tmux}/bin/tmux send-keys -t $SESSION:3 'cd ~ && fastfetch' C-m
    
    ${pkgs.tmux}/bin/tmux select-window -t $SESSION:2
  fi
  
  ${pkgs.tmux}/bin/tmux attach-session -t $SESSION
''
