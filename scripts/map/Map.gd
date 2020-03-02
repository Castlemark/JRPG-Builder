extends Spatial

class_name Map

const TILE_SIZE = 1000

var navigation_node_res : Resource = preload("res://scenes/map/Navigation_Node.tscn")
var between_node_res : Resource = preload("res://scenes/map/Between_node.tscn")
var background_tile_res : Resource = preload("res://scenes/map/Background_Tile.tscn")
var detail_node_res : Resource = preload("res://scenes/map/Detail_Node.tscn")

onready var GM := $"/root/Game_Manager"
onready var navigation_nodes := $Navigation_Nodes as Spatial
onready var between_nodes := $Between_Nodes as Spatial
onready var background := $Backgorund as Spatial
onready var details := $Details as Spatial
onready var player_avatar := $Player_Avatar as Player_Avatar
onready var camera := $Player_Avatar/Camera as Map_Camera

onready var combat_viewport := $UI/Combat_Viewport as Combat_Viewport

var path_img : Texture
var intersection_img : Texture
var between_img : Texture
var avatar_img : Texture
var map_img : Texture

func _ready() -> void:
	if GM.campaign_data == null:
		return
	initialize(GM.campaign_data.maps.get(GM.campaign_data.cur_map))

func initialize(map) -> void:
	path_img = map.path_texture
	intersection_img = map.intersection_texture
	between_img = map.between_texture
	avatar_img = map.avatar_texture
	map_img = map.map_floor

	instantiate_navigation_nodes(map.navigation_nodes as Array)
	instantiate_between_nodes(map.navigation_nodes as Array)
	instantiate_background_map(map.background_info)
	instantiate_details(map.detail_art)

	player_avatar.initialize(navigation_nodes.get_child(map.access_point) as Navigation_Node, avatar_img)

func instantiate_navigation_nodes(node_list : Array) -> void:
	var counter : int = 0
	for node in node_list:
		var nav_node = navigation_node_res.instance()
		navigation_nodes.add_child(nav_node, true)
		nav_node.initialize(node, counter, path_img, intersection_img)

		counter += 1

func instantiate_between_nodes(node_list : Array) -> void:
	var nav_nodes : Array = navigation_nodes.get_children()
	
	var counter : int = 0
	for node in node_list:
		for connection in node.connected_nodes:
			var unique := true
			for child in between_nodes.get_children():
				if String(counter) in child.name and String(connection) in child.name:
					unique = false
					break

			#we check if the between node has been created and if the connection exists in both parties
			if unique \
			   and (counter in nav_nodes[connection].connected_nodes) \
			   and (connection in nav_nodes[counter].connected_nodes):
				var bet_node = between_node_res.instance()

				var from : Vector3 = nav_nodes[counter].translation
				var to :Vector3 = nav_nodes[connection].translation

				bet_node.initialize(from, to, between_img)
				bet_node.name = String(counter) + "_to_" + String(connection)
				between_nodes.add_child(bet_node)

			# TODO warn here if 2 connected nodes do not appear as connected in "connected_nodes" of both parties

		counter += 1

# TODO refactor and implement scale factor
func instantiate_background_map(background_info) -> void:
	var offset := Vector2(background_info.x_offset, background_info.y_offset)

	var map_size := Vector2(4000, 4000)
	if map_img != null:
		map_size = map_img.get_size()

	for i in range(0, map_size.x, TILE_SIZE):
		for j in range(0, map_size.y, TILE_SIZE):
			var back_tile = background_tile_res.instance()

			back_tile.initialize(Vector2(i, j),
								 map_img,
								 Vector2(i/100.0 - 10 * offset.x, map_size.y/100.0 - j/100.0 - 10 * (offset.y + 1)))
			background.add_child(back_tile, true)

func instantiate_details(details_list : Array) -> void:
	for detail_info in details_list:
		var detail_node = detail_node_res.instance()
		details.add_child(detail_node, true)
		detail_node.initialize(detail_info)


func _on_Navigation_Node_clicked_destination(node : Navigation_Node) -> void:
	if node.is_connected_to(player_avatar.current_node, navigation_nodes.get_children()) and !player_avatar.is_moving():
		camera.return_to_original_position()
		yield(player_avatar.move_to_pos(node), "completed")
