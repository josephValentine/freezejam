extends RigidBody2D

var damage_values = {
	"tree": 0,
	"rock": 0,
	"log": 0
}

var velocity = Vector2.ZERO
var spread_angle = 0.0
var bullet_number = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_impulse(Vector2.from_angle(rotation) * 2000)
	# Disable collision with player and other bullets
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)  # Disable collision between bullets
	set_collision_mask_value(2, false)   # Disable collision between bullets
	
	# var direction = Vector2(sin(spread_angle), -cos(spread_angle))
	# var bullet_velocity = direction * bullet_speed
	# bullet_velocity += velocity
	# linear_velocity = bullet_velocity
	
	# Create and start a timer to destroy the bullet
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0  # Bullet lives for 2 seconds
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	# Create laser visual
	var laser_visual = ColorRect.new()
	laser_visual.color = Color(1, 0, 0, 0.8)  # Bright red, slightly transparent
	laser_visual.size = Vector2(30, 2)  # Long and thin
	laser_visual.position = Vector2(-15, -1)  # Center it
	add_child(laser_visual)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	queue_free()
