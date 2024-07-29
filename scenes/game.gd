extends Node2D

var is_paused = false

@onready var stuckTimer = $if_stuck_timer
@onready var pauseMenu = $CanvasLayer/PauseMenu

func _ready():
	Engine.time_scale = 1.0

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

