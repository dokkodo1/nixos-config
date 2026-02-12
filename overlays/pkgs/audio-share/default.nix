{ pkgs, ... }:

pkgs.writeShellScriptBin "audio-share" ''
  pid_file="/tmp/desktop-audio-share.pid"
  case "$1" in
    on)
      if [ -f "$pid_file" ] && kill -0 $(cat "$pid_file") 2>/dev/null; then
        echo "Already sharing desktop audio."
        exit 0
      fi
      ${pkgs.pipewire}/bin/pw-loopback \
        --capture-props='stream.capture.sink=true node.name=desktop-to-mix node.description="Desktop Audio Share" node.passive=true' \
        --playback-props='node.name=desktop-to-mix-out node.description="Desktop Audio Share" node.target=ts-audio-mix' &
      pid=$!
      disown $pid
      echo "$pid" > "$pid_file"
      echo "Desktop audio sharing on."
      ;;
    off)
      if [ -f "$pid_file" ] && kill -0 $(cat "$pid_file") 2>/dev/null; then
        kill $(cat "$pid_file") 2>/dev/null
        rm "$pid_file"
        echo "Desktop audio sharing off."
      else
        rm -f "$pid_file"
        echo "Not currently sharing desktop audio."
      fi
      ;;
    *)
      echo "Usage: audio-share [on|off]"
      ;;
  esac
''
