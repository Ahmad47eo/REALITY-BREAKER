# REALITY BREAKER

A first-person 3D exploration game built with **Godot 4.3**, featuring gravity flipping and a procedural world.

## Open-world prototype

The game now generates connected world regions as you explore:
- **Neon City** — streets, buildings, and glowing rooftop markers.
- **Wildlands** — trees, rocks, and green open terrain.
- **Reality Zone** — sci-fi pylons, glowing markers, and floating platforms to explore using gravity flipping.
- **Streaming world chunks** — nearby sections load as you travel and distant sections are removed, allowing the procedural world to continue beyond the starting area.
- **First-person movement** — keyboard and mouse on desktop, touch controls in mobile browsers.
- **Gravity flipping** — walk between floor and ceiling and experiment with elevated platforms.

The world is generated from chunk coordinates, so sections can be recreated consistently as you revisit them. This is an early procedural prototype: it does not yet include missions, NPCs, traffic, saving, or multiplayer.

## Play on iPhone (free browser build)

1. Open the repository's **Actions** tab.
2. Select **Build browser version** and wait for the latest run to finish.
3. Open the deployed GitHub Pages URL from the workflow's deployment/environment link.
4. If the game looks cached, reload the page after deployment finishes.

### Phone controls
- **Arrow buttons** or drag on the left side — move
- **Drag on the right side** — look around
- **JUMP** — jump
- **FLIP GRAVITY** — switch between floor and ceiling

### Desktop controls
- **W A S D** — move
- **Mouse** — look around
- **Space** — jump
- **G** — flip gravity
- **Esc** — release the mouse

## Run it on a computer

1. Install Godot 4.3 from https://godotengine.org/download/
2. Download or clone this repository.
3. Import `project.godot` in Godot.
4. Press **F5** to run the project.

## Current limitations and next steps

This is a single-player prototype. World generation uses simple primitive geometry to stay lightweight and does not yet include detailed terrain sculpting, buildings you can enter, vehicles, quests, NPCs, persistence, or multiplayer. The browser export is built by GitHub Actions; wait for the build and deployment jobs to succeed before testing the latest changes.

