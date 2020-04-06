extends Control

class_name Main_Menu

var campaign_button_res = preload("res://scenes/ui/title_screen/Campaign_Button.tscn")

const menu_pos := Vector2(-1920, 0)

onready var menu_container := $MenuContainer as Control
onready var tween := $Tween as Tween

onready var campaign_button_container := $MenuContainer/Campaigns_Menu/CampaignScroll/VBoxContainer as VBoxContainer
onready var campaign_description := $MenuContainer/Campaigns_Menu/DescriptionScroll/RichTextLabel as RichTextLabel

onready var is_moving := false
onready var campaigns := {}
onready var cur_campaign_index := -1

func _ready() -> void:
	campaigns = Loaders.load_all_campaigns_basic_info()
	for i in range(campaigns.size()):
		var campaign_button_node := campaign_button_res.instance() as Button
		campaign_button_node.text = campaigns.keys()[i]
		campaign_button_container.add_child(campaign_button_node)
		campaign_button_node.connect("pressed", self, "_on_campaign_button_pressed", [i])

func move_to_menu(index : int) -> void:
	if not is_moving:
		tween.interpolate_property(menu_container, "rect_position", null, menu_pos * index, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		
		is_moving = true
		tween.start()
		yield(tween, "tween_all_completed")
		is_moving = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and menu_container.rect_position != menu_pos:
		move_to_menu(1)

func _on_campaign_button_pressed(index : int):
	cur_campaign_index = index
	campaign_description.bbcode_text = campaigns.values()[index].description

func _on_campaign_chooser_button_pressed():
	if cur_campaign_index != -1:
		campaign_button_container.get_child(cur_campaign_index).grab_focus()
		_on_campaign_button_pressed(cur_campaign_index)

func _on_start_campaign_pressed():
	# TODO load save file
	Game_Manager.load_campaign(campaigns.keys()[cur_campaign_index])
	Game_Manager.goto_scene(Game_Manager.MAP)
	pass
