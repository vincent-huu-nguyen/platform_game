extends Area2D

# Reference to the Timer node
@onready var respawn_timer = $RespawnTimer

# Cooldown timer to prevent repeated damage
@onready var damage_cooldown_timer = $DmgCooldownTimer

# AudioStreamPlayer for damage sound and KO'd sound
@onready var damaged_sound_player = $DamagedSound
@onready var ko_sound_player = $KOsound

# Cooldown duration in seconds
const DAMAGE_COOLDOWN = 0.5

# Flag to track if damage can be applied
var can_damage = true

# Can be altered through ownership(referencing)
var damage = 1

var wielder = null


func _ready():
	# Called when the node is added to the scene
	if respawn_timer:
		print("Timer node found")  # Debug message to confirm the Timer node is found
	else:
		print("Timer node is not found")  # Debug message if Timer node is missing
	
	if damage_cooldown_timer:
		print("Damage cooldown timer found")
	else:
		print("Damage cooldown timer is not found")

func _on_body_entered(body):
	# Called when another body enters the Area2D's collision area
	if can_damage and body != wielder: # Check if the body is not the owner
		if body.is_in_group("Player") and not body.is_invincible:
			body.take_damage(damage)  # Inflicts damage to the player
			damaged_sound_player.play()  # Play damage sound
			# Check if the player's health is zero
			if body.health <= 0:
				ko_sound_player.play()  # Play KO sound
				print("player died...")
				Engine.time_scale = 0.5  # Slow down the game to half speed
				body.get_node("CollisionShape2D").queue_free()  # Remove the player's collision shapes
				body.get_node("CrouchColShape2D").queue_free()
				body.get_node("DashColShape2D").queue_free()
				respawn_timer.start()  # Start the Timer to trigger the scene reload after the specified wait time
			start_damage_cooldown()  # Start the cooldown timer
		
		if body.is_in_group("AIPlayer") and not body.is_invincible:
			body.take_damage(damage)  # Inflicts damage to the player
			damaged_sound_player.play()  # Play damage sound
			# Check if the player's health is zero
			if body.health <= 0:
				ko_sound_player.play()  # Play KO sound
				print("ai died...")
				Engine.time_scale = 0.5  # Slow down the game to half speed
				body.get_node("CollisionShape2D").queue_free()  # Remove the player's collision shape
				respawn_timer.start()  # Start the Timer to trigger the scene reload after the specified wait time
			start_damage_cooldown()  # Start the cooldown timer

func start_damage_cooldown():
	can_damage = false
	damage_cooldown_timer.start(DAMAGE_COOLDOWN)
	
func _on_dmg_cooldown_timer_timeout():
	# Called when the damage cooldown timer's wait time elapses
	can_damage = true
	print("Damage cooldown ended")

func _on_respawn_timer_timeout():
	# Called when the Timer's wait time elapses
	print("RESPAWNED")  # Debug message to confirm the timer timeout function is called
	Engine.time_scale = 1.0  # Restore the game speed to normal
	
	# random stage
	var rand = randi_range(1, 3)
	if rand == 1:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	elif rand == 2:
		get_tree().change_scene_to_file("res://scenes/stage2.tscn")
	elif rand == 3:
		get_tree().change_scene_to_file("res://scenes/stage3.tscn")
	
