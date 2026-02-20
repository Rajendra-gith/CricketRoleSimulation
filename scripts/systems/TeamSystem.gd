class_name TeamSystem
extends RefCounted

static func create_quick_match_teams(user_profile: Dictionary) -> Array:
	var user_team_name: String = str(user_profile.get("country", "India"))
	var opp_team_name = _random_opponent(user_team_name)
	var user_team = _build_team(user_team_name, true, user_profile)
	var opp_team = _build_team(opp_team_name, false, {})
	return [user_team, opp_team]

static func _build_team(name: String, includes_user: bool, user_profile: Dictionary) -> Dictionary:
	var players: Array = []
	for i in range(11):
		players.append(PlayerSystem.generate_ai_player(name, i))

	if includes_user:
		var user_player = {
			"id": user_profile.id,
			"name": user_profile.name,
			"role": user_profile.role,
			"batting_hand": user_profile.batting_hand,
			"bowling_style": user_profile.bowling_style,
			"jersey": user_profile.jersey,
			"country": user_profile.country,
			"attributes": user_profile.attributes,
			"is_user": true
		}
		players[0] = user_player

	var batting_order = range(11)
	var bowling_plan: Array = build_bowling_plan(players, 5, includes_user, user_profile.get("bowling_style", "None") != "None")

	return {
		"name": name,
		"players": players,
		"batting_order": batting_order,
		"bowling_plan": bowling_plan
	}

static func build_bowling_plan(players: Array, overs: int, include_user: bool, user_can_bowl: bool) -> Array:
	var plan: Array = []
	for over in range(overs):
		var idx = 5 + (over % 5)
		if idx >= players.size():
			idx = players.size() - 1
		if include_user and user_can_bowl and over % 2 == 0:
			idx = 0
		plan.append(idx)
	return plan

static func _random_opponent(user_team_name: String) -> String:
	var teams = ["Australia", "England", "Pakistan", "South Africa", "New Zealand", "Sri Lanka"]
	teams.erase(user_team_name)
	return teams[randi() % teams.size()]
