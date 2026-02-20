extends Node

const PROFILE_PATH = "user://profile.json"

var current_profile: Dictionary = {}

func _ready() -> void:
	load_profile()

func save_profile(profile: Dictionary) -> void:
	current_profile = profile.duplicate(true)
	var file = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_profile, "\t"))
		file.close()

func load_profile() -> Dictionary:
	if not FileAccess.file_exists(PROFILE_PATH):
		current_profile = {}
		return current_profile
	var file: FileAccess = FileAccess.open(PROFILE_PATH, FileAccess.READ)
	if not file:
		current_profile = {}
		return current_profile
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	current_profile = parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}
	return current_profile
