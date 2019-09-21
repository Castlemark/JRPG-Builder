extends Control

class_name Menu_Manager

onready var inventory_menu : Menu_Inventory = $Game_Menu/Inventory as Menu_Inventory
onready var party_menu : Menu_Party = $Game_Menu/Party as Menu_Party

func _ready():
	self.visible = false

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_inventory"):
		self.visible = not self.visible