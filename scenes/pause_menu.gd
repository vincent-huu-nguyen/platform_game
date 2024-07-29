extends Control

@onready var pauseMenu = $"."

func _process(delta):
	testEsc()

func resume():
	get_tree().paused = false
	pauseMenu.visible = false

func pause():
	get_tree().paused = true
	pauseMenu.visible = true

func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()


func _on_resume_pressed():
	resume()


func _on_restart_pressed():
	Global.score = 0
	Engine.time_scale = 1.0
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed():
	Engine.time_scale = 1.0
	Global.permanant_buff = false
	resume()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
