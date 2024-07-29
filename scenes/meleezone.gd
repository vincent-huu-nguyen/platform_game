extends Area2D

# Reference to the Timer node
@onready var respawn_timer = $RespawnTimer

# AudioStreamPlayer for damage sound and KO'd sound
@onready var damaged_sound_player = $DamagedSound
@onready var ko_sound_player = $KOsound

func _on_body_entered(body):
	# Called when another body enters the Area2D's collision area
	if body.is_in_group("AIPlayer") and not body.is_invincible:
		body.take_damage(1)  # Inflicts damage to the player
		damaged_sound_player.play()  # Play damage sound
		# Check if the player's health is zero
		if body.health <= 0:
			ko_sound_player.play()  # Play KO sound
			print("ai died...")
			Engine.time_scale = 0.5  # Slow down the game to half speed
			body.get_node("CollisionShape2D").queue_free()  # Remove the player's collision shape
			respawn_timer.start()  # Start the Timer to trigger the scene reload after the specified wait time

func _on_respawn_timer_timeout():
	# Called when the Timer's wait time elapses
	print("RESPAWNED")  # Debug message to confirm the timer timeout function is called
	Engine.time_scale = 1.0  # Restore the game speed to normal
	get_tree().reload_current_scene()  # Reload the current scene to restart the game
