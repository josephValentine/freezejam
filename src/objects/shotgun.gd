extends Node2D
signal person_touched

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Assuming your player node is named "Player"
		print('picked up gun', body)
		emit_signal('person_touched')
		queue_free()
