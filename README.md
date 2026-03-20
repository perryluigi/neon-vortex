# Neon Vortex

A 3D endless flying game built with **Godot 4.4**.

You pilot a neon spaceship flying forward through a cyberpunk city, dodging procedurally generated skyscrapers. Score increases the longer you survive; colliding with a building triggers game over with a restart option.

---

## Requirements

- **Godot 4.4.1 (Linux)** already installed here as:
  - `/home/ocuser/bin/Godot_v4.4.1-stable_linux.x86_64`
- Project path:
  - `~/projects/neon-vortex/`

---

## How to run the game

### 1. From the command line (headless check)

To verify the project loads and assets/scripts are valid:

```bash
/home/ocuser/bin/Godot_v4.4.1-stable_linux.x86_64 \
  --headless \
  --path ~/projects/neon-vortex/ \
  --check-only
```

You should see Godot start and exit without errors.

### 2. From the Godot editor (playable)

1. Launch the Godot editor:
   ```bash
   /home/ocuser/bin/Godot_v4.4.1-stable_linux.x86_64
   ```
2. When the project manager opens, choose **Import** → select:
   - `~/projects/neon-vortex/project.godot`
3. Open the **neon-vortex** project.
4. The main scene is already set to:
   - `res://scenes/main.tscn`
5. Press **F5** (or click the Play button) to run the game.

Controls:

- `W` / `S` – move the ship up / down
- `A` / `D` – strafe left / right

The ship constantly flies forward through the neon city.

---

## Game flow

- Score increases over time while you are alive.
- Buildings are spawned in rows ahead of you with random gaps and heights.
- Colliding with a building is intended to trigger **Game Over** and show a restart overlay.

If you open the scene in the editor, you can:

- Inspect and tweak parameters on:
  - `Main` → `BuildingSpawner` (lane count, spacing, height range, spawn distance).
  - `Player` (movement speeds).
  - `GameManager` (score rate).
- Wire the `Restart` button (in `UI/GameOverOverlay/RestartButton`) to `GameManager.restart()` if not already connected.

---

## Useful commands

From inside the project directory:

```bash
cd ~/projects/neon-vortex

# Run Godot editor on this project (if you want to force path)
/home/ocuser/bin/Godot_v4.4.1-stable_linux.x86_64 --path .

# Validate project headlessly
/home/ocuser/bin/Godot_v4.4.1-stable_linux.x86_64 --headless --path . --check-only
```