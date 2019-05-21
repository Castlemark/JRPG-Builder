extends Node

class_name Game_Manager

var campaign : Dictionary = {
	"name": "example_campaign",
	"cur_map": {
			"name": null,
		"access_point": null
	}
}

var UI : Dictionary = {
	"margin_bottom": null,
	"margin_right": null
}

var current_scene : Node = null

const MAP : Resource = preload("res://scenes/map/Map.tscn") 

onready var transition : ColorRect = $UI/Transition
onready var transition_tween : Tween = $UI/Transition/Tween


func _ready() -> void:
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	
	var campaign_data : Dictionary = Utils.load_json("res://campaigns/" + campaign.name + "/campaign.json")
	campaign.cur_map.name = campaign_data.map_name
	campaign.cur_map.access_point = campaign_data.access_point
	
	get_tree().root.connect("size_changed", self, "on_window_resize")
	on_window_resize()
	
	transition.margin_bottom = 0
	transition.margin_right = 0

func goto_scene(scene : Resource) -> void:
	""" 
	This function will usually be called from a signal callback,
	or some other function in the current scene.
	Deleting the current scene at this point is
	a bad idea, because it may still be executing code.
	This will result in a crash or unexpected behavior.
	
	The solution is to defer the load to a later time, when
	we can be sure that no code from the current scene is running:
	"""
	call_deferred("_deferred_goto_scene", scene)

# IMPROVE TRANSITION
func _deferred_goto_scene(scene : Resource) -> void:
	
	# We fade out to mask the transition
	transition.margin_bottom = UI.margin_bottom
	transition.margin_right = UI.margin_right

	transition_tween.interpolate_property(transition, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	transition_tween.start()
	yield(transition_tween,"tween_completed")
	
	# It is now safe to remove the current scene
	current_scene.free()
	
	# Instance the new scene.
	current_scene = scene.instance()
	
	
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	
	# We fade in to smooth the transition
	transition_tween.interpolate_property(transition, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	transition_tween.start()
	yield(transition_tween,"tween_completed")

	transition.margin_bottom = 0
	transition.margin_right = 0

func travel_to_map(map_name : String, access_point : int) -> void:
	campaign.cur_map.name = map_name
	campaign.cur_map.access_point = access_point
	
	goto_scene(MAP)

func on_window_resize() -> void:
	UI.margin_bottom = get_viewport().get_visible_rect().size.y
	UI.margin_right = get_viewport().get_visible_rect().size.x