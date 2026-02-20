class_name PlayerSystem
extends RefCounted

static func role_base_attributes(role: String) -> Dictionary:
	match role:
		"Specialist Batter":
			return {
				"batting_average": 46.0,
				"strike_rate": 132.0,
				"aggression": 72,
				"defensive_skill": 68,
				"shot_timing": 78,
				"boundary_pct": 24,
				"consistency": 74,
				"economy_rate": 8.4,
				"wicket_ability": 24,
				"variation": 30,
				"accuracy": 35,
				"swing_spin": 28
			}
		"Specialist Bowler":
			return {
				"batting_average": 20.0,
				"strike_rate": 104.0,
				"aggression": 46,
				"defensive_skill": 52,
				"shot_timing": 54,
				"boundary_pct": 12,
				"consistency": 62,
				"economy_rate": 6.8,
				"wicket_ability": 78,
				"variation": 72,
				"accuracy": 74,
				"swing_spin": 75
			}
		_:
			return {
				"batting_average": 33.0,
				"strike_rate": 120.0,
				"aggression": 60,
				"defensive_skill": 60,
				"shot_timing": 63,
				"boundary_pct": 18,
				"consistency": 68,
				"economy_rate": 7.4,
				"wicket_ability": 63,
				"variation": 62,
				"accuracy": 62,
				"swing_spin": 62
			}

static func difficulty_mod(difficulty: String) -> float:
	match difficulty:
		"Easy":
			return 1.08
		"Hard":
			return 0.92
		_:
			return 1.0

static func create_profile(name: String, role: String, hand: String, bowling_style: String, jersey: int, country: String, difficulty: String) -> Dictionary:
	var base = role_base_attributes(role)
	var mod = difficulty_mod(difficulty)
	base.shot_timing = int(round(base.shot_timing * mod))
	base.consistency = int(round(base.consistency * mod))
	base.wicket_ability = int(round(base.wicket_ability * mod))
	base.accuracy = int(round(base.accuracy * mod))
	return {
		"id": "user_%d" % Time.get_unix_time_from_system(),
		"name": name,
		"role": role,
		"batting_hand": hand,
		"bowling_style": bowling_style,
		"jersey": jersey,
		"country": country,
		"difficulty": difficulty,
		"attributes": base,
		"career": {"matches": 0, "runs": 0, "wickets": 0}
	}

static func generate_ai_player(team_name: String, idx: int) -> Dictionary:
	var roles = ["Specialist Batter", "Specialist Batter", "All-Rounder", "All-Rounder", "Specialist Bowler", "Specialist Bowler"]
	var role = roles[idx % roles.size()]
	var base = role_base_attributes(role)
	for k in base.keys():
		if typeof(base[k]) == TYPE_INT:
			base[k] = clamp(base[k] + randi_range(-6, 6), 20, 95)
		if typeof(base[k]) == TYPE_FLOAT:
			base[k] = max(3.5, base[k] + randf_range(-0.6, 0.6))
	return {
		"id": "%s_%d" % [team_name.to_lower().replace(" ", "_"), idx],
		"name": "%s Player %d" % [team_name, idx + 1],
		"role": role,
		"batting_hand": "Right" if idx % 3 != 0 else "Left",
		"bowling_style": ["Fast", "Medium", "Spin"][idx % 3],
		"jersey": 10 + idx,
		"country": team_name,
		"attributes": base,
		"is_user": false
	}

static func derived_probabilities(batter: Dictionary, bowler: Dictionary, shot_risk: float, timing: float) -> Dictionary:
	var bat = batter.attributes
	var bowl = bowler.attributes
	var batting_power = (bat.shot_timing + bat.consistency + bat.aggression * 0.5) / 2.5
	var bowling_power = (bowl.wicket_ability + bowl.accuracy + bowl.variation) / 3.0
	var pressure_adj = clamp(shot_risk * 0.16, 0.0, 0.25)
	var timing_boost = clamp((timing - 0.5) * 0.6, -0.25, 0.25)
	var wicket = clamp(0.03 + (bowling_power - batting_power) / 250.0 + pressure_adj - timing_boost * 0.6, 0.02, 0.36)
	var boundary = clamp(0.10 + bat.boundary_pct / 180.0 + shot_risk * 0.22 + timing_boost * 0.25 - bowl.accuracy / 500.0, 0.04, 0.46)
	var dot = clamp(0.28 + bowl.accuracy / 220.0 - bat.strike_rate / 500.0 - timing_boost * 0.3, 0.12, 0.58)
	var mis_hit = clamp(0.09 + shot_risk * 0.2 - timing_boost * 0.35 + (100 - bat.shot_timing) / 400.0, 0.03, 0.45)
	return {
		"wicket": wicket,
		"boundary": boundary,
		"dot": dot,
		"mis_hit": mis_hit,
		"run": clamp(1.0 - wicket - dot, 0.22, 0.78)
	}
