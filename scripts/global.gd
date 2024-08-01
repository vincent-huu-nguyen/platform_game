extends Node


#create new file name in future updates
const SAVE_FILE_PATH = "user://savedata.save"

# Score variables
var score = 0
var highscore = 0
var permanant_buff = false

func _ready():
	# Load the highscore when the game starts
	load_highscore()
	# Initial check to update highscore if score is loaded from a saved game
	check_highscore()

# Function to reset the score
func reset_score():
	score = 0

func check_highscore(): #make score < highscore to reset
	if score > highscore and !permanant_buff:
		highscore = score
		save_highscore()

func save_highscore():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE_READ)
	file.store_32(highscore)

func load_highscore():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if FileAccess.file_exists(SAVE_FILE_PATH):
		highscore = file.get_32()

func perma_buff():
	permanant_buff = true
