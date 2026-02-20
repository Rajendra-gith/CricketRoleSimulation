extends Node

signal fielding_event_ready(event_type: String)

func check_fielding_chance(_outcome: Dictionary) -> void:
	# Future-ready hook: catches/run-outs can trigger user fielding control here.
	return
