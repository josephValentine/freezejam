extends CharacterBody2D
@export var max_speed = 500
@export var acceleration = 1.5
@export var max_turn_speed = 350
@export var turn_acceleration = 10
@export var brake_acceleration = 10
var brakes = false
var hasShotty = false
var cur_health = 100
var max_health = 100
var damage_speed_threshold = 100  # Minimum speed to take damage
var damage_multiplier = 0.15  # How much damage per unit of speed
var invulnerable = false
var invulnerability_time = 0.5 
@onready var invulnerability_timer = Timer.new()
# @export var shotty_bullet_scene: PackedScene  
var shotty_bullet_scene = preload("res://src/objects/shotty_bullet.tscn")
var shoot_cooldown = 0.0
var can_shoot = true


# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO
	get_node('../Shotgun').connect('person_touched', Callable(self, '_shotty'))

	 # Setup ski trail
	var scn = preload("res://src/SkiTrail.tscn")
	var left_trail = scn.instantiate()
	left_trail.set_offset(Vector2(5, 0))
	add_child(left_trail)

	var right_trail = scn.instantiate()
	right_trail.set_offset(Vector2(-5, 0))
	add_child(right_trail)

	 # Setup invulnerability timer
	add_child(invulnerability_timer)
	invulnerability_timer.one_shot = true
	invulnerability_timer.timeout.connect(_on_invulnerability_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y -= acceleration
	brakes = false
	# Check for input and update velocity
	if Input.is_action_pressed("move_right"):
		velocity.x += turn_acceleration
		velocity.y += turn_acceleration / 4
	if Input.is_action_pressed("move_left"):
		velocity.x -= turn_acceleration
		velocity.y += turn_acceleration / 4
	if Input.is_action_pressed("slow_down"):
		pass
		#velocity.y += brake_acceleration
		#brakes = true
	if Input.is_action_pressed("tuck"):
		velocity.y -= 50
	if Input.is_action_pressed("shoot") and hasShotty and can_shoot:
		shoot()
	var turn_speed
	if velocity.y >= -20:
		turn_speed = max_turn_speed / 8
	else:
		turn_speed = max_turn_speed
		
	velocity.x = clamp(velocity.x, -turn_speed, turn_speed)
	velocity.y = clamp(velocity.y, -max_speed, 0 if brakes else -50)
	

	move_and_slide()
	handle_collisions()
	
	if shoot_cooldown > 0:
		shoot_cooldown -= delta
		if shoot_cooldown <= 0:
			can_shoot = true

func _shotty():
	hasShotty = true

func handle_collisions():
	if invulnerable:
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("collision", collision.get_collider().get_parent().name)
		if collision and collision.get_collider().get_parent().is_in_group("static_objects"):
			var impact_speed = velocity.length()
			if impact_speed > damage_speed_threshold:
				var damage = (impact_speed - damage_speed_threshold) * damage_multiplier
				take_damage(damage)
				print("Collision speed: ", impact_speed, " Damage taken: ", damage, " Health: ", cur_health)

func take_damage(damage):
	cur_health -= damage
	invulnerable = true
	invulnerability_timer.start(invulnerability_time)

func _on_invulnerability_timer_timeout():
	invulnerable = false

func shoot():
	var bullet = shotty_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	
	# Add cooldown between shots
	shoot_cooldown = 0.5  # Adjust this value to control fire rate
	can_shoot = false
