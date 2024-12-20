class_name Ski_trail
extends Line2D
@onready var curve := Curve2D.new()
const MAX_POINTS = 5000
var offset: Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	curve.add_point(get_parent().position + offset)
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	points = curve.get_baked_points()
	
func set_offset(offset: Vector2):
	self.offset = offset
