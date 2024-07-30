class_name Projectile
extends RigidBody2D

var initial_velocity: float = 300.0
var life_time: float = 2.0
var damage: float = 1.0

@onready var life_timer = $LifeTimer
@onready var timer  = $RespawnTimer
@onready var gbamboo = $BambooSprite
@onready var ybamboo = $YBambooSprite

var wielder = null

func _ready() -> void:
	
	gbamboo.visible = false
	ybamboo.visible = false
	
	# Switches weapon sprites depending on the wielder
	print("Wielder: ", wielder.name)
	if wielder.name == "Player":
		gbamboo.visible = true
	elif wielder.name == "AIPlayer":
		ybamboo.visible = true
	
	# Convert rotation from radians to direction vector
	var direction = Vector2(1, 0).rotated(rotation)
	
	# Set the linear velocity in the direction the projectile is facing
	linear_velocity = direction * initial_velocity
	
	# Optional: Print information for debuagging
	print("Projectile velocity set to: ", linear_velocity, " with rotation: ", rotation)
	
	# Configure and start the life timer
	life_timer.wait_time = life_time
	life_timer.one_shot = true
	life_timer.start()
	# Correctly connect the signal
	life_timer.connect("timeout", Callable(self, "_on_LifeTimer_timeout"))

func _on_LifeTimer_timeout():
	queue_free()
	
