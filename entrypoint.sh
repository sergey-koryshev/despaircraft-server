#!/bin/bash
set -e

XMX=${XMX:-2G}
XMS=${XMS:-2G}
RCONPASSWORD=${RCONPASSWORD}

enableRconPropertyName="enable-rcon"
rconPasswordPropertyName="rcon\.password"
rconPortPropertyName="rcon\.port"

cleanup() { 
  echo "Received exiting signal: $1"

  if [ "$(getServerPropertyValue "$enableRconPropertyName")" == "true" ] && [ "$(getServerPropertyValue "$rconPasswordPropertyName")" != "" ]; then
    if pidof java > /dev/null; then
      echo "Server will be stopped by mcrcon tool..."
      exec /usr/local/bin/mcrcon/mcrcon -H localhost -P "$(getServerPropertyValue "$rconPortPropertyName")" -p "$(getServerPropertyValue "$rconPasswordPropertyName")" "say Server is shutting down..." save-all stop || echo "Warning: mcrcon failed to stop server gracefully"
    else
      echo "Server is not running, exiting..."
      exit 0
    fi
  fi
}

getServerPropertyValue() {
  echo "$(sed -nE 's/^'"$1"'=(.*)$/\1/p' /minecraft/server.properties)"
}

setServerPropertyValue() {
  local key="$1"
  local value="$2"
  local file="/minecraft/server.properties"
  local tmpfile="/minecraft/server.properties.tmp"

  if grep -q "^$key=" "$file"; then
    echo "Setting '$key' in '$file'"
    sed "$file" -e "/^$key/s/=.*$/=$value/" > "$tmpfile" && mv "$tmpfile" "$file"
  else
    echo "Adding '$key' to '$file'"
    echo "$key=$value" >> "$file"
  fi

  chmod 755 "$file"
}

trap 'cleanup EXIT' EXIT
trap 'cleanup SIGINT' SIGINT
trap 'cleanup SIGTERM' SIGTERM

if [ "$(getServerPropertyValue "$enableRconPropertyName")" == "false" ]; then
  echo "RCON is disabled in server.properties, enabling it..."
  setServerPropertyValue "$enableRconPropertyName" "true"
fi

if [ "$(getServerPropertyValue "$rconPasswordPropertyName")" == "" ]; then
  echo "RCON password is empty in server.properties"

  if [ -z "$RCONPASSWORD" ]; then
    RCONPASSWORD=$(openssl rand -base64 12)
    echo "Using random RCON password: $RCONPASSWORD"
  else
    echo "Using provided RCON password"
  fi

  setServerPropertyValue "$rconPasswordPropertyName" "$RCONPASSWORD"
fi

echo "Starting Minecraft server at $(date)..."
java -Xmx"$XMX" -Xms"$XMS" -jar minecraft_server.jar --nogui &

PID=$(pidof java)
wait $PID