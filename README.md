# DespairCraft Server

This repository contains Dockerfile to run pure Fabric Minecraft server in Docker.

## Building Arguments

The docker file have a few arguments:

| Name | Required | Description |
| - | - | - |
| **FABRIC_SERVER_DOWNLOAD_URL** | Yes | URL to download fabric server |
| **UID** | No | id of user (default value is `25575`) |
| **GID** | No | id of group (default value is `25575`) |

## Docker Container Shutdown

The server is configured to be gracefully exited on container shutdown process by tool [mcrcon by Tiiffi](https://github.com/Tiiffi/mcrcon), if you map your own `server.properties`, make sure the file has the following properties set:

```
enable-rcon=true
rcon.password=SomePassword
```

or ensure that the file is available for writing and the properties will be set automatically (in this case password for rcon will be `RconPassword12345`).

## Docker Container User

The minecraft server is running under non-root user `minecraft_user` (group `minecraft_group`) with prepopulated `UID` and `GID` (`25575` by default for both). If you mount any directories into the container, make sure the user has access to them.

## Starting Container

Container can be started by the following command:

```bash
docker run --init -p 25565:25565 -v $(pwd)/server.properties:/minecraft/server.properties:rw -v $(pwd)/world:/minecraft/world ghcr.io/sergey-koryshev/despaircraft-server:fabric-1.21.4
```

Note, that `--init` parameter is desirable, but not required. Container may work incorrectly without it.

### Customization

You can use the following environment variables to adjust execution of the server:

| Name | Default Value | Description |
| - | - | - |
| XMS | 2G | Initial size of the memory allocation pool  |
| XMX | 2G | Maximum size of the memory allocation pool |
| RCONPASSWORD | Random value (exposed in logs) | RCON's password |