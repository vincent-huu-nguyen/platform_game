extends Node2D

@onready var stuckTimer = $if_stuck_timer

func _process(delta): # doesnt work idk why
	if Engine.time_scale == 0.5:
		if not stuckTimer.is_stopped():
			stuckTimer.start()
			print("Timer started")

func _physics_process(delta):
	if Input.is_action_pressed("reset"):
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()

func _on_area_2d_body_entered(body):
	if body is Player:
		print("buff")
		body.buff()

func _on_if_stuck_timer_timeout(): # doesnt work idk why
	print("Timer timeout reached, reloading scene")
	get_tree().reload_current_scene()
