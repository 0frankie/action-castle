# CLAUDE.md

This file provides guidance for coding agents (Claude Code, Cursor, etc.) working on this repository. All contributors — human or AI — must follow these conventions.

## Project Overview

This is a game project built primarily with the **Godot Engine** using **GDScript**. **Python** may be used for auxiliary tooling (build scripts, asset pipelines, data processing, CI helpers) and, where appropriate, for integration with the game via subprocess calls, sockets, or generated data files.

> Update this section with the specific Godot version, target platforms, and game genre once finalized.

## Repository Layout

```
/scenes        # .tscn scene files
/scripts       # .gd GDScript files (mirror /scenes structure where possible)
/assets        # art, audio, fonts, raw data
/addons        # third-party Godot plugins
/tools         # Python tooling, build scripts, asset pipelines
/tests         # GUT tests for GDScript, pytest for Python
project.godot  # Godot project file
```

## General Rules for All Code

1. **Every function must have a concise comment** explaining what it does. One line is usually enough; only expand when the function's purpose, side effects, or return value are non-obvious. Do not restate the function name — describe the intent.
2. Prefer clarity over cleverness. Game code is read far more often than it is written.
3. Keep functions small and single-purpose. If a comment needs to describe multiple unrelated things, split the function.
4. Never commit commented-out code. Use version control history instead.
5. No magic numbers. Promote them to named constants.

### Function comment examples

**GDScript:**
```gdscript
# Returns the player's current health clamped to [0, max_health].
func get_clamped_health() -> int:
    return clamp(health, 0, max_health)


# Applies knockback to the target in the direction of the impact.
func apply_knockback(target: Node2D, impact_dir: Vector2) -> void:
    target.velocity += impact_dir.normalized() * KNOCKBACK_FORCE
```

**Python:**
```python
def pack_textures(source_dir: Path, atlas_path: Path) -> None:
    """Pack all PNGs in source_dir into a single atlas at atlas_path."""
    ...
```

---

## GDScript Style Guide (Official, Condensed)

This summarizes Godot's [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html). When in doubt, defer to the official docs.

### Formatting

- **Indentation:** tabs, one tab per level. Never spaces.
- **Line length:** keep lines under 100 characters.
- **One statement per line.** No semicolons.
- **Two blank lines** between functions and class definitions.
- **One blank line** inside functions to separate logical sections.
- **Trailing comma** in multi-line arrays, dictionaries, and enums to make diffs cleaner.
- **Spaces around operators** (`a + b`, not `a+b`) and after commas.
- **No spaces inside parentheses, brackets, or braces.**
- **Strings:** use double quotes (`"hello"`) unless the string contains a double quote.

### Naming

| Item                   | Convention             | Example                  |
|------------------------|------------------------|--------------------------|
| Files (.gd, .tscn)     | `snake_case`           | `player_controller.gd`   |
| Classes (`class_name`) | `PascalCase`           | `PlayerController`       |
| Nodes in scene tree    | `PascalCase`           | `MainCamera`             |
| Functions & methods    | `snake_case`           | `apply_damage()`         |
| Variables              | `snake_case`           | `current_health`         |
| Private members        | `_snake_case` (leading underscore) | `_internal_state` |
| Signals                | `snake_case`, past tense verb | `health_depleted` |
| Constants              | `CONSTANT_CASE`        | `MAX_HEALTH`             |
| Enums (type)           | `PascalCase`           | `enum State`             |
| Enum members           | `CONSTANT_CASE`        | `IDLE`, `RUNNING`        |

### Static Typing

Use static types everywhere — for variables, parameters, and return values. It improves performance, enables better autocomplete, and catches bugs early.

```gdscript
var health: int = 100
var speed: float = 250.0
var target: Node2D = null

func deal_damage(amount: int) -> void:
    health -= amount
```

Use type inference (`:=`) when the right-hand side makes the type obvious:

```gdscript
var velocity := Vector2.ZERO   # inferred as Vector2
```

### Class Member Order

Order members within a script file as follows:

1. `@tool`, `@icon`, `class_name`
2. `extends`
3. Docstring (`##` comments at top describing the class)
4. Signals (`signal`)
5. Enums (`enum`)
6. Constants (`const`)
7. Static variables
8. Exported variables (`@export`)
9. Public variables
10. Private variables (`_prefixed`)
11. `@onready` variables
12. `_static_init()`
13. Static methods
14. `_init()`
15. `_enter_tree()`
16. `_ready()`
17. `_process()`, `_physics_process()`
18. Other built-in virtual methods (e.g. `_input()`)
19. Public methods
20. Private methods (`_prefixed`)
21. Subclasses

### Documentation Comments

Use `##` for documentation comments that appear in Godot's in-editor help. Use `#` for regular inline comments.

```gdscript
## Represents an enemy that patrols between waypoints.
class_name PatrolEnemy
extends CharacterBody2D


## Emitted when this enemy spots the player.
signal player_spotted(player: Node2D)
```

### Example File

```gdscript
class_name Player
extends CharacterBody2D

## Player character controller. Handles movement, jumping, and damage.

signal died
signal health_changed(new_health: int)

const MAX_HEALTH: int = 100
const JUMP_VELOCITY: float = -400.0
const SPEED: float = 300.0

@export var double_jump_enabled: bool = false

var health: int = MAX_HEALTH
var _can_double_jump: bool = false

@onready var sprite: Sprite2D = $Sprite2D


# Initializes the player state on scene entry.
func _ready() -> void:
    health = MAX_HEALTH
    _can_double_jump = double_jump_enabled


# Handles physics-driven movement each frame.
func _physics_process(delta: float) -> void:
    _apply_gravity(delta)
    _handle_input()
    move_and_slide()


# Reduces health by amount and emits the relevant signals.
func take_damage(amount: int) -> void:
    health = max(health - amount, 0)
    health_changed.emit(health)
    if health == 0:
        died.emit()


# Applies gravity to vertical velocity.
func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y += get_gravity().y * delta
```

---

## Python Style Guide

For any Python code in `/tools` or integration scripts:

- Follow **PEP 8**. Run `ruff` or `black` before committing.
- **4 spaces** for indentation (not tabs — this differs from GDScript).
- Line length: 100 characters.
- Use **type hints** on all function signatures.
- Use **f-strings** for formatting, not `%` or `.format()`.
- File and function names: `snake_case`. Classes: `PascalCase`. Constants: `CONSTANT_CASE`.
- Use **docstrings** (triple-quoted) on every function, class, and module. One-line docstrings are fine for short functions.
- Prefer `pathlib.Path` over `os.path` for filesystem work.

```python
from pathlib import Path


def export_dialogue_csv(scenes_dir: Path, output: Path) -> int:
    """Extract dialogue from all .tscn files and write to CSV. Returns row count."""
    ...
```

### GDScript ↔ Python Interop

When Python tools and GDScript need to exchange data:

- Prefer **JSON** for structured data (both languages handle it natively).
- Use **CSV** for tabular game data (dialogue tables, item stats).
- For runtime integration, prefer a **subprocess** or **local socket** boundary rather than embedding. Document the protocol in `/tools/README.md`.

---

## Testing

- **GDScript:** use [GUT](https://github.com/bitwes/Gut) for unit tests. Place tests in `/tests/gdscript/`, mirroring the `/scripts` structure. Name test files `test_<module>.gd`.
- **Python:** use `pytest`. Place tests in `/tests/python/`. Name test files `test_<module>.py`.
- Write tests for any non-trivial pure logic (damage calculations, save/load, pathfinding helpers). UI and visual code can be tested manually.

## Common Commands

> Fill in once tooling is set up.

```bash
# Run the game from the command line
godot --path .

# Run GDScript tests
godot --headless --path . -s addons/gut/gut_cmdln.gd

# Format / lint Python tools
ruff check tools/
ruff format tools/

# Run Python tests
pytest tests/python/
```

---

## Pull Request Checklist

Before opening a PR (or before a coding agent marks a task complete):

- [ ] Every new or modified function has a concise comment.
- [ ] Static types used on all GDScript declarations.
- [ ] No tabs-vs-spaces mixing within a file.
- [ ] No commented-out code or stray `print()` / debug statements.
- [ ] Tests pass locally.
- [ ] No new warnings in the Godot editor.

## Notes for Coding Agents

- When generating GDScript, **always** include type hints and per-function comments — do not omit them even for one-line helpers.
- When editing an existing file, match its existing structure (member order, comment style) rather than reorganizing it in an unrelated change.
- If a requested change conflicts with this style guide, flag the conflict instead of silently violating the guide.
- Prefer Godot's built-in nodes and signals over custom systems unless there's a clear reason to roll your own.
