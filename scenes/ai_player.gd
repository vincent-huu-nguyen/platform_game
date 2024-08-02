extends CharacterBody2D

# Constants for movement, jumping, and dashing
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 450.0
const DASH_DURATION = 0.1
const DASH_COOLDOWN = 1.0
const MAX_HEALTH = 5
const REGEN_INTERVAL = 1.5
const MIN_DISTANCE = 115.0  # Minimum distance to keep from the player
const MAX_DISTANCE = 118.0  # Maximum distance to keep from the player

# Variables to manage physics and state
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_doublejump = false
var is_dashing = false
var dash_timer = 0.0
var can_dash = true
var health = MAX_HEALTH
var is_charged = false
var is_dead = false
var is_invincible = false

# Preloaded projectile scene for easy instantiation
var projectile = preload("res://scenes/projectile.tscn")
var can_fire = true
var rate_of_fire = max(1.0 - (0.015 * Global.score), 0.1) # increase rate of fire and ensure it does not go below 0.1

# Onready variables to cache node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var fire_timer = $FireTimer
@onready var charge_timer = $ChargeTimer
@onready var dash_cooldown_timer = $DashCooldown # Timer node for dash cooldown
@onready var hand_anchor = $HandAnchor
@onready var shooter = $HandAnchor/Shooter
@onready var weapon = $HandAnchor/Shooter/Weapon
@onready var regen_timer = $RegenTimer # Timer node for health regeneration
@onready var health_ui = $AnimatedSprite2D/Hearts
@onready var charged_sound_player = $Charged

# Reference to the player node
var player = null

func _ready():
	regen_timer.stop()
	charge_timer.start()
	add_to_group("AIPlayer") # Add AI to the "AIPlayer" group
	update_health_ui()
	player = get_tree().root.get_node("Game/Player") # Adjust path to player node

	#if Global.score >= 20:
	#	rate_of_fire = max(0.1 - (0.001 * (Global.score-19)), 0.01) #rate of fire increases by score, lowest is 0.01

# Called every frame
func _process(delta):
	if is_dead:
		return
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector2.ZERO
	else:
		aim_shooter()
		handle_shooting()
		handle_dashing()
		handle_movement()

# Called every physics frame
func _physics_process(delta):
	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return
	if not is_dashing:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			can_doublejump = true

		if is_on_floor():
			can_doublejump = true
		elif not is_on_floor() and can_doublejump:
			velocity.y = JUMP_VELOCITY 
			can_doublejump = false

	move_and_slide()

# Handles AI movement towards the player
# Handles AI movement towards the player while keeping a distance
func handle_movement():
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction = 0
		
		# Move towards player if too far
		if distance_to_player > MAX_DISTANCE:
			if player.global_position.x < global_position.x:
				direction = -1
			else:
				direction = 1
		# Move away from player if too close
		elif distance_to_player < MIN_DISTANCE:
			if player.global_position.x < global_position.x:
				direction = 1
			else:
				direction = -1

		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true

		if is_on_floor():
			if direction == 0:
				if animated_sprite.animation != "damaged":
					animated_sprite.play("idle")
			else:
				if animated_sprite.animation != "damaged":
					animated_sprite.play("run")
		else:
			if !can_doublejump:
				animated_sprite.play("midair")

		velocity.x = direction * SPEED

		# Jump randomly to shoot while moving
		if is_on_floor() and randf() < 0.03:
			velocity.y = JUMP_VELOCITY
			animated_sprite.play("jump")

# Aims the shooter towards the player
func aim_shooter():
	if player:
		var player_position = player.global_position
		var hand_anchor_position = hand_anchor.get_global_position()
		var direction = (player_position - hand_anchor_position).normalized()
		var offset_distance = 20  # Distance from hand anchor to shooter
		shooter.position = direction * offset_distance
		shooter.rotation = direction.angle()

# Handles shooting projectiles
func handle_shooting():
	if player and can_fire:  
		var min_shoot_chance = 0.008  # Minimum shooting chance regardless of health
		var shoot_chance = max(1.0 * (health / MAX_HEALTH), min_shoot_chance)  # Dynamic shooting chance based on health
		if randf() < shoot_chance:
			can_fire = false
			shooter.visible = false
			var projectile_instance = projectile.instantiate()
	
			projectile_instance.position = shooter.global_position
			projectile_instance.rotation = shooter.rotation
			projectile_instance.wielder = self
			projectile_instance.get_node("dmgzone").wielder = self  # Set the owner to the player
			if is_charged:
				weapon.visible = true
				projectile_instance.initial_velocity = 750.0  # altering variables from other scenes
				projectile_instance.life_time = 1.0
				projectile_instance.get_node("dmgzone").damage = 3
				get_parent().add_child(projectile_instance)
				is_charged = false
				charge_timer.start()
			else:
				charge_timer.stop()
				charge_timer.start()
				get_parent().add_child(projectile_instance)
				
			fire_timer.start(rate_of_fire)

			if not regen_timer.is_stopped():
				regen_timer.stop()
			regen_timer.start(REGEN_INTERVAL)

func _on_fire_timer_timeout():
	can_fire = true
	shooter.visible = true

# Handles dashing mechanics
func handle_dashing():
	if can_dash and randf() < 0.5:  # Random chance to dash
		is_dashing = true
		can_dash = false
		dash_timer = DASH_DURATION
		var direction = 1 if player.global_position.x > global_position.x else -1
		velocity = Vector2(direction * DASH_SPEED, 0)
		dash_cooldown_timer.start(DASH_COOLDOWN)

func _on_dash_cooldown_timeout():
	can_dash = true

# Handles health regeneration
func _on_regen_timer_timeout():
	if health < MAX_HEALTH:
		health += 1
		update_health_ui()
		if health < MAX_HEALTH:
			regen_timer.start(REGEN_INTERVAL)

func take_damage(amount):
	health -= amount
	animated_sprite.play("damaged")
	update_health_ui()
	print("AI health decreased to: ", health)
	if health <= 0:
		die()
	else:
		if not regen_timer.is_stopped():
			regen_timer.stop()
		regen_timer.start(REGEN_INTERVAL)

func die():
	is_dead = true
	shooter.visible = false
	animated_sprite.play("die")
	velocity = Vector2(0, 300)
	
	# Notify the player that the AI has died
	player = get_tree().root.get_node("Game/Player")  # Adjust path to player node
	if player:
		player.increment_score()

func update_health_ui():
	if health <= 0:
		health_ui.visible = 0
	else:
		health_ui.size.x = health * 10


func _on_charge_timer_timeout():
	is_charged = true
	weapon.visible = false
	charged_sound_player.play()
	charge_timer.stop()
	print("Charging Complete")


func recharge():
	is_charged = true
	weapon.visible = false
	charged_sound_player.play()
	charge_timer.stop()
	print("Charging Complete")
