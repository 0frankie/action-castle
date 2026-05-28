# Action Castle

A Godot-based text adventure engine implementing the classic game "Action Castle". This project is built primarily with the **Godot Engine (v4.6)** using **GDScript**.

## Project Overview

Action Castle is a modular text-adventure game. The architecture separates the core game logic and state from the visual representation in the Godot scene tree. The game engine parses text commands, updates the world state, and the scene controller (`main.gd`) reflects these changes visually.

## Directory Structure

```text
.
├── scenes/         # .tscn scene files
│   ├── locations/  # Individual room scenes (Cottage, Dungeon, etc.)
│   ├── ui/         # User interface components
│   ├── world/      # Entity pools and world management
│   └── main.tscn   # The main entry point scene
├── scripts/        # .gd GDScript files containing game logic
│   ├── actions/    # Specific command implementations (e.g., go, get, attack)
│   ├── blocks/     # Route blockers (e.g., Troll, Guard, Locked Door)
│   ├── things/     # Base classes for entities (Thing, Item, Character, Location)
│   ├── action_castle_game.gd # Core game engine and state manager
│   ├── main.gd     # Scene controller linking UI to game logic
│   └── parser.gd   # Text command parser
├── sprites/        # Visual assets and textures
├── tools/          # Auxiliary tooling, build scripts, and smoke tests
├── CLAUDE.md       # Coding standards and style guide
└── project.godot   # Godot project configuration file
```

*(Note: `addons/`, `assets/`, and `tests/` directories may be added as the project expands, as outlined in the style guide.)*

## Architecture

The game follows a Model-View-Controller (MVC) inspired architecture:

1. **Model (`scripts/action_castle_game.gd` & `scripts/things/`)**: Contains the pure game state, including locations, items, characters, and their relationships. It handles the logic for moving items, changing locations, and evaluating game rules.
2. **View (`scenes/`)**: The visual representation of the game. Each location, item, and character has a corresponding node in the scene tree.
3. **Controller (`scripts/main.gd` & `scripts/parser.gd`)**: `main.gd` listens for user input, passes it to the `ActionCastleGame` instance (which uses `parser.gd` to interpret commands), and then updates the View based on the new game state.

### Actions and Blocks

- **Actions (`scripts/actions/`)**: Commands are highly modular. Each action (like `catch_fish.gd` or `sit_on_throne.gd`) is a separate script that the parser evaluates against the current game state.
- **Blocks (`scripts/blocks/`)**: Movement between locations can be restricted by "blocks" (like `troll_block.gd`). These blocks define conditions that must be met before the player can pass (e.g., giving the troll a fish).

## Development Guidelines

Please refer to [`CLAUDE.md`](CLAUDE.md) for comprehensive coding standards, style guides, and contribution rules.

### Key Rules:
- Use **static typing** everywhere in GDScript.
- Every function must have a concise comment explaining its intent.
- Keep functions small and single-purpose.
- Prefer clarity over cleverness.

## Running the Game

You can run the game directly from the Godot Editor or via the command line:

```bash
# Run the game from the command line
godot --path .
```

## Testing

The project uses [GUT (Godot Unit Test)](https://github.com/bitwes/Gut) for GDScript testing and `pytest` for Python tooling (once set up).

```bash
# Run GDScript tests (requires GUT addon)
godot --headless --path . -s addons/gut/gut_cmdln.gd

# Run a quick smoke test
godot --headless --script tools/smoke_test.gd
```
