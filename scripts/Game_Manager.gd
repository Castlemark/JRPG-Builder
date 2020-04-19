extends Node

var UI : Dictionary = {
	"margin_bottom": null,
	"margin_right": null
}

var campaign_data := Model.Campaign_Data.new()

var current_scene : Node = null

const MAP : Resource = preload("res://scenes/map/Map.tscn") 
const TITLE_SCREEN : Resource = preload("res://scenes/ui/title_screen/Title_Screen.tscn")

onready var transition : ColorRect = $UI/Transition as ColorRect
onready var transition_tween : Tween = $UI/Transition/Tween as Tween
onready var menus : Menu_Manager


func _ready() -> void:
	### SETUP ###
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	#############
	
	### CONFIG ###
	get_tree().root.connect("size_changed", self, "on_window_resize")
	on_window_resize()
	
	resize_transition(false)
	##############

func load_campaign(campaign_name : String) -> void:
	var campaign_loader := Loaders.Campaign_Loader.new()
	campaign_data = campaign_loader.load_campaign(campaign_name)

func goto_scene(scene : Resource) -> void:
	call_deferred("_deferred_goto_scene", scene)

func _deferred_goto_scene(scene : Resource) -> void:
	
	# We fade out to mask the transition
	resize_transition(true)

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

	resize_transition(false)

func resize_transition(to_max : bool) -> void:
	transition.margin_bottom = UI.margin_bottom if to_max else 0
	transition.margin_right = UI.margin_right if to_max else 0

func travel_to_map(map_name : String, access_point : int) -> void:
	campaign_data.cur_map = map_name
	goto_scene(MAP)

func on_window_resize() -> void:
	UI.margin_bottom = get_viewport().get_visible_rect().size.y
	UI.margin_right = get_viewport().get_visible_rect().size.x
