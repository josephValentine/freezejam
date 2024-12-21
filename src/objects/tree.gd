extends Node2D

var health = 50  # Starting health of the tree
var log_scene = preload("res://src/objects/log.tscn")
var coin_scene = preload("res://src/objects/coin.tscn")
var invulnerable = false
var invulnerability_time = 0.8 
@onready var invulnerability_timer = Timer.new()

func take_damage(damage_amount):
	if not invulnerable:
		health -= damage_amount
		invulnerable = true
		invulnerability_timer.start(invulnerability_time)
		if health <= 0:
			explode()
			queue_free()

func explode():
	print("explode called for: ", self.name)
	var num_logs = randi_range(0, 2)
	for i in range(num_logs):
		var log = log_scene.instantiate()
		log.position = position
		var impulse_strength = 400  # Adjust this value to change force
		var random_direction = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		log.apply_impulse(random_direction * impulse_strength)
		get_parent().add_child(log)
		
	var coins_rand = randi_range(0, 1)
	for i in range(coins_rand):
		var coin = coin_scene.instantiate()
		coin.position = position
		var impulse_strength = 400  # Adjust this value to change force
		var random_direction = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		coin.apply_impulse(random_direction * impulse_strength)
		get_parent().add_child(coin)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(invulnerability_timer)
	invulnerability_timer.one_shot = true
	invulnerability_timer.timeout.connect(_on_invulnerability_timer_timeout)

func _on_invulnerability_timer_timeout():
	invulnerable = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	# if area.name == 'ShottyBulletArea2D':
	# 	take_damage(50)
	# 	area.get_parent().queue_free()
	if area.get_parent().is_in_group("bullets"):
		var bullet = area.get_parent()
		var damage = bullet.damage_values["tree"]  
		take_damage(damage)
		bullet.queue_free()
