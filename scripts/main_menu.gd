extends Control

var stage_one = "res://scenes/game.tscn"

@onready var mainmenu = $MainMenu
@onready var credits = $Credits
@onready var modes = $ModeSelect
@onready var ai_instructions = $ai_HowToPlay

func _on_play_pressed():
	mainmenu.hide()
	modes.show()

func _on_settings_pressed():
	pass # Replace with function body.


func _on_credits_pressed():
	credits.show()


func _on_quit_pressed():
	get_tree().quit()


func _on_close_credits_pressed():
	credits.hide()


func _on_ai_pressed():
	modes.hide()
	ai_instructions.show()


func _on_back_pressed():
	modes.hide()
	mainmenu.show()


func _on_start_pressed():
	# get_tree().change_scene_to_file(stage_one)
	get_tree().change_scene_to_file("res://scenes/stage2.tscn")
