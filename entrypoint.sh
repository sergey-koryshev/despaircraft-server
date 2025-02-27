#!/bin/bash

XMX=${XMX:-2G}
XMS=${XMS:-2G}
rconDefaultPassword="RconPassword12345"
enableRconPropertyName="enable-rcon"
rconPasswordPropertyName="rcon\.password"
rconPortPropertyName="rcon\.port"

cleanup() { 
  echo "Received exiting signal"

  if [ "$(getServerPropertyValue "$enableRconPropertyName")" == "true" ] && [ "$(getServerPropertyValue "$rconPasswordPropertyName")" != "" ]; then
    echo "Server will be stopped by mcrcon tool..."
    exec /usr/local/bin/mcrcon/mcrcon -H localhost -P "$(getServerPropertyValue $rconPortPropertyName)" -p "$(getServerPropertyValue "$rconPasswordPropertyName")" "say Server is shutting down..." save-all stop
  fi
}

getServerPropertyValue() {
  echo "$(sed -nE 's/^'"$1"'=(.*)$/\1/p' server.properties)"
}

setServerPropertyValue() {
  sed server.properties -e '/^'"$1"'/s/=.*$/='"$2"'/' > /tmp/modified_properties && cp /tmp/modified_properties server.properties
}

trap cleanup EXIT SIGINT SIGTERM

if [ "$(getServerPropertyValue "$enableRconPropertyName")" == "false" ]; then
  echo "Enabling rcon..."
  setServerPropertyValue "$enableRconPropertyName" "true"
fi

if [ "$(getServerPropertyValue "$rconPasswordPropertyName")" == "" ]; then
  echo "Rcon password is empty, setting default one..."
  setServerPropertyValue "$rconPasswordPropertyName" "$rconDefaultPassword"
fi

java -Xmx"$XMX" -Xms"$XMS" -jar minecraft_server.jar --nogui &

PID=$(pidof java)
wait $PID