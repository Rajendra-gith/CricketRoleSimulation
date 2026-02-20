extends Control

var role_select: OptionButton
var name_edit: LineEdit
var hand_select: OptionButton
var bowling_style_select: OptionButton
var jersey_spin: SpinBox
var country_edit: LineEdit
var difficulty_select: OptionButton
var status_label: Label
var root_box: VBoxContainer

func _ready() -> void:
	randomize()
	_build_ui()

func _build_ui() -> void:
	var center_container: CenterContainer = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)

	root_box = VBoxContainer.new()
	root_box.custom_minimum_size = Vector2(900, 700)
	center_container.add_child(root_box)

	var title: Label = Label.new()
	title.text = "3D Cricket Role Simulation"
	title.add_theme_font_size_override("font_size", 40)
	root_box.add_child(title)

	root_box.add_child(_subtitle("Step 1 - Choose your role"))
	role_select = OptionButton.new()
	role_select.add_item("Specialist Batter")
	role_select.add_item("Specialist Bowler")
	role_select.add_item("All-Rounder")
	root_box.add_child(_row("Primary Role", role_select))

	root_box.add_child(_subtitle("Step 2 - Personal profile"))
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Player Name"
	root_box.add_child(_row("Player Name", name_edit))

	hand_select = OptionButton.new()
	hand_select.add_item("Right")
	hand_select.add_item("Left")
	root_box.add_child(_row("Batting Hand", hand_select))

	bowling_style_select = OptionButton.new()
	bowling_style_select.add_item("Fast")
	bowling_style_select.add_item("Medium")
	bowling_style_select.add_item("Spin")
	bowling_style_select.add_item("None")
	root_box.add_child(_row("Bowling Style", bowling_style_select))

	jersey_spin = SpinBox.new()
	jersey_spin.min_value = 1
	jersey_spin.max_value = 999
	jersey_spin.value = 18
	root_box.add_child(_row("Jersey Number", jersey_spin))

	country_edit = LineEdit.new()
	country_edit.placeholder_text = "Country / Team"
	country_edit.text = "India"
	root_box.add_child(_row("Country / Team", country_edit))

	difficulty_select = OptionButton.new()
	difficulty_select.add_item("Easy")
	difficulty_select.add_item("Normal")
	difficulty_select.add_item("Hard")
	root_box.add_child(_row("Skill Difficulty", difficulty_select))

	var continue_button: Button = Button.new()
	continue_button.text = "Continue to Captain Panel"
	continue_button.pressed.connect(_on_continue_pressed)
	root_box.add_child(continue_button)

	status_label = Label.new()
	root_box.add_child(status_label)

func _subtitle(text_value: String) -> Label:
	var subtitle: Label = Label.new()
	subtitle.text = text_value
	subtitle.add_theme_font_size_override("font_size", 24)
	return subtitle

func _row(caption: String, input_control: Control) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	var name_label: Label = Label.new()
	name_label.text = caption
	name_label.custom_minimum_size = Vector2(220, 30)
	row.add_child(name_label)
	row.add_child(input_control)
	return row

func _on_continue_pressed() -> void:
	var player_name: String = name_edit.text.strip_edges()
	if player_name.is_empty():
		status_label.text = "Enter a player name."
		return

	var country_text: String = country_edit.text.strip_edges()
	if country_text.is_empty():
		country_text = "India"

	var profile: Dictionary = PlayerSystem.create_profile(
		player_name,
		role_select.get_item_text(role_select.selected),
		hand_select.get_item_text(hand_select.selected),
		bowling_style_select.get_item_text(bowling_style_select.selected),
		int(jersey_spin.value),
		country_text,
		difficulty_select.get_item_text(difficulty_select.selected)
	)

	ProfileManager.save_profile(profile)
	GameManager.set_user_profile(profile)
	get_tree().change_scene_to_file("res://scenes/ui/CaptainPanel.tscn")
