# Cricket Role Simulation 3D (Godot 4)

## Run
1. Open the `project` folder in Godot 4.2+.
2. Run the main scene (`scenes/ui/LaunchFlow.tscn`).

## Current Playable Scope (Phase 1)
- Role selection + player profile creation.
- JSON profile save/load (`user://profile.json`).
- Captain quick-match setup panel.
- Ball-by-ball simulation with player-stat based outcomes.
- Manual batting only when user is striker.
- Manual bowling only when user's assigned over is active.
- Auto simulation for all other balls.
- 3D stadium, 3D ball trajectory animation, and dynamic camera switching.
- Match result screen and JSON match history (`user://match_history.json`).

## Architecture Modules
- `scripts/autoload/GameManager.gd`
- `scripts/autoload/ProfileManager.gd`
- `scripts/autoload/MatchEngine.gd`
- `scripts/simulation/SimulationEngine.gd`
- `scripts/systems/PlayerSystem.gd`
- `scripts/systems/TeamSystem.gd`
- `scripts/controllers/BattingController.gd`
- `scripts/controllers/BowlingController.gd`
- `scripts/systems/FieldingSystem.gd`
- `scripts/systems/CameraManager.gd`
- `scripts/systems/UIManager.gd`
- `scripts/systems/ScorecardSystem.gd`
- `scripts/systems/AnimationManager.gd`

## Future-ready hooks
- Fielding control trigger point in `FieldingSystem.gd`.
- Additional conditions (pitch, weather, fatigue) can be added to `SimulationEngine.gd` and profile/team data.
- Career mode can use `GameManager.match_history` and profile `career` section.
