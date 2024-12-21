extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	print("in upgrade menu")
	$StartButton.pressed.connect(_on_start_pressed)


func _on_start_pressed():
	# Change to the game scene
	get_tree().change_scene_to_file("res://src/levels/levelOne.tscn")  # Adjust path as needed
