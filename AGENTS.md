# AGENTS.md — Botched Batch Brewery

Guidance for agentic coding assistants working in this repository.

---

## Project Overview

**Botched Batch Brewery** is a 3D game built with **Godot 4.6** and **C# (.NET)**.

- Engine: Godot 4.6, Forward Plus renderer, Jolt Physics (3D), Direct3D 12 on Windows
- Language: C# via Godot's .NET integration
- IDE: VS Code with the coreclr / C# Dev Kit extension

The `.godot/` directory is gitignored and should never be committed.

---

## Directory Structure

```
botched-batch-brewery/
├── Prefabs/
│   ├── Enviroment/
│   │   ├── box.tscn
│   │   └── island.tscn
│   └── Gameplay/
│       └── player.tscn
├── Scenes/
│   └── Island.tscn
├── Scripts/
│   └── Gameplay/
│       ├── Player.cs
│       ├── Player.cs.uid
│       ├── FollowCamera.cs
│       └── FollowCamera.cs.uid
├── .editorconfig
├── .vscode/
├── project.godot
└── AGENTS.md
```

New scripts should live under `Scripts/` in a subfolder that mirrors their gameplay domain
(e.g. `Scripts/Gameplay/`, `Scripts/UI/`, `Scripts/Systems/`).

---

## Build & Run Commands

### Prerequisites

Set the `GODOT4` environment variable to the path of your Godot 4 executable before running
any CLI commands:

```bash
export GODOT4="/path/to/godot4"   # Linux / macOS
$env:GODOT4 = "C:\Godot\Godot.exe" # PowerShell
```

### Open the Editor

```bash
$GODOT4 --path .
```

### Build (compile C# without launching)

```bash
dotnet build
```

### Run in Headless Mode (CI / scripted)

```bash
$GODOT4 --path . --headless
```

### VS Code

Press **F5** to build and launch via the `Play` launch configuration (`.vscode/launch.json`).
This requires the `GODOT4` environment variable to be set in your shell environment.

---

## Testing

**There is currently no test suite.** No test framework (GUT, xUnit, NUnit) has been
configured yet.

When tests are added:

- Prefer **xUnit** or **NUnit** for C# unit tests (engine-independent logic).
- Prefer **GUT** (Godot Unit Test plugin) for integration/scene tests that require the
  Godot runtime.
- Place test files in a top-level `Tests/` directory mirroring the `Scripts/` structure.

---

## Linting & Formatting

### Prettier (for non-C# files: JSON, YAML, Markdown, etc.)

```bash
npx prettier --write .       # format all supported files
npx prettier --check .       # check without writing
```

### C# Formatting

The project includes an `.editorconfig` with C# formatting rules. Run:

```bash
dotnet format
```

---

## C# Code Style

### File Layout

1. `using` directives — Godot namespaces first, then System, then third-party
2. XML documentation summary (recommended for public APIs)
3. Class declaration

```csharp
using Godot;
using System;

/// <summary>
/// Brief description of what this class does.
/// </summary>
public partial class MyNode : Node3D
{
}
```

### Class Declarations

All Godot node scripts **must** be declared `partial`. This is required by Godot's C#
source generator for signal and property bindings.

```csharp
public partial class Player : CharacterBody3D { }
```

### Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Classes | PascalCase | `Player`, `FollowCamera` |
| Public fields / constants | PascalCase | `Speed`, `JumpVelocity` |
| Private fields | `_camelCase` | `_mesh`, `_coyoteTimer` |
| Local variables | camelCase | `inputDir`, `velocity` |
| Methods | PascalCase | `ApplyGravity()` |
| Godot lifecycle overrides | Underscore prefix | `_Ready()`, `_PhysicsProcess()` |
| Signals | PascalCase, past-tense | `BrewingCompleted` |

### Braces & Indentation

- **Allman style** — opening brace on its own line.
- **Tabs** for indentation (matches `.editorconfig`).

### Types

- Prefer **explicit types** over `var` for clarity, especially with Godot types.
- Use Godot math types (`Vector3`, `Vector2`, `Mathf`, `Transform3D`) rather than
  System.Numerics equivalents.
- Use `float` (not `double`) for spatial values to match Godot's internal precision.
- `_PhysicsProcess` and `_Process` receive `double delta`; cast to `float` when passing
  into Godot math operations.

### Constants

Declare magic numbers as `const` fields with a descriptive name:

```csharp
public const float Speed = 6.0f;
public const float JumpVelocity = 5.5f;
```

### XML Documentation

Use XML documentation for public classes and members:

```csharp
/// <summary>
/// Seconds the player can still jump after walking off a ledge.
/// </summary>
public const float CoyoteTime = 0.12f;
```

### Error Handling

- Use `GD.PrintErr()` / `GD.PushError()` for engine-level errors (visible in Godot output).
- Use standard C# exceptions for logic errors in non-Godot code paths.
- Validate `[Export]` node references in `_Ready()` with an early `null` check and
  `GD.PushError()` before proceeding.

---

## Input Mappings

Defined in `project.godot`:

| Action | Keys | Gamepad |
|--------|------|---------|
| `ui_left` | A, Left Arrow | D-pad Left, Left Stick Left |
| `ui_right` | D, Right Arrow | D-pad Right, Right Stick Right |
| `ui_up` | W, Up Arrow | D-pad Up, Left Stick Up |
| `ui_down` | S, Down Arrow | D-pad Down, Left Stick Down |
| `ui_accept` | Space | A button |

---

## Scene & Asset Conventions

- Scene files use the `.tscn` (text) format — never binary `.scn`.
- Prefabs (reusable sub-scenes) go in `Prefabs/` with a subdirectory matching their domain.
- Top-level playable scenes go in `Scenes/`.
- One C# script per scene/node — name the script the same as the root node.
- `.uid` sidecar files are generated by Godot and **must be committed** alongside their
  corresponding `.cs` files.

---

## Environment Notes

- The `GODOT4` environment variable must point to the Godot 4 executable for VS Code
  debugging and headless CLI runs.
- The `.godot/` cache directory is gitignored; never commit its contents.
- EOL is enforced as **LF** by `.gitattributes` — do not commit CRLF line endings.
- All text files must use **UTF-8** encoding (enforced by `.editorconfig`).
