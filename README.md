# DespairCraft Server

This repository contains Dockerfile to run pure Fabric Minecraft server in Docker.

## Docker container shutdown

The server is configured to be gracefully exited on container shutdown process by tool [mcrcon by Tiiffi](https://github.com/Tiiffi/mcrcon), if you map your own `server.properties`, make sure the file has the following properties set:

```
enable-rcon=true
rcon.password=SomePassword
```

or ensure that the file is available for writing and the properties will be set automatically (in this case password for rcon will be `RconPassword12345`).

## Starting container

Container can be started by the following command:

```bash
docker run --init -p 25565:25565 -v $(pwd)/server.properties:/minecraft/server.properties:rw -v $(pwd)/world:/minecraft/world ghcr.io/sergey-koryshev/despaircraft-server:fabric-1.21.4
```

Note, that `--init` parameter is desirable, but not required. Container may work incorrectly without it.

### Customization

You can specify memory limits for running Minecraft server:

```bash
docker run ... -e XMX=5G -e XMS=5G ...
```

Default values for both parameters is `2G`