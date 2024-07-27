extends Node2D

# Export variables to set in the Godot editor
@export var knockback_strength: float = 0.0
@export var knockback_direction: Vector2 = Vector2() # Initialize with default Vector2

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

# Method to get knockback strength
func get_knockback_strength() -> float:
	return knockback_strength

# Method to get knockback direction
func get_knockback_direction() -> Vector2:
	return knockback_direction

# Method to handle enemy-specific logic (override in subclasses)
func _ready():
	# Initialize anything specific to the enemy
	pass

# Add other common methods or functionality here
