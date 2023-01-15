# vr-table-tennis
A simple VR game made with Godot 4.0. It was made for Pico 4. Not sure if it will work on other platforms.

Screenshot from Pico:

![Screenshot from Pico](./images/screenshot-pico.jpeg)

Screenshot from server:

![Screenshot from server](./images/screenshot-server.png)

# Modify the domain

This game is a multiplayer game. Domain or public IP needs to be set before running. Search for the string `YOUR_DOMAIN_OR_IP` in the project and replace it. Usually it is in `client.gd`.

# Run

## Start the server

```
$ /path/to/godot/bin/godot.windows.editor.x86_64.console.exe --path /path/to/vr-table-tennis --server --xr-mode off
```

## Run the game

Two ways:
1. Export an apk and install it to Pico. Then run it on Pico.
2. Click the [Remote Debug] icon on the right top of Godot project manager. It will automatically export/install/run the game on the target device.

# Game Instructions

## Server

| Instruction | Description                                      |
|-------------|--------------------------------------------------|
| W/A/S/D     | Move observer camera forward/left/backward/right |
| Q/E         | Move observer camera down/up                     |

## Client

| Controller | Instruction | Description                      |
|------------|-------------|----------------------------------|
| Left Hand  | Thumbstick  | Move forward/left/backward/right |
|            | X/Y         | Moving speed down/up             |
| Right Hand | Thumbstick  | Turn left/right                       |
|            | A/B         | Steering speed down/up           |
|            | Pose        | Control the paddle               |

# Copyright Notice

The materials used in this project come from the following addresses, and the relevant rights belong to the original author. The MIT license only affects the game code.

- [Modular Village Pack](https://fertile-soil-productions.itch.io/modular-village-pack) - Keith at Fertile Soil Productions
- [Modular Terrain Pack](https://fertile-soil-productions.itch.io/modular-terrain-pack) - Keith at Fertile Soil Productions