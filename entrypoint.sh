#!/bin/bash

cleanup() { 
  echo "Received exiting signal" 
  exec /usr/local/bin/mcrcon/mcrcon -H localhost -P "$RCON_PORT" -p "$RCON_PASSWORD" "say Server is shutting down..." save-all stop
}

trap cleanup EXIT SIGINT SIGTERM

java -Xmx"$XMX" -Xms"$XMS" -jar minecraft_server.jar --nogui &

PID=$(pidof java)
wait $PID