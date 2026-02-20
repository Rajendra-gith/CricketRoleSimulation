extends Control

var toss_select: OptionButton
var overs_spin: SpinBox
var summary_label: Label
var teams: Array = []

func _ready() -> void:
	_build_ui()
	_prepare_teams()

func _build_ui() -> void:
	var center_container: CenterContainer = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)

	var root: VBoxContainer = VBoxContainer.new()
	root.custom_minimum_size = Vector2(1000, 650)
	center_container.add_child(root)

	var title = Label.new()
	title.text = "Captain Control Panel - Quick Match"
	title.add_theme_font_size_override("font_size", 34)
	root.add_child(title)

	toss_select = OptionButton.new()
	toss_select.add_item("Bat First")
	toss_select.add_item("Bowl First")
	root.add_child(_row("Toss Decision", toss_select))

	overs_spin = SpinBox.new()
	overs_spin.min_value = 2
	overs_spin.max_value = 20
	overs_spin.value = 5
	root.add_child(_row("Overs", overs_spin))

	summary_label = Label.new()
	summary_label.custom_minimum_size = Vector2(900, 280)
	root.add_child(summary_label)

	var btn = Button.new()
	btn.text = "Start Match"
	btn.pressed.connect(_on_start)
	root.add_child(btn)

func _row(label: String, node: Control) -> Control:
	var h = HBoxContainer.new()
	var l = Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(220, 30)
	h.add_child(l)
	h.add_child(node)
	return h

func _prepare_teams() -> void:
	teams = TeamSystem.create_quick_match_teams(GameManager.user_profile)
	var user_team = teams[0]
	var opp_team = teams[1]
	var txt = "You are captain of %s\nOpponent: %s\n\nPlaying XI (%s):\n" % [user_team.name, opp_team.name, user_team.name]
	for i in range(user_team.players.size()):
		var p = user_team.players[i]
		txt += "%d. %s (%s)%s\n" % [i + 1, p.name, p.role, " [YOU]" if p.get("is_user", false) else ""]
	txt += "\nBowling Plan (auto-assign for quick mode): "
	for i in range(user_team.bowling_plan.size()):
		txt += "Over %d -> %s; " % [i + 1, user_team.players[user_team.bowling_plan[i]].name]
	summary_label.text = txt

func _on_start() -> void:
	var overs = int(overs_spin.value)
	teams[0].bowling_plan = TeamSystem.build_bowling_plan(
		teams[0].players,
		overs,
		true,
		GameManager.user_profile.get("bowling_style", "None") != "None"
	)
	teams[1].bowling_plan = TeamSystem.build_bowling_plan(teams[1].players, overs, false, false)
	GameManager.quick_match_config = {
		"teams": teams,
		"user_team_idx": 0,
		"user_bats_first": toss_select.selected == 0,
		"overs": overs
	}
	get_tree().change_scene_to_file("res://scenes/match/MatchScene.tscn")
