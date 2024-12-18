extends CharacterBody2D
@export var max_speed = 500
@export var acceleration = 1.5
@export var max_turn_speed = 250
@export var turn_acceleration = 5
@export var brake_acceleration = 10
var brakes = false
var hasShotty = false
# @export var shotty_bullet_scene: PackedScene  
var shotty_bullet_scene = preload("res://src/objects/shotty_bullet.tscn")
var shoot_cooldown = 0.0
var can_shoot = true


# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO
	get_node('../Shotgun').connect('person_touched', Callable(self, '_shotty'))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y -= acceleration
	brakes = false
	# Check for input and update velocity
	if Input.is_action_pressed("move_right"):
		velocity.x += turn_acceleration
		velocity.y += turn_acceleration / 5
	if Input.is_action_pressed("move_left"):
		velocity.x -= turn_acceleration
		velocity.y += turn_acceleration / 5
	if Input.is_action_pressed("slow_down"):
		velocity.y += brake_acceleration
		brakes = true
	if Input.is_action_pressed("tuck"):
		velocity.y -= 50
	if Input.is_action_pressed("shoot") and hasShotty and can_shoot:
		shoot()
	var turn_speed
	if velocity.y >= -50:
		turn_speed = max_turn_speed / 3
	else:
		turn_speed = max_turn_speed
		
	velocity.x = clamp(velocity.x, -turn_speed, turn_speed)
	velocity.y = clamp(velocity.y, -max_speed, 0 if brakes else -50)
	

	move_and_slide()
	
	if shoot_cooldown > 0:
		shoot_cooldown -= delta
		if shoot_cooldown <= 0:
			can_shoot = true

func _shotty():
	hasShotty = true

func shoot():
	var bullet = shotty_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	
	# Add cooldown between shots
	shoot_cooldown = 0.5  # Adjust this value to control fire rate
	can_shoot = false
