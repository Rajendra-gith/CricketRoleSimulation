extends Node

signal ball_committed(ball_setup: Dictionary)

func commit_ball(ball_setup: Dictionary) -> void:
	emit_signal("ball_committed", ball_setup)
