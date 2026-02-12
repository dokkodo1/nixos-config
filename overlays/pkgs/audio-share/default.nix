{ pkgs, ... }:

pkgs.writeShellScriptBin "audio-share" ''
  state_dir="/tmp/audio-share"
  mic_pid_file="$state_dir/mic-loopback.pid"
  desktop_pid_file="$state_dir/desktop-loopback.pid"

  kill_pid_file() {
    if [ -f "$1" ] && kill -0 $(cat "$1") 2>/dev/null; then
      kill $(cat "$1") 2>/dev/null
    fi
    rm -f "$1"
  }

  case "$1" in
    on)
      if [ -f "$desktop_pid_file" ] && kill -0 $(cat "$desktop_pid_file") 2>/dev/null; then
        echo "Already sharing."
        exit 0
      fi

      # Verify ts-audio-mix null sink exists
      if ! ${pkgs.pipewire}/bin/pw-cli list-objects Node 2>/dev/null | grep -q 'node.name = "ts-audio-mix"'; then
        echo "Error: ts-audio-mix sink not found. Try restarting PipeWire:"
        echo "  systemctl --user restart pipewire pipewire-pulse wireplumber"
        exit 1
      fi

      mkdir -p "$state_dir"

      # Mic -> mix loopback
      ${pkgs.pipewire}/bin/pw-loopback \
        --capture-props='node.name=mic-to-mix node.description="Microphone Share" node.passive=true' \
        --playback-props='node.name=mic-to-mix-out node.description="Microphone Share" node.target=ts-audio-mix' &
      echo "$!" > "$mic_pid_file"
      disown

      # Desktop audio -> mix loopback
      ${pkgs.pipewire}/bin/pw-loopback \
        --capture-props='stream.capture.sink=true node.name=desktop-to-mix node.description="Desktop Audio Share" node.passive=true' \
        --playback-props='node.name=desktop-to-mix-out node.description="Desktop Audio Share" node.target=ts-audio-mix' &
      echo "$!" > "$desktop_pid_file"
      disown

      echo "Audio sharing on (mic + desktop -> ts-audio-mix)."
      ;;
    off)
      kill_pid_file "$desktop_pid_file"
      kill_pid_file "$mic_pid_file"
      rm -rf "$state_dir"
      echo "Audio sharing off."
      ;;
    *)
      echo "Usage: audio-share [on|off]"
      ;;
  esac
''
