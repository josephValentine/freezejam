extends CharacterBody2D
@export var max_speed = 500
@export var acceleration = 1.5
@export var max_turn_speed = 250
@export var turn_acceleration = 5
@export var brake_acceleration = 10
var brakes = false
var hasShotty = false


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
	if Input.is_action_pressed("shoot"):
		print('shotty instanciate bullet and velocity', hasShotty)
	var turn_speed
	if velocity.y >= -50:
		turn_speed = max_turn_speed / 3
	else:
		turn_speed = max_turn_speed
		
	velocity.x = clamp(velocity.x, -turn_speed, turn_speed)
	velocity.y = clamp(velocity.y, -max_speed, 0 if brakes else -50)
	

	move_and_slide()
	
func _shotty():
	hasShotty = true
