extends Node

const MATCH_HISTORY_PATH = "user://match_history.json"

var user_profile: Dictionary = {}
var quick_match_config: Dictionary = {}
var match_history: Array = []

func _ready() -> void:
	user_profile = ProfileManager.current_profile.duplicate(true)
	load_match_history()

func set_user_profile(profile: Dictionary) -> void:
	user_profile = profile.duplicate(true)

func load_match_history() -> void:
	if not FileAccess.file_exists(MATCH_HISTORY_PATH):
		match_history = []
		return
	var file: FileAccess = FileAccess.open(MATCH_HISTORY_PATH, FileAccess.READ)
	if not file:
		match_history = []
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	match_history = parsed as Array if typeof(parsed) == TYPE_ARRAY else []

func record_match(summary: Dictionary) -> void:
	match_history.push_front(summary)
	if match_history.size() > 30:
		match_history = match_history.slice(0, 30)
	var file: FileAccess = FileAccess.open(MATCH_HISTORY_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(match_history, "\t"))
		file.close()
