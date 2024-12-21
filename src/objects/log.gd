extends RigidBody2D

var health = 50  # Starting health of the tree

func take_damage(damage_amount):
	health -= damage_amount
	if health <= 0:
		pass
		#queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("im a log and im here")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#if area.name == 'ShottyBulletArea2D':
		#take_damage(50)
		#area.get_parent().queue_free()
