extends Tabs

class_name Menu_Encyclopedia

var enemy_encyclopedia : Resource = preload("res://scenes/ui/encyclopedia/Encyclopedia_Enemy.tscn")
var ability_encyclopedia_res : Resource = preload("res://scenes/ui/encyclopedia/Encyclopedia_Ability.tscn")

onready var bestiary_button := $HBoxContainer/Selector/BG/Container/Bestiary as Button
onready var abilities_button := $HBoxContainer/Selector/BG/Container/Abilities as Button

onready var encyclopedia_enemies := $HBoxContainer/Content/BG/EnemiesScroll as ScrollContainer
onready var encyclopedia_enemy_container := $HBoxContainer/Content/BG/EnemiesScroll/Grid as GridContainer
onready var enemy_preview := $HBoxContainer/Enemy_Preview as Enemy_preview

onready var encyclopedia_abilities := $HBoxContainer/Content/BG/AbilitiesScroll as ScrollContainer
onready var encyclopedia_ability_container := $HBoxContainer/Content/BG/AbilitiesScroll/Grid as GridContainer
onready var ability_preview := $HBoxContainer/Ability_Preview as Ability_Preview

var enemy_button_group := ButtonGroup.new()
var ability_button_group := ButtonGroup.new()

func _ready() -> void:
	_scan_enemies()
	_scan_abilities()
	
	enemy_preview.connect("redirect_to_ability", self, "_on_redirect_to_ability")
	
	bestiary_button.pressed = true
	_on_Bestiary_pressed()

func update() -> void:
	pass


func _scan_enemies() -> void:
	if Game_Manager.campaign_data == null: 
		return
	for enemy_data in Game_Manager.campaign_data.enemies.values():
		var enemy_node : Encyclopedia_Enemy = enemy_encyclopedia.instance()
		encyclopedia_enemy_container.add_child(enemy_node, true)
		enemy_node.initialize(enemy_data)
		enemy_node.connect("enemy_ui_pressed", enemy_preview, "set_data")
		enemy_node.group = enemy_button_group
	encyclopedia_enemy_container.get_child(0).pressed = true

func _scan_abilities() -> void:
	if Game_Manager.campaign_data == null: 
		return
	for ability_data in Game_Manager.campaign_data.abilities.values():
		var ability_node : Character_Ability = ability_encyclopedia_res.instance()
		encyclopedia_ability_container.add_child(ability_node, true)
		ability_node.initialize(ability_data)
		ability_node.connect("ability_pressed", ability_preview, "set_data")
		ability_node.group = ability_button_group
	encyclopedia_ability_container.get_child(0).pressed = true
	ability_preview.set_data(encyclopedia_ability_container.get_child(0).data)


func _on_Bestiary_pressed() -> void:
	encyclopedia_enemies.visible = true
	enemy_preview.visible = true
	encyclopedia_abilities.visible = false
	ability_preview.visible = false

func _on_Abilities_pressed() -> void:
	encyclopedia_enemies.visible = false
	enemy_preview.visible = false
	encyclopedia_abilities.visible = true
	ability_preview.visible = true

func _on_redirect_to_ability(ability_name : String) -> void:
	for ability_node in encyclopedia_ability_container.get_children():
		if ability_node.data.name == ability_name:
			ability_node.pressed = true
			ability_preview.set_data(ability_node.data)
			
			_on_Abilities_pressed()
			abilities_button.pressed = true
			return
