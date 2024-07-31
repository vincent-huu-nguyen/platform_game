extends Control

var stage_one = "res://scenes/game.tscn"

@onready var title = $CanvasLayer/Title
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
	title.hide()
	input_settings.show()


func _on_credits_pressed():
	credits.show()
	mainmenu.hide()


func _on_quit_pressed():
	get_tree().quit()


func _on_close_credits_pressed():
	credits.hide()
	mainmenu.show()


func _on_arcade_pressed():
	modes.hide()
	title.hide()
	ai_instructions.show()


func _on_back_pressed():
	modes.hide()
	mainmenu.show()
	title.show()


func _on_start_pressed():
	# get_tree().change_scene_to_file(stage_one)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_setting_pressed():
	input_settings.hide()
	mainmenu.show()
	title.show()
