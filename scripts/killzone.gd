extends Area2D

@onready var timer = $Timer
@onready var death_sound_player = $Death

func _on_body_entered(body):
		print("You died!")
		death_sound_player.play()
		body.take_damage(5)
		Engine.time_scale = 0.5
		timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
