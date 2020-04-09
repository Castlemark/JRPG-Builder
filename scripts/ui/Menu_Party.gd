extends Tabs

class_name Menu_Party

var CHAR_PREV_SIZE_X := 444 * 0.8
var CHAR_PREV_SIZE_Y := 717 * 0.8

var character_res : Resource = preload("res://scenes/ui/party/Character_UI.tscn")
var character_ability_res : Resource = preload("res://scenes/ui/party/Character_Ability.tscn")

var character_button_group := ButtonGroup.new()
var ability_button_group := ButtonGroup.new()

onready var character_container : HBoxContainer = $Party/BG/Scroll/Char_Container as HBoxContainer
onready var character_ability_container : GridContainer = $Data/HBoxContainer/Abilities/Scroll/Container as GridContainer
onready var character_preview := $Character/Preview/Sprite as Sprite

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

func _ready():
	if Game_Manager.campaign_data == null:
		return
	var character_list := [Game_Manager.campaign_data.party.first_character, \
		Game_Manager.campaign_data.party.second_character, \
		Game_Manager.campaign_data.party.third_character]

	for character in character_list:
		var character_node : Character_UI = character_res.instance()
		character_container.add_child(character_node, true)
		character_node.initialize(character)
		character_node.connect("character_selected", self, "_on_player_select")
		character_node.group = character_button_group
	
	character_container.get_child(0).pressed = true

func _process(delta: float) -> void:
	if frames > 1:
		if elapsed_frame_time >= duration/frames:
			if character_preview.frame == (frames - 1):
				character_preview.frame = 0;
			else:
				character_preview.frame += 1;
			elapsed_frame_time = 0.0
		
		elapsed_frame_time += delta


func update() -> void:
	pass

func _on_ability_pressed(data : Model.Ability_Data, preview_icon : Texture) -> void:
	var stats : Model.Stats_Data = (character_button_group.get_pressed_button() as Character_UI).data.stats

	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Icon as TextureRect).texture = preview_icon
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Name as Label).text = String(data.name).replace("_", " ")
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Description as Label).text = data.description
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Level as Label).text = "Level: " + String(data.min_level)
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Cost as Label).text = "Costs " + String(data.cost) + " stamina points"

	var damage : String = "Effect: " + String(data.amount * stats.damage) + " " + data.type

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
	character_preview.texture = data.idle_texture
	character_preview.frame = 0
	elapsed_frame_time = 0.0
	if data.animation_data != null:
		self.frames = data.animation_data.total_frames
		character_preview.hframes = data.animation_data.hframes
		character_preview.vframes = data.animation_data.vframes
		self.duration = data.animation_data.duration
	_rescale_sprite()

	($Data/TopHBoxContainer/Stats/HBoxContainer/Hard/Critic as Label).text = "Critic: " + String(round(data.stats.critic * 100)) + "%"
	($Data/TopHBoxContainer/Stats/HBoxContainer/Hard/Speed as Label).text = "Speed: " + String(round(data.stats.speed))

	($Data/TopHBoxContainer/Stats/HBoxContainer/Soft/HP as Label). text = "HP: " + String(round(data.stats.health))
	($Data/TopHBoxContainer/Stats/HBoxContainer/Soft/Strain as Label).text = "Strain: " + String(round(data.stats.strain))
	($Data/TopHBoxContainer/Stats/HBoxContainer/Soft/Evasion as Label).text = "Evasion: " + String(round(data.stats.evasion * 100)) + "%"
	($Data/TopHBoxContainer/Stats/HBoxContainer/Soft/Damage as Label).text = "Base Damage: " + String(round(data.stats.damage))

	_update_character_equipment(data.equipment)
	_update_character_abilites_panel(data.abilities.values())
	_reset_ability_preview()

func _rescale_sprite() -> void:
	var width_scale : float = float(CHAR_PREV_SIZE_X)/float(float(character_preview.texture.get_size().x)/character_preview.hframes)
	var heigth_scale : float = float(CHAR_PREV_SIZE_Y)/float(float(character_preview.texture.get_size().y)/character_preview.vframes)
	
	var scale : float = min(width_scale, heigth_scale)
	character_preview.scale = Vector2(scale, scale)

func _update_character_equipment(equipment_data : Model.Character_Data.Equipment_Data):
	$Data/TopHBoxContainer/Equipment/Clothes/Torso/VBoxContainer/Name.text = equipment_data.torso.name
	$Data/TopHBoxContainer/Equipment/Clothes/Torso/TextureRect.texture = equipment_data.torso.icon_texture
	
	$Data/TopHBoxContainer/Equipment/Clothes/Legs/VBoxContainer/Name.text = equipment_data.legs.name
	$Data/TopHBoxContainer/Equipment/Clothes/Legs/TextureRect.texture = equipment_data.legs.icon_texture
	
	$Data/TopHBoxContainer/Equipment/Clothes/Weapon/VBoxContainer/Name.text = equipment_data.weapon.name
	$Data/TopHBoxContainer/Equipment/Clothes/Weapon/TextureRect.texture = equipment_data.weapon.icon_texture
	
	$Data/TopHBoxContainer/Equipment/Accessories/Accessory_1/VBoxContainer/Name.text = equipment_data.accessory_1.name
	$Data/TopHBoxContainer/Equipment/Accessories/Accessory_1/TextureRect.texture = equipment_data.accessory_1.icon_texture
	
	$Data/TopHBoxContainer/Equipment/Accessories/Accessory_2/VBoxContainer/Name.text = equipment_data.accessory_2.name
	$Data/TopHBoxContainer/Equipment/Accessories/Accessory_2/TextureRect.texture = equipment_data.accessory_2.icon_texture
	
	$Data/TopHBoxContainer/Equipment/Accessories/Accessory_3/VBoxContainer/Name.text = equipment_data.accessory_3.name
	$Data/TopHBoxContainer/Equipment/Accessories/Accessory_3/TextureRect.texture = equipment_data.accessory_3.icon_texture

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
