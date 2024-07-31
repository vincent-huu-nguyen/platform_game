extends Node2D

var is_paused = false
var enter_label = false
var tryagain_label = false

@onready var respawnTimer = $if_stuck_timer
@onready var pauseMenu = $CanvasLayer/PauseMenu

@onready var press_enter = $CanvasLayer/PressEnter
@onready var enter_player = $CanvasLayer/PressEnter/AnimationPlayer

@onready var player = $Player

func _ready():
	Engine.time_scale = 1.0

func _process(delta): # doesnt work idk why
	if (all_ai_bots_dead() and enter_label == false):
		enter_label = true
		press_enter.show()
		Engine.time_scale = 0.5  # Slow down the game to half speed
		play_animation("countdown")
		respawnTimer.start()
		
	elif player.is_dead and enter_label == false:
		enter_label = true
		press_enter.show()
		Engine.time_scale = 0.5  # Slow down the game to half speed
		play_animation("tryagain")
		respawnTimer.start()
		
func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		Engine.time_scale = 1.0
		var rand = randi_range(1, 3)
		if rand == 1:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		elif rand == 2:
			get_tree().change_scene_to_file("res://scenes/stage2.tscn")
		elif rand == 3:
			get_tree().reload_current_scene()
			

func _on_if_stuck_timer_timeout(): # respawnTimer
	Engine.time_scale = 1.0
	
	# restart to first stage if lose
	if player.is_dead:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		var rand = randi_range(1, 3)
		if rand == 1:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		elif rand == 2:
			get_tree().change_scene_to_file("res://scenes/stage2.tscn")
		elif rand == 3:
			get_tree().reload_current_scene()

func all_ai_bots_dead() -> bool:
	# Checks if all AI bots in the scene are dead
	var ai_bots = get_tree().get_nodes_in_group("AIPlayer")
	for ai_bot in ai_bots:
		if !ai_bot.is_dead:  # Assuming 'is_alive' is a property or method you have to check the AI's status
			return false
	return true

func play_animation(animation_name: String):
	enter_player.stop()
	enter_player.play(animation_name, -1.0, 1.0, false) #plays the animation from the start
