class_name AnimationManager
extends Node

func play_ball_animation(ball: Node3D, was_hit: bool) -> void:
	var tw = get_tree().create_tween()
	ball.position = Vector3(0.0, 1.0, -8.0)
	if was_hit:
		tw.tween_property(ball, "position", Vector3(randf_range(-12, 12), 0.7, randf_range(8, 22)), 0.7)
	else:
		tw.tween_property(ball, "position", Vector3(randf_range(-0.6, 0.6), 0.7, 2.0), 0.45)
	await tw.finished

func play_wicket_replay(camera_manager: Node3D) -> void:
	camera_manager.switch_camera("replay")
	await get_tree().create_timer(1.0).timeout
	camera_manager.switch_camera("broadcast")
