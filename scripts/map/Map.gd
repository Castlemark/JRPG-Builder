extends Spatial

class_name Map

const TILE_SIZE = 1000

var navigation_node_res : Resource = preload("res://scenes/map/Navigation_Node.tscn")
var between_node_res : Resource = preload("res://scenes/map/Between_node.tscn")
var background_tile_res : Resource = preload("res://scenes/map/Background_Tile.tscn")

onready var GM := $"/root/Game_Manager"
onready var navigation_nodes := $Navigation_Nodes as Spatial
onready var between_nodes := $Between_Nodes as Spatial
onready var background := $Backgorund as Spatial
onready var player_avatar := $Player_Avatar as Player_Avatar
onready var camera := $Player_Avatar/Camera as Map_Camera

var path_img : Texture
var intersection_img : Texture
var between_img : Texture
var avatar_img : Texture
var map_img : Texture

func _ready() -> void:
	initialize(GM.campaign.cur_map.name, GM.campaign.cur_map.access_point)

func initialize(map_name : String, acces_point : int):
	
	var map_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/maps/" + map_name + "/map.json")
	
	path_img = Utils.load_img("res://campaigns/" + GM.campaign.name + "/maps/" + map_name + "/map_nodes/node_path.png")
	intersection_img = Utils.load_img("res://campaigns/" + GM.campaign.name + "/maps/" + map_name + "/map_nodes/node_intersection.png")
	between_img = Utils.load_img("res://campaigns/" + GM.campaign.name + "/maps/" + map_name + "/map_nodes/node_between.png")
	avatar_img = Utils.load_img("res://campaigns/" + GM.campaign.name + "/maps/" + map_name + "/player_avatar.png")
	map_img = Utils.load_img("res://campaigns/" + GM.campaign.name + "/maps/" + map_name + "/map.png")
	
	instantiate_navigation_nodes(map_data.navigation_nodes as Array)
	instantiate_between_nodes(map_data.navigation_nodes as Array)
	instantiate_background_map(Vector2(map_data.backgroung_info.x_offset, map_data.backgroung_info.y_offset))
	

	player_avatar.initialize(navigation_nodes.get_child(acces_point), avatar_img)
	

func instantiate_navigation_nodes(node_list : Array) -> void:
	var counter : int = 0
	for node in node_list:
		var nav_node = navigation_node_res.instance()
		navigation_nodes.add_child(nav_node, true)
		nav_node.initialize(node as Dictionary, counter, path_img, intersection_img)
		
		counter += 1

func instantiate_between_nodes(node_list : Array) -> void:
	var nav_nodes : Array = navigation_nodes.get_children()
	
	var counter : int = 0
	for node in node_list:
		for connection in node.connected_nodes:
			var unique : bool = true
			for child in between_nodes.get_children():
				if String(counter) in child.name and String(connection) in child.name:
					unique = false
					break
			
			#we check if the between node has been created and if the connection exists in both parties
			if unique and counter in nav_nodes[connection].connected_nodes and connection in nav_nodes[counter].connected_nodes:
				var bet_node = between_node_res.instance()
				
				var from : Vector3 = nav_nodes[counter].translation
				var to :Vector3 = nav_nodes[connection].translation
				
				bet_node.initialize(from, to, between_img)
				bet_node.name = String(counter) + "_to_" + String(connection)
				between_nodes.add_child(bet_node)
		
		counter += 1

func instantiate_background_map(offset : Vector2):
	var map_size := Vector2(4000, 4000)
	if map_img != null:
		map_size = map_img.get_size()
	
	for i in range(0, map_size.x, 1000):
		for j in range(0, map_size.y, 1000):
			var back_tile = background_tile_res.instance()
			
			back_tile.initialize(Vector2(i, j), 
			                     map_img, 
			                     Vector2(i/100.0 - 10 * offset.x, map_size.y/100.0 - j/100.0 - 10 * (offset.y + 1)))
			background.add_child(back_tile, true)

func _on_Navigation_Node_clicked_destination(node : Navigation_Node) -> void:
	if node.is_connected_to(player_avatar.current_node, navigation_nodes.get_children()) and !player_avatar.is_moving():
		camera.return_to_original_position()
		yield(player_avatar.move_to_pos(node), "completed")
