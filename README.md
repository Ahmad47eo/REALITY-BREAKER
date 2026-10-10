# REALITY BREAKER

A lightweight first-person 3D gravity-puzzle prototype built with **Godot 4.3**.

## Current prototype
- First-person movement and look
- Jumping and gravity flipping between floor and ceiling
- A small test chamber with a floor, ceiling, and walls
- A browser build workflow for testing in Safari, Chrome, or desktop browsers

## Play on iPhone (free browser build)
1. Open the repository's **Actions** tab.
2. Select **Build browser version** and tap **Run workflow** if a build has not started automatically.
3. Wait for the workflow to finish and open the deployed GitHub Pages URL from the workflow's deployment/environment link.

The Web build is a work in progress. Touch controls are now included for mobile browsers: use the left-side directional buttons (or drag on the left side to move), drag on the right side to look around, and use **JUMP** and **FLIP GRAVITY** on the right. Desktop keyboard/mouse controls remain available. iOS native export is a separate experimental workflow and is not required for browser testing.

## Run it on a computer
1. Install Godot 4.3 from https://godotengine.org/download/
2. Download or clone this repository.
3. Import `project.godot` in Godot.
4. Press **F5** to run the project.

## Controls
### Phones and tablets
- **Arrow buttons** or drag on the left side — move
- **Drag on the right side** — look around
- **JUMP** — jump
- **FLIP GRAVITY** — switch between floor and ceiling

### Desktop
- **W A S D** — move
- **Mouse** — look around
- **Space** — jump
- **G** — flip gravity
- **Esc** — release the mouse

## Multiplayer direction: player-hosted rooms
The planned multiplayer model is **listen-server / player-hosted**: the player who creates a room runs the match. This avoids paying for a dedicated game server for every match.

Important design notes:
- The host must keep the game open while the room is running.
- Hosting from a home network may require NAT traversal or a relay; a room code alone does not make direct connections possible.
- A small matchmaking/signalling service or relay may still be needed for reliable internet connections, and free tiers can have limits.
- The host should be authoritative for important game state so clients cannot freely decide puzzle outcomes.
- Multiplayer is planned, not implemented yet. The current prototype is single-player.

See [the multiplayer design notes](docs/multiplayer-design.md).

## Roadmap
1. Reliable single-player room and gravity puzzle
2. Browser and Windows builds
3. Touch controls for phones and tablets
4. Player-hosted private multiplayer rooms
