extends Node2D
var screen_size = Vector2(720, 1280)
var chunk_size = screen_size * 2
var tree_scene = preload("res://src/objects/tree.tscn")
var rock_scene = preload("res://src/objects/rock.tscn")
var player
var generated_chunks = []


func _ready():
	player = get_node("Player")
	_generate_next_chunk(Vector2.ZERO)  # Generate initial chunk

func _process(delta):
	if player:
		var distance = floor(-player.position.y / 100)
		#var distance = player.position.y
		var label = get_node("CanvasLayer/DistanceLabel")
		label.text = "Distance: %d" % distance

		# Calculate which chunk the player is in
		var player_chunk = (player.position / chunk_size).floor()
		var player_chunk_progress = (player.position - (player_chunk * chunk_size)) / chunk_size
		#print("player pos", player.position, "player chunk ", player_chunk, "player chunk progress", player_chunk_progress)

		# Generate chunks when player approaches chunk boundaries
		if player_chunk_progress.x >= 0.7:  # Moving right
			_generate_next_chunk(player_chunk + Vector2(1, 0))
			_generate_next_chunk(player_chunk + Vector2(1, -1))  # Also generate above
		if player_chunk_progress.x <= -0.7:  # Moving left
			_generate_next_chunk(player_chunk + Vector2(-1, 0))
			_generate_next_chunk(player_chunk + Vector2(-1, -1))  # Also generate above
		if player_chunk_progress.y >= 0.7:  # Moving up
			#print("ready to generate above", player_chunk, "player chunk progress: ", player_chunk_progress)
			_generate_next_chunk(player_chunk + Vector2(0, -1))
			_generate_next_chunk(player_chunk + Vector2(1, -1))  # Generate right-above
			_generate_next_chunk(player_chunk + Vector2(-1, -1))  # Generate left-above
			_delete_old_chunks(player_chunk.y)


	
func _generate_next_chunk(chunk_coord: Vector2):
	# Skip if chunk already exists
	if generated_chunks.has(chunk_coord):
		return
		
	generated_chunks.append(chunk_coord)
	var chunk_world_pos = chunk_coord * chunk_size
	#print("generating new chunk: ", chunk_world_pos, "player pos: ", player.position)
	var num_items = _calculate_items_for_dist(-chunk_world_pos.y)

	for i in range(num_items):
		var is_rock = randf() <= 0.15  # 10% chance for rocks
		var object = (rock_scene if is_rock else tree_scene).instantiate()
		add_child(object)
		object.add_to_group("static_objects")

		var random_x = chunk_world_pos.x + randf() * chunk_size.x - chunk_size.x/2
		var random_y = chunk_world_pos.y + randf() * chunk_size.y - chunk_size.y/2
		object.position = Vector2(random_x, random_y)
			#print("new tree at: ", tree.position, "player is at: ", player.position, "dist from player: ", tree.position.distance_to(player.position))

func _delete_old_chunks(current_y: float):
	# Find chunks to delete
	var chunks_to_delete = []
	for chunk_coord in generated_chunks:
		if chunk_coord.y > current_y + 1:  # Keep current chunk and one below
			chunks_to_delete.append(chunk_coord)
	
	# Remove chunks and their contents
	for chunk_coord in chunks_to_delete:
		generated_chunks.erase(chunk_coord)
		_delete_chunk_contents(chunk_coord)

func _delete_chunk_contents(chunk_coord: Vector2):
	var chunk_world_pos = chunk_coord * chunk_size
	
	# Get all static objects
	for obj in get_tree().get_nodes_in_group("static_objects"):
		var obj_chunk = (obj.position / chunk_size).floor()
		if obj_chunk == chunk_coord:
			#print("deleting a tree", obj)
			obj.queue_free()

func _calculate_items_for_dist(dist: float) -> int:
	var min_items := 100
	var max_items := 200
	var max_dist := 25000.0
	
	# If we're below max_height, scale between min and max items
	if dist < max_dist:
		var t = dist / max_dist  # Get percentage of max height
		return int(lerp(min_items, max_items, t))
	
	# If we're beyond max_height, return max items
	return max_items
