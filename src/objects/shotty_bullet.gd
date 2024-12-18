extends RigidBody2D

var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Disable collision with player
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
	
	# Disable gravity and lock rotation
	gravity_scale = 0.0
	lock_rotation = true
	linear_damp = 0.0  # Prevents slowdown
	
	# Set bullet velocity
	var bullet_speed = 800
	var bullet_velocity = Vector2.UP.rotated(rotation) * bullet_speed
	bullet_velocity += velocity
	linear_velocity = bullet_velocity
	
	# Create and start a timer to destroy the bullet
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0  # Bullet lives for 2 seconds
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	queue_free()
