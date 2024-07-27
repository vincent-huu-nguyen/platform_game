extends Area2D

# Reference to the Timer node
@onready var timer = $Timer

func _ready():
	# Called when the node is added to the scene
	if timer:
		print("Timer node found")  # Debug message to confirm the Timer node is found
	else:
		print("Timer node is not found")  # Debug message if Timer node is missing

func _on_body_entered(body):
	# Called when another body enters the Area2D's collision area
	if body.is_in_group("Player"):
		body.take_damage(1)  # Inflicts damage to the player
		# Check if the player's health is zero
		if body.health == 0:
			Engine.time_scale = 0.5  # Slow down the game to half speed
			body.get_node("CollisionShape2D").queue_free()  # Remove the player's collision shape
			timer.start()  # Start the Timer to trigger the scene reload after the specified wait time

func _on_timer_timeout():
	# Called when the Timer's wait time elapses
	print("respawned")  # Debug message to confirm the timer timeout function is called
	Engine.time_scale = 1.0  # Restore the game speed to normal
	get_tree().reload_current_scene()  # Reload the current scene to restart the game
