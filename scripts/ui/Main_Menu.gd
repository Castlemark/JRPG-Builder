extends Control

class_name Main_Menu

var campaign_button_res = preload("res://scenes/ui/title_screen/Campaign_Button.tscn")

const menu_pos := Vector2(-1920, 0)

onready var menu_container := $MenuContainer as Control
onready var tween := $Tween as Tween

onready var campaign_button_container := $MenuContainer/Campaigns_Menu/CampaignScroll/VBoxContainer as VBoxContainer
onready var campaign_description := $MenuContainer/Campaigns_Menu/Descritption as RichTextLabel
onready var start_campaign_button := $MenuContainer/Campaigns_Menu/Start_Campaign_Button as Button

onready var settings_menu := $MenuContainer/Settings_Menu as Control
onready var title_screen := $MenuContainer/Options_Menu as Control
onready var campaigns_menu := $MenuContainer/Campaigns_Menu as Control

onready var settings_back_button := $MenuContainer/Settings_Menu/BackButton as Button
onready var campaigns_back_button := $MenuContainer/Campaigns_Menu/BackButton as Button
onready var choose_campaign_button := $MenuContainer/Options_Menu/Choose_Campaign_Button as Button

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
		
		if index == 0:
			settings_back_button.grab_focus()
			settings_menu.visible = true
		elif index == 1:
			choose_campaign_button.grab_focus()
			title_screen.visible = true
		elif index == 2:
			campaigns_back_button.grab_focus()
			campaigns_menu.visible = true
		
		tween.start()
		yield(tween, "tween_all_completed")
		
		if index == 0:
			title_screen.visible = false
			campaigns_menu.visible = false
		elif index == 1:
			settings_menu.visible = false
			campaigns_menu.visible = false
		elif index == 2:
			title_screen.visible = false
			settings_menu.visible = false
		
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
	start_campaign_button.disabled = true
	Game_Manager.load_campaign(campaigns.keys()[cur_campaign_index])
	Game_Manager.goto_scene(Game_Manager.MAP)


func _on_Credit_Label_meta_clicked(meta) -> void:
	OS.shell_open(meta)
