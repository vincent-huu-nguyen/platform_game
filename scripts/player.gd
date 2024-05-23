extends CharacterBody2D
class_name Player

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_doublejump = false

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		can_doublejump = true

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true
	elif Input.is_action_just_pressed("jump") and !is_on_floor() and can_doublejump:
		velocity.y = JUMP_VELOCITY 
		can_doublejump = false

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
			
		if Input.is_action_pressed("jump"):
			animated_sprite.play("jump")
		
		if Input.is_action_pressed("crouch"):
			animated_sprite.play("crouch")
	else:
		if !can_doublejump:
			animated_sprite.play("midair")
	
	# Apply movement
	if Input.is_action_pressed("crouch") and is_on_floor():
		velocity.x = 0
	else:	
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
