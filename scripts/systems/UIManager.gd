class_name UIManager
extends CanvasLayer

signal batting_selected(shot_type: String, timing: float)
signal bowling_selected(config: Dictionary)

var score_label: Label
var status_label: Label
var commentary_label: Label
var camera_label: Label
var batting_panel: PanelContainer
var bowling_panel: PanelContainer
var line_opt: OptionButton
var length_opt: OptionButton
var ball_opt: OptionButton
var speed_slider: HSlider

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	score_label = Label.new()
	score_label.position = Vector2(20, 12)
	score_label.add_theme_font_size_override("font_size", 26)
	root.add_child(score_label)

	status_label = Label.new()
	status_label.position = Vector2(20, 48)
	status_label.add_theme_font_size_override("font_size", 18)
	root.add_child(status_label)

	commentary_label = Label.new()
	commentary_label.position = Vector2(20, 78)
	commentary_label.size = Vector2(980, 24)
	root.add_child(commentary_label)

	camera_label = Label.new()
	camera_label.position = Vector2(20, 106)
	root.add_child(camera_label)

	batting_panel = PanelContainer.new()
	batting_panel.position = Vector2(20, 640)
	batting_panel.size = Vector2(700, 160)
	root.add_child(batting_panel)
	var bat_v = VBoxContainer.new()
	batting_panel.add_child(bat_v)
	bat_v.add_child(_make_title("Manual Batting"))
	var row = HBoxContainer.new()
	bat_v.add_child(row)
	for shot in ["defensive", "normal", "aggressive", "lofted"]:
		var b = Button.new()
		b.text = shot.capitalize()
		b.pressed.connect(_on_shot_pressed.bind(shot))
		row.add_child(b)

	bowling_panel = PanelContainer.new()
	bowling_panel.position = Vector2(860, 560)
	bowling_panel.size = Vector2(700, 240)
	root.add_child(bowling_panel)
	var bowl_v = VBoxContainer.new()
	bowling_panel.add_child(bowl_v)
	bowl_v.add_child(_make_title("Manual Bowling"))

	line_opt = _make_option(["Off Stump", "Middle", "Leg Stump"])
	length_opt = _make_option(["Yorker", "Good", "Short"])
	ball_opt = _make_option(["Seam", "Swing", "Cutter", "Spin"])
	bowl_v.add_child(_labeled("Line", line_opt))
	bowl_v.add_child(_labeled("Length", length_opt))
	bowl_v.add_child(_labeled("Ball Type", ball_opt))
	speed_slider = HSlider.new()
	speed_slider.min_value = 110
	speed_slider.max_value = 155
	speed_slider.value = 132
	speed_slider.step = 1
	bowl_v.add_child(_labeled("Speed", speed_slider))

	var bowl_btn = Button.new()
	bowl_btn.text = "Deliver Ball"
	bowl_btn.pressed.connect(_on_bowl_pressed)
	bowl_v.add_child(bowl_btn)

	show_batting(false)
	show_bowling(false)

func _make_title(text: String) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 20)
	return l

func _make_option(values: Array) -> OptionButton:
	var o = OptionButton.new()
	for v in values:
		o.add_item(v)
	return o

func _labeled(title: String, node: Control) -> Control:
	var row = HBoxContainer.new()
	var l = Label.new()
	l.text = title
	l.custom_minimum_size = Vector2(120, 24)
	row.add_child(l)
	row.add_child(node)
	return row

func _on_shot_pressed(shot_type: String) -> void:
	var timing = clamp(randf() + randf_range(-0.15, 0.15), 0.0, 1.0)
	emit_signal("batting_selected", shot_type, timing)

func _on_bowl_pressed() -> void:
	emit_signal("bowling_selected", {
		"line": line_opt.get_item_text(line_opt.selected),
		"length": length_opt.get_item_text(length_opt.selected),
		"ball_type": ball_opt.get_item_text(ball_opt.selected),
		"speed": speed_slider.value
	})

func update_hud(score_text: String, status_text: String, commentary: String, cam_mode: String) -> void:
	score_label.text = score_text
	status_label.text = status_text
	commentary_label.text = commentary
	camera_label.text = "Camera: %s" % cam_mode

func show_batting(show: bool) -> void:
	batting_panel.visible = show

func show_bowling(show: bool) -> void:
	bowling_panel.visible = show
