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
var pistol_bullet_scene = preload("res://src/objects/pistol_bullet.tscn")
var raygun_bullet_scene = preload("res://src/objects/raygun_bullet.tscn")
var shoot_cooldown = 0.0
var can_shoot = true
var current_weapon = "none"  # Tracks which weapon is currently held
var weapons = {
	"none": null,
	"shotgun": {
		"shoot_func": "shoot_shotgun",
		"cooldown": 0.5,
		"damage": {
			"tree": 50,
			"rock": 30,
			"log": 40
		}
	},
	"pistol": {
		"shoot_func": "shoot_pistol",
		"cooldown": 0.3,
		"damage": {
			"tree": 20,
			"rock": 15,
			"log": 25
		}
	},
	"raygun": {
		"shoot_func": "shoot_raygun",
		"cooldown": 0.4,
		"damage": {
			"tree": 35,
			"rock": 45,
			"log": 35
		}
	}
}


# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO
	
	# Check for each weapon and connect if it exists
	var shotgun = get_node_or_null('../Shotgun')
	var pistol = get_node_or_null('../Pistol')
	var raygun = get_node_or_null('../Raygun')
	
	print("Found weapons - Shotgun: ", shotgun != null, " Pistol: ", pistol != null, " Raygun: ", raygun != null)
	
	if shotgun:
		shotgun.connect('person_touched', Callable(self, '_shotty'))
	if pistol:
		pistol.connect('person_touched', Callable(self, '_pistol'))
	if raygun:
		raygun.connect('person_touched', Callable(self, '_raygun'))
	
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
	if Input.is_action_pressed("shoot") and current_weapon != "none" and can_shoot:
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
	print("Shotgun picked up!")
	hasShotty = true
	current_weapon = "shotgun"

func _pistol():
	print("Pistol picked up!")
	current_weapon = "pistol"

func _raygun():
	print("Raygun picked up!")
	current_weapon = "raygun"

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

func take_damage(damage):
	cur_health -= damage
	invulnerable = true
	invulnerability_timer.start(invulnerability_time)
	if cur_health <= 0:
		print("die")
		if get_tree() != null:
			get_tree().change_scene_to_file("res://src/levels/Start_screen.tscn")  # Adjust path as needed


func _on_invulnerability_timer_timeout():
	invulnerable = false

func shoot():
	print("inside main shooting")
	if current_weapon in weapons:
		var weapon = weapons[current_weapon]
		call(weapon["shoot_func"])
		shoot_cooldown = weapon["cooldown"]
		can_shoot = false

func shoot_shotgun():
	print("shooting shotgun")
	var num_bullets = 5  # Adjust the number of bullets in the spread
	var spread_angle = 25  # Adjust the spread angle in degrees

	for i in range(num_bullets):
		var bullet_instance
		bullet_instance = shotty_bullet_scene.instantiate()
		bullet_instance.damage_values = weapons["shotgun"]["damage"]
		var angle_offset = randf_range(-spread_angle / 2, spread_angle / 2)  # Random offset within the spread angle

		bullet_instance.position = position  # Adjust the gun position node as needed

		var direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
		
		bullet_instance.rotation = direction.angle() + deg_to_rad(angle_offset)
		bullet_instance.add_to_group("bullets")  # Add bullets to a group for easy management
		get_parent().add_child(bullet_instance)
		bullet_instance.set("rotation", direction.angle() + deg_to_rad(angle_offset))  # Set the direction of the bullet
	shoot_cooldown = 0.5
	can_shoot = false


func shoot_pistol():
	print("shooting pistol")
	var bullet_instance = pistol_bullet_scene.instantiate()
	bullet_instance.damage_values = weapons["pistol"]["damage"]
	bullet_instance.position = position
	var direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	bullet_instance.rotation = direction.angle()
	bullet_instance.add_to_group("bullets")
	get_parent().add_child(bullet_instance)
	bullet_instance.set("rotation", direction.angle())

func shoot_raygun():
	print("shooting raygun")
	var bullet_instance = raygun_bullet_scene.instantiate()
	bullet_instance.damage_values = weapons["raygun"]["damage"]
	bullet_instance.position = position
	var direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	bullet_instance.rotation = direction.angle()
	bullet_instance.add_to_group("bullets")
	get_parent().add_child(bullet_instance)
	bullet_instance.set("rotation", direction.angle())
