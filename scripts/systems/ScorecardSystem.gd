class_name ScorecardSystem
extends RefCounted

static func player_of_match(match_state: Dictionary) -> Dictionary:
	var best = {"name": "", "impact": -1.0}
	for inn in match_state.innings:
		for id in inn.batting_score.keys():
			var entry = inn.batting_score[id]
			var score = float(entry.runs) + entry.fours * 1.5 + entry.sixes * 2.2
			if score > best.impact:
				best = {"name": entry.name, "impact": score}
		for id in inn.bowling_score.keys():
			var bowl = inn.bowling_score[id]
			var overs = float(bowl.balls) / 6.0
			var econ_bonus = max(0.0, 8.0 - (float(bowl.runs) / max(0.5, overs)))
			var score2 = bowl.wickets * 14.0 + econ_bonus
			if score2 > best.impact:
				best = {"name": bowl.name, "impact": score2}
	return best

static func match_summary(match_state: Dictionary) -> Dictionary:
	var pom = player_of_match(match_state)
	return {
		"winner": match_state.result.get("winner", ""),
		"margin": match_state.result.get("margin", ""),
		"player_of_match": pom.name,
		"timestamp": Time.get_datetime_string_from_system()
	}
