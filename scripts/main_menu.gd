extends Control

var stage_one = "res://scenes/game.tscn"

@onready var mainmenu = $CanvasLayer/MainMenu
@onready var credits = $CanvasLayer/Credits
@onready var modes = $CanvasLayer/ModeSelect
@onready var ai_instructions = $CanvasLayer/ai_HowToPlay
@onready var input_settings = $CanvasLayer/InputSettings


func _on_play_pressed():
	mainmenu.hide()
	modes.show()

func _on_settings_pressed():
	mainmenu.hide()
	input_settings.show()


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
	get_tree().change_scene_to_file("res://scenes/game.tscn")
