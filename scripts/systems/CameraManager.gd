class_name CameraManager
extends Node3D

var cameras: Dictionary = {}
var current_mode = "broadcast"

func _ready() -> void:
	cameras = {
		"broadcast": $BroadcastCamera,
		"runup": $RunupCamera,
		"striker": $StrikerCamera,
		"tracking": $TrackingCamera,
		"aerial": $AerialCamera,
		"replay": $ReplayCamera
	}
	switch_camera("broadcast")

func switch_camera(mode: String) -> void:
	if not cameras.has(mode):
		mode = "broadcast"
	for k in cameras.keys():
		(cameras[k] as Camera3D).current = false
	(cameras[mode] as Camera3D).current = true
	current_mode = mode
