extends Node2D

func _physics_process(delta):
	if Input.is_action_pressed("reset"):
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()

func _on_area_2d_body_entered(body):
	if body is Player:
		print("win")
