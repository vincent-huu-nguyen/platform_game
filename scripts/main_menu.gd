extends Control

var stage_one = "res://scenes/game.tscn"

@onready var credits = $Credits

func _on_start_pressed():
	get_tree().change_scene_to_file(stage_one)


func _on_settings_pressed():
	pass # Replace with function body.


func _on_credits_pressed():
	credits.show()


func _on_quit_pressed():
	get_tree().quit()


func _on_close_credits_pressed():
	credits.hide()
