extends Position3D

class_name Between_node

var between_img : Texture
var default_between_img : Texture = preload("res://default_assets/map/map_nodes/node_between.png")

func initialize(from_pos : Vector3, to_pos : Vector3, bet_img : Texture) -> void:
	translation = from_pos
	
	between_img = bet_img
	spawn_between_sprites(from_pos, to_pos)

func spawn_between_sprites(from : Vector3, to : Vector3) -> void:
	var distance : float = from.distance_to(to)
	var traveled_distance : float = 0.0
	var unit: Vector3 = (to - from).normalized()
	
	var cur_pos : Vector3 = Vector3(0, 0, 0)
	traveled_distance += 1.5 * unit.length()
	cur_pos += 1.5 * unit
	while traveled_distance < (distance - unit.length()):
		
		if traveled_distance < distance:
			var bet_sprite := Sprite3D.new()
			bet_sprite.translation = cur_pos
			bet_sprite.rotation_degrees = Vector3(-60, 0, 0)
			
			bet_sprite.texture = between_img
			if between_img == null:
				bet_sprite.texture = default_between_img
			add_child(bet_sprite, true)
		
		traveled_distance += 2 * unit.length()
		cur_pos += 2 * unit