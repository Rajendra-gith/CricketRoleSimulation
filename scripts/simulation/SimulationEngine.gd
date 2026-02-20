class_name SimulationEngine
extends RefCounted

func simulate_ball(striker: Dictionary, bowler: Dictionary, context: Dictionary, input_data: Dictionary = {}) -> Dictionary:
	var shot_type: String = str(input_data.get("shot_type", "normal"))
	var shot_risk = _shot_risk(shot_type)
	var timing = float(input_data.get("timing", randf()))

	var probs = PlayerSystem.derived_probabilities(striker, bowler, shot_risk, timing)
	var roll = randf()
	if roll < probs.wicket:
		return {
			"runs": 0,
			"is_wicket": true,
			"wicket_type": ["Bowled", "Caught", "LBW"][randi() % 3],
			"commentary": "%s dismissed!" % striker.name,
			"shot_type": shot_type
		}

	roll -= probs.wicket
	if roll < probs.dot:
		return {
			"runs": 0,
			"is_wicket": false,
			"commentary": "Dot ball by %s." % bowler.name,
			"shot_type": shot_type
		}

	roll -= probs.dot
	if roll < probs.boundary:
		var is_six = shot_type == "lofted" and randf() > 0.45
		var val = 6 if is_six else 4
		return {
			"runs": val,
			"is_wicket": false,
			"commentary": "%s hammers %d!" % [striker.name, val],
			"shot_type": shot_type,
			"is_boundary": true
		}

	var singles = [1, 1, 2, 2, 3]
	var runs = singles[randi() % singles.size()]
	if shot_type == "defensive":
		runs = [0, 1, 1, 2][randi() % 4]
	return {
		"runs": runs,
		"is_wicket": false,
		"commentary": "%s takes %d run(s)." % [striker.name, runs],
		"shot_type": shot_type,
		"is_boundary": false
	}

func _shot_risk(shot: String) -> float:
	match shot:
		"defensive":
			return 0.1
		"normal":
			return 0.35
		"aggressive":
			return 0.62
		"lofted":
			return 0.85
		_:
			return 0.4
