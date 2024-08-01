class_name Projectile
extends RigidBody2D

var initial_velocity: float = 300.0
var life_time: float = 1.5
var damage: float = 1.0

@onready var life_timer = $LifeTimer
@onready var timer  = $RespawnTimer
@onready var collision = $CollisionPolygon2D3
@onready var gbamboo = $BambooSprite
@onready var ybamboo = $YBambooSprite
@onready var rbamboo = $ChargedBambooSprite
@onready var chargedshot_sound_player = $ChargedShot
@onready var shoot_sound_player = $Shoot

var wielder = null
var is_charged_weapon = false

func _ready() -> void:
	
	gbamboo.visible = false
	ybamboo.visible = false
	rbamboo.visible = false
	
	
	# Switches weapon sprites depending on the wielder
	print("Wielder: ", wielder.name)
	if wielder.is_charged == true:
		is_charged_weapon = true
		rbamboo.visible = true
		chargedshot_sound_player.play()
	else:
		if wielder.name == "AIPlayer":
			ybamboo.visible = true
		elif wielder.name == "AIPlayer2":
			ybamboo.visible = true
		elif wielder.name == "AIPlayer3":
			ybamboo.visible = true
		elif wielder.name == "Player" or "MM_AIPlayer":
			gbamboo.visible = true
		shoot_sound_player.play()
	
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
	

# If Red Panda catches charged bamboo, Red Panda recharges.
func _on_recharge_area_body_entered(body):
	if body.is_in_group("Player") and wielder.name == "Player" and is_charged_weapon:
			print("CHARGED WEAPON ALERT")
			body.recharge()
			queue_free()
			
	elif body.is_in_group("AIPlayer") and wielder.name == "AIPlayer" and is_charged_weapon:
			print("CHARGED WEAPON ALERT")
			body.recharge()
			queue_free()
