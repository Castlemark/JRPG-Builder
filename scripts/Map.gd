extends Spatial

class_name Map

var navigation_node_res : Resource = preload("res://scenes/map/Navigation_Node.tscn")
var between_node_res : Resource = preload("res://scenes/map/Between_node.tscn")

onready var GM : Node
onready var navigation_nodes : Spatial
onready var between_nodes : Spatial
onready var player_avatar : Player_Avatar

var path_img : Texture
var intersection_img : Texture
var between_img : Texture
var avatar_img : Texture


func initialize(map_name : String, acces_point : int):
	player_avatar = $Movables/Player_Avatar as Player_Avatar
	navigation_nodes = $Navigation_Nodes as Spatial
	between_nodes = $Between_Nodes as Spatial
	GM = $"/root/Game_Manager"
	
	var map_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign_name + "/maps/" + map_name + "/map.json")
	
	path_img = Utils.load_img("res://campaigns/" + GM.campaign_name + "/maps/" + map_name + "/map_nodes/node_path.png")
	intersection_img = Utils.load_img("res://campaigns/" + GM.campaign_name + "/maps/" + map_name + "/map_nodes/node_intersection.png")
	between_img = Utils.load_img("res://campaigns/" + GM.campaign_name + "/maps/" + map_name + "/map_nodes/node_between.png")
	avatar_img = Utils.load_img("res://campaigns/" + GM.campaign_name + "/maps/" + map_name + "/player_avatar.png")
	
	instantiate_navigation_nodes(map_data.navigation_nodes as Array)
	instantiate_between_nodes(map_data.navigation_nodes as Array)
	
	player_avatar.initialize(navigation_nodes.get_child(acces_point), avatar_img)
	

func instantiate_navigation_nodes(node_list : Array) -> void:
	var counter : int = 0
	for node in node_list:
		var nav_node = navigation_node_res.instance()
		nav_node.initialize(node as Dictionary, counter, path_img, intersection_img)
		navigation_nodes.add_child(nav_node, true)
		
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

func _on_Navigation_Node_clicked_destination(node : Navigation_Node) -> void:
	if node.is_connected_to(player_avatar.current_node, navigation_nodes.get_children()) and !player_avatar.is_moving():
		yield(player_avatar.move_to_pos(node), "completed")
