extends CharacterBody2D

@export var min_speed = 200
@export var max_speed = 450
@export var max_height = 10000
var target: Node2D  # Will be set to player

func _ready():
	# Assuming the player is a sibling node named "Player"
	target = get_node("../Player")

func _physics_process(delta):
	if not target:
		return
		
 # Calculate speed based on height
	var height = -global_position.y  # Convert negative y to positive height
	var current_speed = min_speed
	if height < max_height:
		var t = height / max_height  # Get percentage of max height
		current_speed = lerp(min_speed, max_speed, t)
	else:
		current_speed = max_speed
		
	# Get direction to player and move
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * current_speed
	
	# Move and check for collisions
	move_and_slide()
	
	# Check if we hit the player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision and collision.get_collider() == target:
			print("Got the player!")
			target.take_damage(1000)
