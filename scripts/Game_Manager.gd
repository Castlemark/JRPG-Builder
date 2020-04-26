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

func apply_save(save_game : Save_Game) -> void:
	campaign_data.cur_map = save_game.cur_map
	(campaign_data.maps[campaign_data.cur_map] as Model.Map_Data).access_point = save_game.cur_access_point
	campaign_data.completed_action_nodes = save_game.completed_actions_nodes
	
	campaign_data.party.inventory = []
	for item_name in save_game.party.inventory:
		campaign_data.party.inventory.append(campaign_data.items[item_name])
	
	campaign_data.party.first_character = campaign_data.characters[save_game.party.first_character.name]
	campaign_data.party.first_character.equipment.legs = campaign_data.items[save_game.party.first_character.equipment.legs]
	campaign_data.party.first_character.equipment.torso = campaign_data.items[save_game.party.first_character.equipment.torso]
	campaign_data.party.first_character.equipment.weapon = campaign_data.items[save_game.party.first_character.equipment.weapon]
	campaign_data.party.first_character.equipment.accessory_1 = campaign_data.items[save_game.party.first_character.equipment.accessory_1]
	campaign_data.party.first_character.equipment.accessory_2 = campaign_data.items[save_game.party.first_character.equipment.accessory_2]
	campaign_data.party.first_character.equipment.accessory_3 = campaign_data.items[save_game.party.first_character.equipment.accessory_3]
	
	campaign_data.party.first_character.stats_with_equipment = campaign_data.party.first_character.stats_with_eq(campaign_data.party.first_character.equipment, true)
	
	campaign_data.party.first_character.stats_with_equipment.health = save_game.party.first_character.cur_health
	campaign_data.party.first_character.cur_xp = save_game.party.first_character.cur_xp
	
	campaign_data.party.second_character = campaign_data.characters[save_game.party.second_character.name]
	campaign_data.party.second_character.equipment.legs = campaign_data.items[save_game.party.second_character.equipment.legs]
	campaign_data.party.second_character.equipment.torso = campaign_data.items[save_game.party.second_character.equipment.torso]
	campaign_data.party.second_character.equipment.weapon = campaign_data.items[save_game.party.second_character.equipment.weapon]
	campaign_data.party.second_character.equipment.accessory_1 = campaign_data.items[save_game.party.second_character.equipment.accessory_1]
	campaign_data.party.second_character.equipment.accessory_2 = campaign_data.items[save_game.party.second_character.equipment.accessory_2]
	campaign_data.party.second_character.equipment.accessory_3 = campaign_data.items[save_game.party.second_character.equipment.accessory_3]
	
	campaign_data.party.second_character.stats_with_equipment = campaign_data.party.second_character.stats_with_eq(campaign_data.party.second_character.equipment, true)
	
	campaign_data.party.second_character.stats_with_equipment.health = save_game.party.second_character.cur_health
	campaign_data.party.second_character.cur_xp = save_game.party.second_character.cur_xp
	
	campaign_data.party.third_character = campaign_data.characters[save_game.party.third_character.name]
	campaign_data.party.third_character.equipment.legs = campaign_data.items[save_game.party.third_character.equipment.legs]
	campaign_data.party.third_character.equipment.torso = campaign_data.items[save_game.party.third_character.equipment.torso]
	campaign_data.party.third_character.equipment.weapon = campaign_data.items[save_game.party.third_character.equipment.weapon]
	campaign_data.party.third_character.equipment.accessory_1 = campaign_data.items[save_game.party.third_character.equipment.accessory_1]
	campaign_data.party.third_character.equipment.accessory_2 = campaign_data.items[save_game.party.third_character.equipment.accessory_2]
	campaign_data.party.third_character.equipment.accessory_3 = campaign_data.items[save_game.party.third_character.equipment.accessory_3]
	
	campaign_data.party.third_character.stats_with_equipment = campaign_data.party.third_character.stats_with_eq(campaign_data.party.third_character.equipment, true)
	
	campaign_data.party.third_character.stats_with_equipment.health = save_game.party.third_character.cur_health
	campaign_data.party.third_character.cur_xp = save_game.party.third_character.cur_xp

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
