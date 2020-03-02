extends VBoxContainer

class_name Menu_Manager

signal on_menus_toggle(is_hidden)

const SCREEN_NONE := "None"
const MIN_SIZE := 74
const MAX_SIZE := -1072

onready var GM := $"/root/Game_Manager"

onready var inventory_menu : Menu_Inventory = $Content/Inventory as Menu_Inventory
onready var party_menu : Menu_Party = $Content/Party as Menu_Party
onready var encyclopedia_menu : Menu_Encyclopedia = $Content/Encyclopedia as Menu_Encyclopedia

onready var inventory_button : Button = $Sections/Tabs/Inventory as Button
onready var party_button : Button = $Sections/Tabs/Party as Button
onready var encyclopedia_button : Button = $Sections/Tabs/Encyclopedia as Button
onready var settings_button : Button = $Sections/Controls/Settings as Button
onready var sections_group : ButtonGroup = ($Sections/Tabs/Inventory as Button).group

onready var tween : Tween = $Tween as Tween
onready var content_panel : Panel = $Content as Panel

var menu_up : bool
var animation_in_progress : bool
var current_screen : String

func initialize() -> void:
	inventory_menu.initialize_inventory()
	party_menu.initialize_party()
	encyclopedia_menu.initialize_encyclopedia([], [])

func _ready() -> void:
	initialize()
	_wipe_all_menus()
	self.margin_top = MIN_SIZE
	
	menu_up = false
	animation_in_progress = false
	current_screen = SCREEN_NONE
	
	GM.menus = self

func _input(event : InputEvent) -> void:
	if not animation_in_progress:
		if event.is_action_pressed("ui_inventory"):
			_update_current_screen(inventory_button)
		if event.is_action_pressed("ui_party"):
			_update_current_screen(party_button)
		if event.is_action_pressed("ui_encyclopedia"):
			_update_current_screen(encyclopedia_button)
		if event.is_action_pressed("ui_pause"):
			_update_current_screen(settings_button)

func _on_section_toggled(button_pressed: bool) -> void:
	if button_pressed and not animation_in_progress:
		_update_current_screen(sections_group.get_pressed_button())
		

func _update_current_screen(section : Button) -> void:
	section.grab_focus()
	
	if section.name == current_screen:
		section.pressed = false
		current_screen = SCREEN_NONE
		
		animation_in_progress = true
		tween.interpolate_property(self, "margin_top", null, MIN_SIZE, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
		animation_in_progress = false
		menu_up = false
		
		(get_node("Content/" + section.name) as Control).visible = false
		
		emit_signal("on_menus_toggle", not menu_up)
	
	elif not menu_up:
		section.pressed = true
		_wipe_all_menus()
		(get_node("Content/" + section.name) as Control).visible = true
		current_screen = section.name
		
		animation_in_progress = true
		tween.interpolate_property(self, "margin_top", null, MAX_SIZE, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
		animation_in_progress = false
		menu_up = true
		
		emit_signal("on_menus_toggle", not menu_up)
	else:
		section.pressed = true
		_wipe_all_menus()
		(get_node("Content/" + section.name) as Control).visible = true
		current_screen = section.name

func _wipe_all_menus() -> void:
	for screen in content_panel.get_children():
			(screen as Control).visible = false
