# REALITY BREAKER

A lightweight first-person 3D puzzle game built with **Godot 4**.

## Current prototype
- First-person mouse-look and WASD movement
- Jumping and gravity flipping with **G**
- A simple test chamber with a floor, ceiling, and walls
- Designed to start small and run on modest hardware

## Run it
1. Install Godot 4.x from https://godotengine.org/download/
2. Download or clone this repository.
3. In Godot, import the project by selecting `project.godot`.
4. Press **F6** to run the main scene, or **F5** to run the project.

## Controls
- **W A S D** — move
- **Mouse** — look around
- **Space** — jump
- **G** — flip gravity between floor and ceiling
- **Esc** — release the mouse

## Multiplayer direction: player-hosted rooms
The planned multiplayer model is **listen-server / player-hosted**: the player who creates a room runs the match, and friends connect to that host. This avoids paying for a dedicated game server for every match.

Important design notes:
- The host must keep the game open while the room is running.
- Hosting from a home network may require NAT traversal or a relay; a room code by itself does not make direct connections possible.
- A small matchmaking/signalling service or relay may still be needed for reliable internet connections, and any free-tier provider can have limits.
- The host should be authoritative for important game state so clients cannot freely decide puzzle outcomes.
- Multiplayer is planned, not implemented yet. The current prototype is still single-player.

See [the multiplayer design notes](docs/multiplayer-design.md).

## Roadmap
1. Reliable single-player room and gravity puzzle
2. Windows build and a browser build investigation
3. Player-hosted private multiplayer rooms
4. Co-op and versus modes

The first milestone is a working prototype; networking and extra reality powers come later.
