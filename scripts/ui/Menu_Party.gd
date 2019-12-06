extends Tabs

class_name Menu_Party

var character_res : Resource = preload("res://scenes/ui/party/Character_UI.tscn")
var character_ability_res : Resource = preload("res://scenes/ui/party/Character_Ability.tscn")

var character_button_group := ButtonGroup.new()
var ability_button_group := ButtonGroup.new()

onready var GM := $"/root/Game_Manager"
onready var character_container : HBoxContainer = $Party/BG/Scroll/Char_Container as HBoxContainer
onready var character_ability_container : GridContainer = $Data/HBoxContainer/Abilities/Scroll/Container as GridContainer

func _ready():
	pass

func initialize_party() -> void:
	if GM.campaign_data == null:
		return
	# TODO check for duplicates (characters)
	var character_list := [GM.campaign_data.party.first_character, \
		GM.campaign_data.party.second_character, \
		GM.campaign_data.party.third_character]

	for character in character_list:
		var character_node : Character_UI = character_res.instance()
		character_container.add_child(character_node, true)
		character_node.initialize(character)
		character_node.connect("character_selected", self, "_on_player_select")
		character_node.group = character_button_group
	pass

func _on_ability_pressed(data : Model.Ability_Data, preview_icon : Texture) -> void:
	var calc_stats : Model.Calc_Stats_Data = (character_button_group.get_pressed_button() as Character_UI).data.calc_stats

	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Icon as TextureRect).texture = preview_icon
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Name as Label).text = String(data.name).replace("_", " ")
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Description as Label).text = data.description
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Level as Label).text = "Level: " + String(data.min_level)
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Cost as Label).text = "Costs " + String(data.cost) + " stamina points"

	var damage : String = "Effect: " + String(data.amount * calc_stats.damage) + " " + data.type

	if data.amount == 0:
		damage = " Effect: none"
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Damage as Label).text = damage

func _reset_ability_preview():
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Icon as TextureRect).texture = null
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Name as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Description as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Level as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Damage as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Cost as Label).text = ""

func _on_player_select(data : Model.Character_Data) -> void:

	($Data/Stats/HBoxContainer/Hard/Strength as Label).text = "Strength: " + String(round(data.stats.strength))
	($Data/Stats/HBoxContainer/Hard/Dexterity as Label).text = "Dexterity: " + String(round(data.stats.dexterity))
	($Data/Stats/HBoxContainer/Hard/Constitution as Label).text = "Constitution: " + String(round(data.stats.constitution))
	($Data/Stats/HBoxContainer/Hard/Critic as Label).text = "Critic: " + String(round(data.stats.critic * 100)) + "%"
	($Data/Stats/HBoxContainer/Hard/Defence as Label).text = "Defence: " + String(round(data.stats.defence))
	($"Data/Stats/HBoxContainer/Hard/Alt Defence" as Label).text = "Alt. Defence: " + String(round(data.stats.alt_defence))
	($Data/Stats/HBoxContainer/Hard/Speed as Label).text = "Speed: " + String(round(data.stats.speed))

	($Data/Stats/HBoxContainer/Soft/HP as Label). text = "HP: " + String(round(data.calc_stats.hp))
	($Data/Stats/HBoxContainer/Soft/Shield as Label).text = "Shield: " + String(round(data.calc_stats.shield))
	($Data/Stats/HBoxContainer/Soft/Strain as Label).text = "Strain: " + String(round(data.calc_stats.strain))
	($Data/Stats/HBoxContainer/Soft/Evasion as Label).text = "Evasion: " + String(round(data.calc_stats.evasion)) + "%"
	($Data/Stats/HBoxContainer/Soft/Damage as Label).text = "Base Damage: " + String(round(data.calc_stats.damage))

	_update_character_abilites_panel(data.abilities.values())
	_reset_ability_preview()

func _update_character_abilites_panel(abilities_data : Array) -> void:
	var difference : int =  abilities_data.size() - (character_ability_container.get_child_count() - 2)

	if difference > 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var character_ability_node : Button = character_ability_res.instance()
			character_ability_container.add_child(character_ability_node, true)
			character_ability_container.move_child(character_ability_node, 0)
			character_ability_node.connect("ability_pressed", self, "_on_ability_pressed")
			character_ability_node.group = ability_button_group
	elif difference < 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var node_to_delete = character_ability_container.get_child(0)
			character_ability_container.remove_child(node_to_delete)
			node_to_delete.queue_free()

	for i in range(abilities_data.size()):
		var ability_node : Character_Ability = character_ability_container.get_child(i) as Character_Ability
		ability_node.initialize(abilities_data[i])
		ability_node.pressed = false