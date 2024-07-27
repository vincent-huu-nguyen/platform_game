extends Control

var heart_texture: Texture
var max_health: int
var player_health: int

# Called when the node enters the scene tree for the first time.
func _ready():
	update_health_display()

# Function to update the health display
func update_health_display():
	# Clear existing hearts
	var hbox = get_node("HBoxContainer")
	for child in hbox.get_children():
		child.queue_free()
	
	# Create hearts based on player health
	for i in range(max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		get_node("HBoxContainer").add_child(heart)
		
		# Set heart visibility based on current player health
		if i >= player_health:
			heart.visible = false
