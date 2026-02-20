extends Node

signal shot_committed(shot_type: String, timing: float)

func commit_shot(shot_type: String, timing: float) -> void:
	emit_signal("shot_committed", shot_type, timing)
