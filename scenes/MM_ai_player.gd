extends CharacterBody2D

# Constants and Variables
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 450.0
const DASH_DURATION = 0.1
const DASH_COOLDOWN = 1.0
const MAX_HEALTH = 5
const REGEN_INTERVAL = 1.0
const MIN_DISTANCE = 115.0  # Minimum distance to keep from the player
const MAX_DISTANCE = 118.0  # Maximum distance to keep from the player
const MOVE_DURATION = 1.0   # Duration to move in one direction

# Variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_doublejump = false
var is_dashing = false
var dash_timer = 0.0
var can_dash = true
var health = MAX_HEALTH
var is_charged = false
var is_dead = false
var is_invincible = false
var movement_timer = 0.0  # Timer to track movement duration
var movement_direction = 1  # Current movement direction

# Preloaded projectile scene
var projectile = preload("res://scenes/projectile.tscn")
var can_fire = true
var rate_of_fire = max(1.0 - (0.1 * Global.score), 0.1)

# Onready nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var fire_timer = $FireTimer
@onready var charge_timer = $ChargeTimer
@onready var dash_cooldown_timer = $DashCooldown
@onready var hand_anchor = $HandAnchor
@onready var shooter = $HandAnchor/Shooter
@onready var weapon = $HandAnchor/Shooter/Weapon
@onready var regen_timer = $RegenTimer
@onready var health_ui = $AnimatedSprite2D/Hearts
@onready var charged_sound_player = $Charged

var target = null

func _ready():
	regen_timer.stop()
	charge_timer.start()
	add_to_group("AIPlayer")
	update_health_ui()
	find_target()
	# Initialize movement direction and timer
	movement_direction = randi_range(1, 2)  # Randomly set initial direction
	movement_timer = MOVE_DURATION

func _process(delta):
	if is_dead:
		return
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector2.ZERO
	else:
		movement_timer -= delta  # Decrease the movement timer
		if movement_timer <= 0:
			# Change direction and reset timer when duration is up
			movement_direction = randi_range(1, 2)
			movement_timer = MOVE_DURATION

		aim_shooter()
		handle_shooting()
		handle_dashing()
		handle_movement(delta)

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

func handle_movement(delta):
	if target:
		var distance_to_target = global_position.distance_to(target.global_position)
		var direction = movement_direction

		if direction == 2:
			direction = -1  # Default to moving right if no direction is set

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

		if is_on_floor() and randf() < 0.03:
			velocity.y = JUMP_VELOCITY
			animated_sprite.play("jump")

func aim_shooter():
	if target:
		var target_position = target.global_position
		var hand_anchor_position = hand_anchor.get_global_position()
		var direction = (target_position - hand_anchor_position).normalized()
		var offset_distance = 20
		shooter.position = direction * offset_distance
		shooter.rotation = direction.angle()

func handle_shooting():
	if target and can_fire:  
		var min_shoot_chance = 0.008
		var shoot_chance = max(1.0 * (health / MAX_HEALTH), min_shoot_chance)
		if randf() < shoot_chance:
			can_fire = false
			shooter.visible = false
			var projectile_instance = projectile.instantiate()
	
			projectile_instance.position = shooter.global_position
			projectile_instance.rotation = shooter.rotation
			projectile_instance.wielder = self
			projectile_instance.get_node("dmgzone").wielder = self
			if is_charged:
				weapon.visible = true
				projectile_instance.initial_velocity = 750.0
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

func handle_dashing():
	if can_dash and randf() < 0.5:
		is_dashing = true
		can_dash = false
		dash_timer = DASH_DURATION
		var direction = 1 if target.global_position.x > global_position.x else -1
		velocity = Vector2(direction * DASH_SPEED, 0)
		dash_cooldown_timer.start(DASH_COOLDOWN)

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_regen_timer_timeout():
	if health < MAX_HEALTH:
		health += 1
		update_health_ui()
		if health < MAX_HEALTH:
			regen_timer.start(REGEN_INTERVAL)

func take_damage(amount):
	if health >= 4:
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

func find_target():
	var ai_bots = get_tree().get_nodes_in_group("AIPlayer")
	for ai in ai_bots:
		if ai != self:
			target = ai
			print("Target found:", target)
			return
	call_deferred("find_target")
