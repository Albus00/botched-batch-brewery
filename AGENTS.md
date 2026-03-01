# AGENTS.md — Botched Batch Brewery

Guidance for agentic coding assistants working in this repository.

---

## Project Overview

**Botched Batch Brewery** is a 3D game built with **Godot 4.6** and **C# (.NET)**.

- Engine: Godot 4.6, Forward Plus renderer, Jolt Physics (3D), Direct3D 12 on Windows
- Language: C# via Godot's .NET integration
- IDE: VS Code with the coreclr / C# Dev Kit extension

There is no `package.json`, `*.sln`, or committed `*.csproj`. Godot generates the C# project
files automatically. The `.godot/` directory is gitignored and should never be committed.

---

## Directory Structure

```
botched-batch-brewery/
├── Prefabs/               # Reusable .tscn scene prefabs
│   ├── island.tscn
│   └── Gameplay/
│       └── player.tscn
├── Scenes/                # Top-level scenes (entry points / levels)
│   └── Island.tscn
├── Scripts/               # All C# source files
│   └── Gameplay/
│       ├── Player.cs
│       └── Player.cs.uid
├── .editorconfig
├── .prettierrc
├── project.godot          # Godot project configuration
└── AGENTS.md              # This file
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

Godot generates the `.csproj` on first editor launch. Run the editor at least once before
using `dotnet build` directly.

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

### Running a Single Test (future guidance)

```bash
# xUnit / NUnit — once a test project is configured:
dotnet test --filter "FullyQualifiedName~MyTestClass.MyTestMethod"

# GUT (GDScript-based) — once installed:
$GODOT4 --path . --headless -s addons/gut/gut_cmdln.gd -gtest=res://Tests/MyTest.gd
```

---

## Linting & Formatting

### Prettier (for non-C# files: JSON, YAML, Markdown, etc.)

Config: `.prettierrc`

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 4
}
```

```bash
npx prettier --write .       # format all supported files
npx prettier --check .       # check without writing
```

### C# Formatting

No Roslyn analyser or `dotnet format` configuration is committed yet. Follow the style
conventions below. When a `.editorconfig` with C# rules is added, run:

```bash
dotnet format
```

### EditorConfig

`.editorconfig` enforces `charset = utf-8` globally. Line endings are normalised to **LF**
via `.gitattributes` — do not commit CRLF line endings.

---

## C# Code Style

### File Layout

1. `using` directives — Godot namespaces first, then System, then third-party
2. `namespace` declaration (add once namespaces are introduced project-wide)
3. Class declaration

```csharp
using Godot;
using System;

public partial class MyNode : Node3D
{
    // ...
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
| Classes | PascalCase | `Player`, `BrewingSystem` |
| Public fields / constants | PascalCase | `Speed`, `JumpVelocity` |
| Private fields | `_camelCase` | `_isGrounded` |
| Local variables | camelCase | `inputDir`, `velocity` |
| Methods | PascalCase | `ApplyGravity()` |
| Godot lifecycle overrides | Underscore prefix (engine convention) | `_Ready()`, `_PhysicsProcess()` |
| Signals | PascalCase, past-tense | `BrewingCompleted` |

### Braces & Indentation

- **Allman style** — opening brace on its own line.
- **Tabs** for indentation (Godot's C# default; aligns with `.editorconfig` tab width of 4).

```csharp
public override void _PhysicsProcess(double delta)
{
    Vector3 velocity = Velocity;

    if (!IsOnFloor())
    {
        velocity += GetGravity() * (float)delta;
    }

    Velocity = velocity;
    MoveAndSlide();
}
```

### Types

- Prefer **explicit types** over `var` for clarity, especially with Godot types.
- Use Godot math types (`Vector3`, `Vector2`, `Mathf`, `Transform3D`) rather than
  System.Numerics equivalents.
- Use `float` (not `double`) for spatial values to match Godot's internal precision.
- `_PhysicsProcess` and `_Process` receive `double delta`; cast to `float` when passing
  into Godot math operations: `(float)delta`.

### Constants

Declare magic numbers as `const` fields with a descriptive name:

```csharp
public const float Speed = 5.0f;
public const float JumpVelocity = 4.5f;
```

### Godot-Specific Patterns

**CharacterBody3D physics loop** (idiomatic pattern — read → modify → write → move):

```csharp
public override void _PhysicsProcess(double delta)
{
    Vector3 velocity = Velocity;

    // Apply gravity
    if (!IsOnFloor())
        velocity += GetGravity() * (float)delta;

    // Read input
    Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
    Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();

    if (direction != Vector3.Zero)
        velocity.X = direction.X * Speed;
    else
        velocity.X = Mathf.MoveToward(velocity.X, 0, Speed);

    Velocity = velocity;
    MoveAndSlide();
}
```

**Node references** — cache node references in `_Ready()` using `GetNode<T>()` or
`[Export]` properties; avoid repeated `GetNode` calls inside per-frame methods.

### Error Handling

- Use `GD.PrintErr()` / `GD.PushError()` for engine-level errors (visible in Godot output).
- Use standard C# exceptions (`ArgumentException`, `InvalidOperationException`) for
  logic errors in non-Godot code paths.
- Validate `[Export]` node references in `_Ready()` with an early `null` check and
  `GD.PushError()` before proceeding.

```csharp
public override void _Ready()
{
    if (_camera == null)
    {
        GD.PushError($"{Name}: _camera export is not assigned.");
        return;
    }
}
```

---

## Scene & Asset Conventions

- Scene files use the `.tscn` (text) format — never binary `.scn`.
- Prefabs (reusable sub-scenes) go in `Prefabs/` with a subdirectory matching their domain.
- Top-level playable scenes go in `Scenes/`.
- One C# script per scene/node — name the script the same as the root node (e.g.
  `Player.cs` for the root node `Player`).
- `.uid` sidecar files are generated by Godot and **must be committed** alongside their
  corresponding `.cs` files.

---

## Environment Notes

- The `GODOT4` environment variable must point to the Godot 4 executable for VS Code
  debugging and headless CLI runs.
- The `.godot/` cache directory is gitignored; never commit its contents.
- EOL is enforced as **LF** by `.gitattributes` — configure your editor accordingly.
- All text files must use **UTF-8** encoding (enforced by `.editorconfig`).
