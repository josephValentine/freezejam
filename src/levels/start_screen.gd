extends Control

func _ready():
	$StartButton.pressed.connect(_on_start_pressed)
	$ShopButton.pressed.connect(_on_upgrade_pressed)

func _on_start_pressed():
	# Change to the game scene
	get_tree().change_scene_to_file("res://src/levels/levelOne.tscn")  # Adjust path as needed

func _on_upgrade_pressed():
	print("clicked upgrade")
	# Change to the upgrade scene
	get_tree().change_scene_to_file("res://src/levels/Upgrade_menu.tscn")  # Adjust path as needed
