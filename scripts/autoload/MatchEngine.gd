extends Node

const BALLS_PER_OVER: int = 6

func create_quick_match_state(team_a: Dictionary, team_b: Dictionary, user_team_idx: int, user_bats_first: bool, overs_limit: int = 5) -> Dictionary:
	var first_batting: int = 0 if user_bats_first else 1
	var state: Dictionary = {
		"teams": [team_a, team_b],
		"user_team_idx": user_team_idx,
		"overs_limit": overs_limit,
		"innings": [],
		"innings_index": 0,
		"is_complete": false,
		"result": {}
	}
	var innings_list: Array = state["innings"] as Array
	innings_list.append(_new_innings(first_batting, 1 - first_batting, overs_limit, 0, state["teams"] as Array))
	return state

func _new_innings(batting_idx: int, bowling_idx: int, overs_limit: int, target: int, teams: Array) -> Dictionary:
	var innings: Dictionary = {
		"batting_idx": batting_idx,
		"bowling_idx": bowling_idx,
		"overs_limit": overs_limit,
		"target": target,
		"runs": 0,
		"wickets": 0,
		"balls": 0,
		"striker_slot": 0,
		"non_striker_slot": 1,
		"next_slot": 2,
		"batting_score": {},
		"bowling_score": {},
		"ball_log": []
	}

	var batting_team_data: Dictionary = teams[batting_idx] as Dictionary
	var bowling_team_data: Dictionary = teams[bowling_idx] as Dictionary
	var batting_players: Array = batting_team_data["players"] as Array
	var bowling_players: Array = bowling_team_data["players"] as Array
	var batting_score: Dictionary = innings["batting_score"] as Dictionary
	var bowling_score: Dictionary = innings["bowling_score"] as Dictionary

	for p in batting_players:
		var player: Dictionary = p as Dictionary
		batting_score[player["id"]] = {
			"name": player["name"],
			"runs": 0,
			"balls": 0,
			"fours": 0,
			"sixes": 0,
			"out": false,
			"dismissal": ""
		}

	for p in bowling_players:
		var player: Dictionary = p as Dictionary
		bowling_score[player["id"]] = {
			"name": player["name"],
			"balls": 0,
			"runs": 0,
			"wickets": 0
		}

	return innings

func current_innings(state: Dictionary) -> Dictionary:
	var innings_list: Array = state["innings"] as Array
	return innings_list[int(state["innings_index"])] as Dictionary

func batting_team(state: Dictionary) -> Dictionary:
	var teams: Array = state["teams"] as Array
	return teams[int(current_innings(state)["batting_idx"])] as Dictionary

func bowling_team(state: Dictionary) -> Dictionary:
	var teams: Array = state["teams"] as Array
	return teams[int(current_innings(state)["bowling_idx"])] as Dictionary

func striker(state: Dictionary) -> Dictionary:
	var inn: Dictionary = current_innings(state)
	var team: Dictionary = batting_team(state)
	var batting_order: Array = team["batting_order"] as Array
	var players: Array = team["players"] as Array
	var slot: int = int(inn["striker_slot"])
	var player_idx: int = int(batting_order[slot])
	return players[player_idx] as Dictionary

func non_striker(state: Dictionary) -> Dictionary:
	var inn: Dictionary = current_innings(state)
	var team: Dictionary = batting_team(state)
	var batting_order: Array = team["batting_order"] as Array
	var players: Array = team["players"] as Array
	var slot: int = int(inn["non_striker_slot"])
	var player_idx: int = int(batting_order[slot])
	return players[player_idx] as Dictionary

func bowler(state: Dictionary) -> Dictionary:
	var inn: Dictionary = current_innings(state)
	var team: Dictionary = bowling_team(state)
	var balls: int = int(inn["balls"])
	var over_index: int = int(floor(float(balls) / float(BALLS_PER_OVER)))
	var plan: Array = team["bowling_plan"] as Array
	var idx: int = int(plan[min(over_index, plan.size() - 1)])
	var players: Array = team["players"] as Array
	return players[idx] as Dictionary

func apply_outcome(state: Dictionary, outcome: Dictionary) -> void:
	if bool(state["is_complete"]):
		return

	var inn: Dictionary = current_innings(state)
	var s: Dictionary = striker(state)
	var b: Dictionary = bowler(state)
	var batting_score: Dictionary = inn["batting_score"] as Dictionary
	var bowling_score: Dictionary = inn["bowling_score"] as Dictionary
	var bat: Dictionary = batting_score[s["id"]] as Dictionary
	var bowl: Dictionary = bowling_score[b["id"]] as Dictionary
	var runs: int = int(outcome.get("runs", 0))
	var is_wicket: bool = bool(outcome.get("is_wicket", false))

	inn["runs"] = int(inn["runs"]) + runs
	inn["balls"] = int(inn["balls"]) + 1
	bat["runs"] = int(bat["runs"]) + runs
	bat["balls"] = int(bat["balls"]) + 1
	bowl["runs"] = int(bowl["runs"]) + runs
	bowl["balls"] = int(bowl["balls"]) + 1

	if runs == 4:
		bat["fours"] = int(bat["fours"]) + 1
	if runs == 6:
		bat["sixes"] = int(bat["sixes"]) + 1

	if is_wicket:
		inn["wickets"] = int(inn["wickets"]) + 1
		bat["out"] = true
		bat["dismissal"] = str(outcome.get("wicket_type", "Out"))
		bowl["wickets"] = int(bowl["wickets"]) + 1
		if int(inn["next_slot"]) <= 10:
			inn["striker_slot"] = int(inn["next_slot"])
			inn["next_slot"] = int(inn["next_slot"]) + 1
	elif runs % 2 == 1:
		_swap_strike(inn)

	if int(inn["balls"]) % BALLS_PER_OVER == 0:
		_swap_strike(inn)

	var ball_log: Array = inn["ball_log"] as Array
	ball_log.append({
		"ball": int(inn["balls"]),
		"striker": str(s["name"]),
		"bowler": str(b["name"]),
		"runs": runs,
		"is_wicket": is_wicket,
		"commentary": str(outcome.get("commentary", ""))
	})

	_check_transitions(state)

func _swap_strike(inn: Dictionary) -> void:
	var t: int = int(inn["striker_slot"])
	inn["striker_slot"] = int(inn["non_striker_slot"])
	inn["non_striker_slot"] = t

func _check_transitions(state: Dictionary) -> void:
	var inn: Dictionary = current_innings(state)
	var balls: int = int(inn["balls"])
	var overs_limit: int = int(inn["overs_limit"])
	var wickets: int = int(inn["wickets"])
	var target: int = int(inn["target"])
	var runs: int = int(inn["runs"])
	var overs_done: bool = balls >= overs_limit * BALLS_PER_OVER
	var all_out: bool = wickets >= 10
	var chase_done: bool = target > 0 and runs > target

	if not (overs_done or all_out or chase_done):
		return

	if int(state["innings_index"]) == 0:
		var innings_list: Array = state["innings"] as Array
		var teams: Array = state["teams"] as Array
		innings_list.append(_new_innings(int(inn["bowling_idx"]), int(inn["batting_idx"]), int(state["overs_limit"]), int(inn["runs"]), teams))
		state["innings_index"] = 1
	else:
		state["is_complete"] = true
		state["result"] = build_result(state)

func build_result(state: Dictionary) -> Dictionary:
	var innings_list: Array = state["innings"] as Array
	var first: Dictionary = innings_list[0] as Dictionary
	var second: Dictionary = innings_list[1] as Dictionary
	var teams: Array = state["teams"] as Array
	var winner: String = "Tie"
	var margin: String = ""

	if int(second["runs"]) > int(first["runs"]):
		winner = str((teams[int(second["batting_idx"])] as Dictionary)["name"])
		margin = "%d wickets" % (10 - int(second["wickets"]))
	elif int(second["runs"]) < int(first["runs"]):
		winner = str((teams[int(first["batting_idx"])] as Dictionary)["name"])
		margin = "%d runs" % (int(first["runs"]) - int(second["runs"]))

	return {"winner": winner, "margin": margin, "innings": innings_list}

func over_text(state: Dictionary) -> String:
	var balls: int = int(current_innings(state)["balls"])
	return "%d.%d" % [int(float(balls) / float(BALLS_PER_OVER)), balls % BALLS_PER_OVER]

func required_run_rate(state: Dictionary) -> float:
	if int(state["innings_index"]) == 0:
		return 0.0
	var inn: Dictionary = current_innings(state)
	var needed: int = int(max(0, int(inn["target"]) + 1 - int(inn["runs"])))
	var left: int = int(max(1, int(inn["overs_limit"]) * BALLS_PER_OVER - int(inn["balls"])))
	return (float(needed) / float(left)) * 6.0
