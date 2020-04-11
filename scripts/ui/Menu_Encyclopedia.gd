extends Tabs

class_name Menu_Encyclopedia

var enemy_encyclopedia : Resource = preload("res://scenes/ui/encyclopedia/Encyclopedia_Enemy.tscn")

onready var GM := $"/root/Game_Manager"
onready var encyclopedia_container : GridContainer = $HBoxContainer/Content/BG/Scroll/Grid
onready var enemy_preview : Enemy_preview = $HBoxContainer/Enemy_Preview

var enemy_button_group := ButtonGroup.new()

func update() -> void:
	_scan_enemies()
	_scan_abilities()


func _scan_enemies() -> void:
	if GM.campaign_data == null: 
		return
	for enemy_data in GM.campaign_data.enemies.values():
		
		var enemy_node : Encyclopedia_Enemy = enemy_encyclopedia.instance()
		encyclopedia_container.add_child(enemy_node, true)
		encyclopedia_container.move_child(enemy_node, 0)
		enemy_node.initialize(enemy_data)
		enemy_node.connect("enemy_ui_pressed", enemy_preview, "set_data")
		enemy_node.group = enemy_button_group
	encyclopedia_container.get_child(0).pressed = true

func _scan_abilities() -> void:
	# TODO
	pass
