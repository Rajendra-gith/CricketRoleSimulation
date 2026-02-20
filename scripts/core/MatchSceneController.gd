extends Node3D

@onready var ball: MeshInstance3D = $Ball
@onready var ui: CanvasLayer = $UI
@onready var camera_manager: Node3D = $Cameras
@onready var batting_controller: Node = $Controllers/BattingController
@onready var bowling_controller: Node = $Controllers/BowlingController
@onready var anim_manager: Node = $Systems/AnimationManager
@onready var fielding_system: Node = $Systems/FieldingSystem

var sim = SimulationEngine.new()
var match_state: Dictionary
var awaiting_input = false
var cached_outcome: Dictionary = {}

func _ready() -> void:
	randomize()
	_setup_stadium()
	var cfg = GameManager.quick_match_config
	match_state = MatchEngine.create_quick_match_state(cfg.teams[0], cfg.teams[1], cfg.user_team_idx, cfg.user_bats_first, cfg.overs)
	(ui as UIManager).batting_selected.connect(_on_batting_selected)
	(ui as UIManager).bowling_selected.connect(_on_bowling_selected)
	_run_match_loop()

func _setup_stadium() -> void:
	var field_mat = StandardMaterial3D.new()
	field_mat.albedo_color = Color(0.16, 0.47, 0.18)
	$Stadium/Ground.material_override = field_mat

	var pitch_mat = StandardMaterial3D.new()
	pitch_mat.albedo_color = Color(0.78, 0.68, 0.5)
	$Stadium/Pitch.material_override = pitch_mat

	var sky = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.58, 0.77, 0.96)
	sky.environment = env
	add_child(sky)

func _run_match_loop() -> void:
	while not match_state.is_complete:
		var striker = MatchEngine.striker(match_state)
		var bowler = MatchEngine.bowler(match_state)
		var user_id = GameManager.user_profile.id
		var user_is_striker = striker.id == user_id
		var user_is_bowler = bowler.id == user_id
		var context = {"state": match_state}

		var outcome: Dictionary
		if user_is_striker:
			(camera_manager as CameraManager).switch_camera("striker")
			(ui as UIManager).show_batting(true)
			(ui as UIManager).show_bowling(false)
			awaiting_input = true
			cached_outcome = {}
			while awaiting_input:
				await get_tree().process_frame
			outcome = cached_outcome
		elif user_is_bowler:
			(camera_manager as CameraManager).switch_camera("runup")
			(ui as UIManager).show_batting(false)
			(ui as UIManager).show_bowling(true)
			awaiting_input = true
			cached_outcome = {}
			while awaiting_input:
				await get_tree().process_frame
			outcome = cached_outcome
		else:
			(camera_manager as CameraManager).switch_camera("broadcast")
			(ui as UIManager).show_batting(false)
			(ui as UIManager).show_bowling(false)
			outcome = sim.simulate_ball(striker, bowler, context, {"shot_type": "normal", "timing": randf()})
			await get_tree().create_timer(0.25).timeout

		MatchEngine.apply_outcome(match_state, outcome)
		await (anim_manager as AnimationManager).play_ball_animation(ball, outcome.get("runs", 0) > 0)
		(fielding_system as Node).check_fielding_chance(outcome)

		if outcome.get("is_wicket", false):
			await (anim_manager as AnimationManager).play_wicket_replay(camera_manager)
		elif outcome.get("is_boundary", false):
			(camera_manager as CameraManager).switch_camera("aerial")
			await get_tree().create_timer(0.7).timeout
			(camera_manager as CameraManager).switch_camera("broadcast")
		else:
			(camera_manager as CameraManager).switch_camera("tracking")
			await get_tree().create_timer(0.35).timeout
			(camera_manager as CameraManager).switch_camera("broadcast")

		_update_hud(outcome.get("commentary", ""))
		await get_tree().create_timer(0.35).timeout

	_finish_match()

func _on_batting_selected(shot_type: String, timing: float) -> void:
	if not awaiting_input:
		return
	var outcome = sim.simulate_ball(MatchEngine.striker(match_state), MatchEngine.bowler(match_state), {"state": match_state}, {"shot_type": shot_type, "timing": timing})
	cached_outcome = outcome
	awaiting_input = false

func _on_bowling_selected(ball_setup: Dictionary) -> void:
	if not awaiting_input:
		return
	var risk = 0.35
	if ball_setup.length == "Yorker":
		risk = 0.25
	elif ball_setup.length == "Short":
		risk = 0.5
	var timing = clamp(0.55 + (float(ball_setup.speed) - 130.0) / 100.0, 0.25, 0.95)
	var input = {"shot_type": "normal", "timing": timing - risk * 0.2}
	cached_outcome = sim.simulate_ball(MatchEngine.striker(match_state), MatchEngine.bowler(match_state), {"state": match_state}, input)
	cached_outcome.commentary = "%s (%s, %s) -> %s" % [GameManager.user_profile.name, ball_setup.line, ball_setup.length, cached_outcome.commentary]
	awaiting_input = false

func _update_hud(commentary: String) -> void:
	var inn = MatchEngine.current_innings(match_state)
	var batting_team = match_state.teams[inn.batting_idx]
	var score = "%s %d/%d (%s ov)" % [batting_team.name, inn.runs, inn.wickets, MatchEngine.over_text(match_state)]
	var striker = MatchEngine.striker(match_state)
	var non_striker = MatchEngine.non_striker(match_state)
	var bowler = MatchEngine.bowler(match_state)
	var status = "Striker: %s | Non-striker: %s | Bowler: %s | RRR: %.2f" % [striker.name, non_striker.name, bowler.name, MatchEngine.required_run_rate(match_state)]
	(ui as UIManager).update_hud(score, status, commentary, (camera_manager as CameraManager).current_mode)

func _finish_match() -> void:
	var summary = ScorecardSystem.match_summary(match_state)
	GameManager.record_match(summary)
	GameManager.quick_match_config.last_result = summary
	get_tree().change_scene_to_file("res://scenes/ui/ResultScene.tscn")
