# REALITY BREAKER

A first-person 3D exploration game built with **Godot 4.3**, featuring gravity flipping, a streamed procedural world, and adaptive performance profiles.

## Play in a browser

The Web version is deployed to GitHub Pages:
https://ahmad47eo.github.io/REALITY-BREAKER/

The web build keeps the mobile touch controls and uses a lighter automatic profile for browser performance.

## Windows PC and laptop build

Every successful validated build also produces a Windows desktop artifact.

1. Open the repository's **Actions** tab: https://github.com/Ahmad47eo/REALITY-BREAKER/actions
2. Open the latest successful **Build browser version** run.
3. Under **Artifacts**, download `reality-breaker-windows`.
4. Extract the ZIP and run `RealityBreaker.exe`.

The Windows export is an early prototype build. Windows SmartScreen may show a warning because this is an unsigned personal project; only run builds you downloaded from this repository.

## Automatic hardware detection

On startup, the game attempts to detect:
- Operating system and CPU thread count
- System RAM when the platform and Godot runtime expose it
- Graphics adapter name (reported for information, not mistaken for dedicated VRAM)

It chooses a starting performance profile and displays it in the HUD:
- **Low-End** — reduced world object density and 30 FPS cap for very limited hardware
- **Balanced** — moderate world density and a 60 FPS cap
- **High** — denser world sections and a larger streaming radius for higher-memory, higher-thread-count computers
- **Web Balanced** — conservative settings for browser builds

Hardware detection is a starting estimate, not a benchmark. Some systems do not expose RAM to Godot, and GPU names alone cannot reliably indicate graphics performance. More precise adaptive scaling and an in-game quality menu are future improvements.

## World regions

- **Neon City** — streets, buildings, and glowing rooftop markers.
- **Wildlands** — trees, rocks, and green open terrain.
- **Reality Zone** — sci-fi pylons, glowing markers, and floating platforms.
- **Streaming world chunks** — nearby sections load as you travel and distant sections are removed. New sections are generated from coordinates.

World geometry currently uses simple primitives to keep the prototype lightweight. It does not yet include missions, NPCs, traffic, vehicles, saving, multiplayer, or detailed handcrafted terrain.

## Controls

### Phone / browser
- **Arrow buttons** or drag on the left side — move
- **Drag on the right side** — look around
- **JUMP** — jump
- **FLIP GRAVITY** — switch between floor and ceiling

### Windows desktop
- **W A S D** — move
- **Mouse** — look around
- **Space** — jump
- **G** — flip gravity
- **Esc** — release the mouse

## Build from source

1. Install Godot 4.3 from https://godotengine.org/download/
2. Clone or download this repository.
3. Import `project.godot` in Godot.
4. Press **F5** to run.
5. For a native Windows build, select **Project → Export → Windows Desktop** after installing Godot 4.3 export templates.

## Development checks

GitHub Actions runs a headless Godot project import and launch check before the browser build is exported and deployed. Downloadable Windows builds are attached as a separate workflow artifact after validation.
