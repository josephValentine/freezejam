extends Node2D

var health = 50  # Starting health of the tree
var log_scene = preload("res://src/objects/log.tscn")

func take_damage(damage_amount):
	health -= damage_amount
	if health <= 0:
		explode()
		queue_free()

func explode():
	var num_logs = randi_range(1, 2)
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
