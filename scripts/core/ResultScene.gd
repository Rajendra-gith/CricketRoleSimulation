extends Control

func _ready() -> void:
	var summary: Dictionary = GameManager.quick_match_config.get("last_result", {})
	var center_container: CenterContainer = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)

	var root: VBoxContainer = VBoxContainer.new()
	root.custom_minimum_size = Vector2(900, 520)
	center_container.add_child(root)

	var title = Label.new()
	title.text = "Match Result"
	title.add_theme_font_size_override("font_size", 40)
	root.add_child(title)

	var body = Label.new()
	body.text = "Winner: %s\nMargin: %s\nPlayer of Match: %s" % [summary.get("winner", ""), summary.get("margin", ""), summary.get("player_of_match", "")]
	body.add_theme_font_size_override("font_size", 24)
	root.add_child(body)

	var btn1 = Button.new()
	btn1.text = "Play Another Quick Match"
	btn1.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/CaptainPanel.tscn"))
	root.add_child(btn1)

	var btn2 = Button.new()
	btn2.text = "Back to Profile Setup"
	btn2.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/LaunchFlow.tscn"))
	root.add_child(btn2)
