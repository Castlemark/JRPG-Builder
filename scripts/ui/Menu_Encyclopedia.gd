extends Tabs

class_name Menu_Encyclopedia

var enemy_encyclopedia : Resource = preload("res://scenes/ui/encyclopedia/Encyclopedia_Enemy.tscn")

onready var GM := $"/root/Game_Manager"
onready var encyclopedia_container : GridContainer = $HBoxContainer/Content/BG/Scroll/Grid
onready var enemy_preview : Enemy_preview = $HBoxContainer/Enemy_Preview

var enemy_button_group := ButtonGroup.new()

func initialize_encyclopedia(journal : Array, statistics : Array) -> void:
	# We don't pass enemy and abilities as parameters because we scan the 
	# whole enemy and ability directories to know wich ones exist.
	
	_initialize_journal(journal)
	_initialize_stats(statistics)
	_scan_enemies()
	_scan_abilities()

func _initialize_journal(journal : Array) -> void:
	# TODO
	pass

func _initialize_stats(statistics : Array) -> void:
	# TODO
	pass

func _scan_enemies() -> void:
	var enemies_names : Array = Utils.scan_directories_in_directory("res://campaigns/" + GM.campaign.name + "/characters/enemies")
	
	for enemy_name in enemies_names:
		var enemy_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/characters/enemies/" + enemy_name + "/enemy.json")
		if not Validator.enemy_is_valid(enemy_data, enemy_name):
			continue
		
		var abilities_data := []
		var abilities_valid := true
		for ability in enemy_data.abilities:
			var ability_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/abilities/" + ability + "/ability.json")
			if ability_data != null:
				ability_data["name"] = ability
				abilities_data.append(ability_data)
			
			if abilities_valid:
				abilities_valid = Validator.ability_is_valid(ability_data, ability)
		
		if not abilities_valid:
			print(enemy_name + " character is valid, but at least one of its abilities is invalid or may not exist, please check the messages above to see what abilities")
			continue
		
		enemy_data["name"] = enemy_name
		
		var enemy_node : Encyclopedia_Enemy = enemy_encyclopedia.instance()
		encyclopedia_container.add_child(enemy_node, true)
		encyclopedia_container.move_child(enemy_node, 0)
		enemy_node.initialize(enemy_data, abilities_data)
		enemy_node.connect("enemy_ui_pressed", enemy_preview, "set_data")
		enemy_node.group = enemy_button_group

func _scan_abilities() -> void:
	# TODO
	pass