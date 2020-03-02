extends Position3D

class_name Navigation_Node

signal clicked_destination(node)

var intersection_node : Texture
var path_node : Texture

var default_intersection_node : Texture = preload("res://default_assets/map/map_nodes/node_intersection.png")
var default_path_node : Texture = preload("res://default_assets/map/map_nodes/node_path.png")

onready var skin : Sprite3D
onready var actions : Node

var index : int
var connected_nodes : Array = []

func _ready() -> void:
#warning-ignore:return_value_discarded
	self.connect("clicked_destination", $"/root/Map", "_on_Navigation_Node_clicked_destination")

func initialize(node_info, node_index : int, path_img : Resource, intersection_img : Texture) -> void:
	skin  = ($Skin as Sprite3D)
	actions = $Actions
	
	intersection_node = intersection_img
	path_node = path_img
	
	index = node_index
	connected_nodes = node_info.connected_nodes
	
	translation = Vector3(node_info.x, 0, -node_info.y)
	rotation_degrees = Vector3(-60, 0 , 0)
	
	set_up_skin(connected_nodes.size())
	set_up_actions(node_info.actions as Array)

# If the desired node images aren't available, it will use the default ones
func set_up_skin(connected_nodes_num : int) -> void:
	if connected_nodes_num == 2:
		skin.texture = path_node
		
		if path_node == null:
			skin.texture = default_path_node
	else:
		skin.texture = intersection_node
		
		if intersection_node == null:
			skin.texture = default_intersection_node

func set_up_actions(actions_list : Array):
	for i in actions_list:
		var action : Generic_Action
		match (i.type as String):
			"travel":
				action = Travel_Action.new()
				action.name = "Travel_Action"
			"combat":
				action = Combat_Trigger_Action.new()
				action.name = "Combat_Action"
		
		action.initialize(i.data)
		actions.add_child(action, true)

func is_connected_to(node : Navigation_Node, all_nodes : Array) -> bool:
	for i in connected_nodes:
		if all_nodes[i].name == node.name:
			return true
	return false

func _on_Clickable_Navigation_input_event(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("click left mouse"):
		emit_signal("clicked_destination", self)
