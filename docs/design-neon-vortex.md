# Neon Vortex – Gameplay & Systems Design

## 1. Game Overview
Fast-paced, endless 3D flyer set in a neon cyberpunk city. The player pilots a small ship that automatically flies forward through procedurally generated skyscraper canyons. The goal is to survive as long as possible by dodging buildings and narrow gaps; score increases with time/distance.

Target experience: 60–120 second intense runs, quick restarts, strong sense of speed and flow, minimal UI.

---

## 2. Core Gameplay Loop
1. **Launch**: Player starts at low speed in a wide, forgiving city layout.
2. **Fly & Dodge**: Ship auto-moves forward; player uses WASD to dodge procedurally spawned buildings and gaps.
3. **Escalation**: Over time, speed increases, building density/height patterns become more complex, and safe gaps get narrower.
4. **Failure**: Colliding with any building or major static obstacle = instant game over.
5. **Restart**: Show final score and best score, then allow instant restart (press any key / click / space) into a freshly seeded run.

Primary skill: spatial awareness and quick lane-switching at high speed.

---

## 3. Controls
Keyboard + mouse (mouse only for look; optional).

### Movement (WASD)
- **A / D** – Horizontal strafe left/right.
- **W / S** – Vertical strafe up/down.

Design intent: Ship feels like sliding in 3D space rather than tilting a plane.

### Optional Mouse Look
- Mouse movement: Slight yaw/pitch adjustment for camera only (minimal impact on ship position). This is purely aesthetic to enhance speed sensation; actual hit detection is driven by ship position, not camera look.

### Other
- **Esc** – Pause / return to main menu (if implemented).
- **Space / Enter / Click / Any key** – Confirm restart on game over.

---

## 4. Camera Behavior
- **Third-person chase camera** slightly above and behind the ship.
- **Offset**: ~5–7 units behind, 2–3 units above, looking towards ship’s forward direction.
- Mild **springiness**: camera lags subtly behind ship movement to emphasize inertia (can be implemented via interpolation towards a target transform each frame).
- Small **FOV** increase with speed ramp (e.g., 70° at start → 90° at high speed) to reinforce intensity.
- Optional: subtle camera shake or oscillation when near buildings or at high speed.

Camera does not collide with buildings; it clips through if necessary to avoid jarring adjustments.

---

## 5. World & Obstacle Generation

### 5.1 Coordinate System & Lanes
- Forward axis: **+Z** (ship moves in +Z).
- Horizontal dodge: **X**.
- Vertical dodge: **Y**.

Define a grid of **horizontal lanes** that buildings can occupy:
- Example: 7 lanes across X: `[-3, -2, -1, 0, 1, 2, 3]` (or continuous with a lane spacing unit).
- Buildings spawn on discrete lane positions, leaving some lanes open per "row".

### 5.2 Building Rows
The world is composed of **rows** of buildings:
- A row is a set of building instances aligned at the same **Z** distance from the player.
- Each row spans all lanes and optional vertical variation (building height).

For each row:
- Decide which lanes have **buildings** and which remain **gaps**.
- Optionally vary the **height** per lane.

Guarantee at least one contiguous safe corridor per row (or per few rows) to ensure the game is always theoretically survivable.

### 5.3 Procedural Rules
For each new row:
1. **Base pattern** based on difficulty:
   - Early: 1–2 building clusters, many open lanes.
   - Mid: 3–5 occupied lanes, fewer safe paths.
   - Late: narrow corridors, occasional "slalom" patterns where safe lane shifts side to side.
2. **Pattern types** (choose randomly, weighted by difficulty):
   - **Straight corridor**: All lanes except 2–3 contiguous lanes in the middle are blocked.
   - **Side corridor**: Only leftmost or rightmost 2–3 lanes are open.
   - **Alternating gap**: Lanes alternate building/gap patterns.
   - **Slalom**: Safe corridor shifts one lane left/right from previous row.
3. **Height variation**:
   - Buildings vary in height but always high enough to block the path at ship height.
   - Optionally allow low or high tunnels by leaving vertical gaps (future expansion).

### 5.4 Spawn Distances & Recycling
- The ship remains near world origin; buildings move towards it (or ship moves; implementation choice, but visually equivalent).
- Spawn rows ahead of player within a **forward range** (e.g., from `z = 50` to `z = 200`).
- Maintain a fixed number of rows in memory (e.g., 20–30); as rows pass behind the player, recycle them:
  - Move the row forward to the next spawn distance.
  - Re-roll lane occupancy and heights based on current difficulty.

### 5.5 Neon City Aesthetic
- Buildings: Simple extruded boxes with emissive neon edges and dark faces.
- Use a small set of **building prefab variations**:
  - Different footprints, heights, neon color accents.
- Ambient environment: Dark skybox, distant silhouettes, a few moving lights (e.g., hover cars far away) for parallax.
- Ground plane: Dark reflective surface with neon reflections.

---

## 6. Difficulty Ramp
Difficulty rises dynamically based on **elapsed time** or **distance travelled**.

Define a normalized difficulty value `d` in `[0, 1]`:

```text
d = clamp(time_elapsed / time_to_max_difficulty, 0, 1)
```

Recommended `time_to_max_difficulty`: 90–120 seconds.

Use `d` to drive:

1. **Forward speed**:
   - `speed = lerp(start_speed, max_speed, d)`
   - Example: `start_speed = 20`, `max_speed = 80` units/sec.

2. **Row spawn spacing** (distance between rows):
   - `row_spacing = lerp(15.0, 8.0, d)` (closer rows at higher difficulty).

3. **Building density** (probability a lane is occupied):
   - `lane_occupancy_chance = lerp(0.3, 0.8, d)`.

4. **Safe corridor width** (number of consecutive open lanes):
   - Early: corridors 3–4 lanes wide.
   - Late: corridors 1–2 lanes wide.

5. **Pattern weights**:
   - Early game prefers simple straight corridors.
   - Later game increases chance of slalom and alternating gap patterns.

Optionally add **micro-variation** (sudden but fair spikes) by temporarily increasing speed or density for short intervals.

---

## 7. Scoring System

### 7.1 Core Scoring
Score increases with distance survived (or time).

Simplest implementation:

```gdscript
# Called each physics frame
score += speed * delta * score_factor
```

Where:
- `score_factor` is a tuning constant (e.g., `0.1`) so numbers feel nice (e.g., ~1,000–10,000 points per typical run).
- Alternatively, simply `score += delta * 10.0` and exaggerate at high difficulty.

### 7.2 Difficulty Bonus
Scale score gain with difficulty to reward surviving late game:

```gdscript
score += speed * delta * (1.0 + d * difficulty_score_bonus)
```

Where `difficulty_score_bonus` might be `1.0` (i.e., at max difficulty, gain 2x score).

### 7.3 UI
- Minimal HUD: score in top-left, best score (high score) in smaller text beneath it.
- Optionally, speed or difficulty meter bar.

On game over:
- Show final score and best score.
- CTA: "Press [Space] to Restart".

---

## 8. Failure & Game Over
- Collision with any building or ground triggers immediate game over.
- Optionally, brief slow-motion and particle/explosion effect.
- After a short delay (0.5–1.0 sec), pause gameplay and show game-over UI.

Game over flow:
1. Stop score and difficulty progression.
2. Freeze building movement / ship controls.
3. Display game-over panel with score & best score.
4. Wait for restart input; on restart:
   - Reset score, time, difficulty.
   - Reset ship position & velocity.
   - Regenerate/reseed building rows.

---

## 9. Implementation Notes (Godot 4)

### 9.1 Suggested Node/Scene Structure

#### Top-level
- **Main.tscn** (or `Game.tscn`)
  - `WorldRoot` (Node3D)
    - `Player` (CharacterBody3D or RigidBody3D, but CharacterBody3D recommended)
      - `Mesh` (ship visual)
      - `CollisionShape3D`
      - `ThrusterParticles` (optional)
      - `Audio` (engine hum)
    - `CameraRoot` (Node3D)
      - `Camera3D`
    - `Environment` (WorldEnvironment + sky/lighting)
    - `BuildingsRoot` (Node3D) – container for pooled building rows.
    - `Ground` (StaticBody3D + MeshInstance3D + CollisionShape3D)
  - `UIRoot` (CanvasLayer)
    - `HUD` (Control)
      - `ScoreLabel`
      - `BestScoreLabel`
    - `GameOverPanel` (Control, hidden by default)
  - `GameController` (Node) – owns game state, difficulty, scoring, and spawner.

#### Building Scenes
- **BuildingBlock.tscn**
  - `StaticBody3D`
    - `MeshInstance3D`
    - `CollisionShape3D`
  - Script handles neon material variant selection (color index, emissive strength).

- **BuildingRow.tscn**
  - `Node3D`
    - Multiple child `BuildingBlock` instances, one per occupied lane.
  - Script fields:
    - `lanes: Array[float]` – X positions for lanes.
    - Methods to configure pattern, height, etc.

Alternatively, skip `BuildingRow` and just instantiate `BuildingBlock`s into a row container using a script in `GameController`.

### 9.2 Autoloads / Singletons

**GameState.gd** (autoload):
- Stores persistent state across scenes:
  - `best_score: int = 0`
  - `current_score: int = 0`
  - `rng_seed` (optional, if you want reproducible runs).
- Methods:
  - `reset_run()` – zero score, time, difficulty.
  - `register_score(score)` – update `best_score`.

**Config.gd** (optional autoload):
- Stores tunable constants shared across scenes:
  - `START_SPEED`, `MAX_SPEED`
  - `TIME_TO_MAX_DIFFICULTY`
  - `LANE_POSITIONS`
  - `ROW_SPACING_MIN/MAX`
  - etc.

Singletons are not strictly required but help keep values centralized.

### 9.3 Player Movement Implementation

Use `CharacterBody3D` for straightforward kinematic movement.

Pseudo-GDScript:

```gdscript
# Player.gd
extends CharacterBody3D

@export var strafe_speed_x: float = 20.0
@export var strafe_speed_y: float = 15.0

var forward_speed: float = 20.0

func _physics_process(delta: float) -> void:
    var input_dir = Vector3.ZERO

    if Input.is_action_pressed("move_left"):
        input_dir.x -= 1
    if Input.is_action_pressed("move_right"):
        input_dir.x += 1
    if Input.is_action_pressed("move_up"):
        input_dir.y += 1
    if Input.is_action_pressed("move_down"):
        input_dir.y -= 1

    input_dir = input_dir.normalized()

    velocity.x = input_dir.x * strafe_speed_x
    velocity.y = input_dir.y * strafe_speed_y
    velocity.z = forward_speed

    move_and_slide()
```

- `forward_speed` is controlled externally by `GameController` based on difficulty.

### 9.4 Building Spawner Logic

`GameController.gd` responsibilities:
- Track elapsed time and difficulty `d`.
- Compute `forward_speed`, `row_spacing`, and spawn pattern weights.
- Maintain a pool of building rows.

Pseudo-structure:

```gdscript
# GameController.gd
extends Node

@export var start_speed := 20.0
@export var max_speed := 80.0
@export var time_to_max_difficulty := 100.0
@export var lanes := [-3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0]
@export var rows_ahead := 25
@export var initial_row_z := 40.0
@export var row_spacing_min := 8.0
@export var row_spacing_max := 15.0

var elapsed_time := 0.0
var difficulty := 0.0
var current_speed := 0.0

var rows: Array[Node3D] = []

func _ready():
    _init_rows()

func _init_rows():
    var z_pos := initial_row_z
    for i in rows_ahead:
        var row = _create_row(z_pos)
        rows.append(row)
        z_pos += row_spacing_max

func _create_row(z_pos: float) -> Node3D:
    var row := Node3D.new()
    BuildingsRoot.add_child(row)
    row.transform.origin.z = z_pos
    _configure_row_pattern(row)
    return row

func _physics_process(delta: float) -> void:
    elapsed_time += delta
    difficulty = clamp(elapsed_time / time_to_max_difficulty, 0.0, 1.0)

    current_speed = lerp(start_speed, max_speed, difficulty)
    var spacing = lerp(row_spacing_max, row_spacing_min, difficulty)

    # Move rows towards player
    for row in rows:
        row.translate(Vector3(0, 0, -current_speed * delta))

    # Recycle rows that passed behind the player
    for row in rows:
        if row.global_transform.origin.z < -10.0:
            var max_z := _get_max_row_z()
            row.global_transform.origin.z = max_z + spacing
            _configure_row_pattern(row)

func _get_max_row_z() -> float:
    var max_z := -INF
    for row in rows:
        max_z = max(max_z, row.global_transform.origin.z)
    return max_z

func _configure_row_pattern(row: Node3D) -> void:
    # Clear existing buildings
    for child in row.get_children():
        child.queue_free()

    # Decide which lanes are occupied based on difficulty
    var lane_occupancy_chance := lerp(0.3, 0.8, difficulty)

    # Guarantee at least one safe corridor
    var safe_lane_index := randi() % lanes.size()

    for i in lanes.size():
        if i == safe_lane_index:
            continue
        if randf() < lane_occupancy_chance:
            var b := building_scene.instantiate()
            row.add_child(b)
            b.transform.origin = Vector3(lanes[i], 0.0, 0.0)
            # Height & scale adjustments here
```

This is a baseline pattern; later we can incorporate specific pattern types (slalom, corridors, etc.) using additional logic.

### 9.5 Score & Game State Handling

In `GameController.gd`:

```gdscript
var score := 0.0

@onready var player := $WorldRoot/Player
@onready var hud := $UIRoot/HUD

func _physics_process(delta: float) -> void:
    if is_game_over:
        return

    # Difficulty & row updates (as above)
    # ...

    # Score update
    score += current_speed * delta * 0.1 * (1.0 + difficulty)
    hud.update_score(int(score))
```

On collision, Player.gd can emit a `hit_obstacle` signal, which GameController listens to:

```gdscript
# Player.gd
signal hit_obstacle

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("obstacle"):
        emit_signal("hit_obstacle")
```

```gdscript
# GameController.gd
var is_game_over := false

func _ready() -> void:
    player.connect("hit_obstacle", Callable(self, "_on_player_hit"))

func _on_player_hit() -> void:
    if is_game_over:
        return
    is_game_over = true
    GameState.register_score(int(score))
    _show_game_over_ui()

func _show_game_over_ui() -> void:
    $UIRoot/GameOverPanel.show()
    # Optionally, tween in UI

func _input(event: InputEvent) -> void:
    if is_game_over and event.is_pressed():
        _restart_run()

func _restart_run() -> void:
    # Simple approach: reload the current scene
    get_tree().reload_current_scene()
```

### 9.6 Visual Tuning Parameters
Expose key parameters as `@export` variables so designers can tweak in the editor:

- **Player.gd**:
  - `strafe_speed_x`
  - `strafe_speed_y`

- **GameController.gd**:
  - `start_speed`, `max_speed`
  - `time_to_max_difficulty`
  - `row_spacing_min`, `row_spacing_max`
  - `lanes` array
  - `rows_ahead` (how many rows to maintain)
  - `initial_row_z` (how far ahead first row is)

- **BuildingBlock.gd**:
  - `min_height`, `max_height`
  - `neon_color_options` (Array[Color])
  - `emissive_strength`

- **Camera script**:
  - `base_fov`, `max_fov`
  - `camera_distance`
  - `camera_height`
  - `follow_smoothness`

These parameters should be tuned to achieve the desired speed, difficulty curve, and visual style.

---

## 10. Summary for Gameplay Programmer

1. Implement `Main.tscn` with `WorldRoot`, `Player`, `CameraRoot/Camera3D`, `BuildingsRoot`, `Ground`, and UI.
2. Use a `GameController` script to:
   - Track elapsed time and compute difficulty.
   - Drive forward speed of player (or world) and building row spacing.
   - Manage a pool of building rows, recycling them ahead of the player with new patterns.
   - Update score based on speed and difficulty, and push updates to HUD.
   - Handle game over state and restarts.
3. Use `CharacterBody3D` for the ship with WASD strafing, constant forward velocity.
4. Create building prefabs with emissive neon materials and spawn them in rows on discrete lanes.
5. Use autoload `GameState` (and optionally `Config`) to track high score and constants.
6. Implement chase camera with adjustable distance/height, FOV scaling by speed, and slight smoothing.

This design should be sufficient to implement a first playable of **Neon Vortex**, with clear extension points for more patterns, power-ups, and visual polish later.