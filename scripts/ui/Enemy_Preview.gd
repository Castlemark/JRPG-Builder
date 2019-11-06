extends VBoxContainer

class_name Enemy_preview

var character_ability_res : Resource = preload("res://scenes/ui/party/Character_Ability.tscn")

onready var sprite : Sprite = $BG/VBoxContainer/Color_BG/Sprite as Sprite
onready var enemy_name : Label = $BG/VBoxContainer/Name as Label
onready var character_ability_container : HBoxContainer = $Abilities2/Scroll/Container as HBoxContainer

var ability_button_group := ButtonGroup.new()

var sprites : Array = []
var cur_sprite: int

var data : Dictionary = {}

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

var size : int = 380

func _ready() -> void:
	self.sprites = [sprite.texture, sprite.texture, sprite.texture, sprite.texture]

func set_data(enemy_data : Dictionary, abilities_data : Array, is_animated : bool, sprites : Array) -> void:
	data = enemy_data
	enemy_name.text = data.name
	
	_calculate_stats(data.stats)
	_set_stats(data.stats, abilities_data)
	
	elapsed_frame_time = 0.0
	sprite.frame = 0
	if is_animated:
		_set_up_animation(enemy_data.animation_data)
	else:
		_set_up_animation({"vframes" : 1, "hframes": 1, "total_frames": 0, "duration": 0})
	
	self.sprites = sprites
	if self.sprites[0] != null:
		sprite.texture = self.sprites[0]
		cur_sprite = 0
		_rescale_sprite()

func _process(delta: float) -> void:
	if frames > 1:
		if elapsed_frame_time >= duration/frames:
			if sprite.frame == (frames - 1):
				sprite.frame = 0;
				_change_sprite_to_next()
			else:
				sprite.frame += 1;
			elapsed_frame_time = 0.0
		
		elapsed_frame_time += delta
	else:
		if elapsed_frame_time >= 3.0:
			_change_sprite_to_next()
			elapsed_frame_time = 0.0
		
		elapsed_frame_time += delta

func _calculate_stats(stats : Dictionary) -> void:
	stats["hp"] = (stats.constitution + 1/4.0 * float(stats.strength) + 1/3.0 * stats.defence) * 4
	stats["shield"] = (1/4.0 * stats.constitution + float(stats.alt_defence) + 1/3.0 * stats.defence) * 4
	stats["strain"] = (1/2.0 * stats.speed + float(stats.strength) + 1/3.0 * stats.alt_defence) * 4
	stats["evasion"] = (float(stats.speed) + 1/2.0 * stats.critic * 100 + 1/4.0 * stats.defence) * 0.4
	stats["damage"] = (1/4.0 * stats.strength + 1/4.0 * stats.dexterity + 1/8.0 * stats.speed) * 4

func _set_up_animation(animation_info : Dictionary) -> void:
	sprite.vframes = animation_info.vframes
	sprite.hframes = animation_info.hframes
	frames = animation_info.total_frames
	duration = animation_info.duration

func _set_stats(stats : Dictionary, abilities : Array) -> void:
	
	($Abilities/Stats/Container/Hard/Strength as Label).text = "Strength: " +  String(round(stats.strength))
	($Abilities/Stats/Container/Hard/Dexterity as Label).text = "Dexterity: " +  String(round(stats.dexterity))
	($Abilities/Stats/Container/Hard/Constitution as Label).text = "Constitution: " +  String(round(stats.constitution))
	($Abilities/Stats/Container/Hard/Critic as Label).text = "Critic: " +  String(round(stats.critic * 100)) + "%"
	($Abilities/Stats/Container/Hard/Defence as Label).text = "Defence: " +  String(round(stats.defence))
	($Abilities/Stats/Container/Hard/Alt_Defence as Label).text = "Alt Defence: " +  String(round(stats.alt_defence))
	($Abilities/Stats/Container/Hard/Speed as Label).text = "Speed: " +  String(round(stats.speed))
	
	($Abilities/Stats/Container/Soft/HP as Label).text = "HP: " + String(round(stats.hp))
	($Abilities/Stats/Container/Soft/Shield as Label).text = "Shield: " + String(round(stats.shield))
	($Abilities/Stats/Container/Soft/Strain as Label).text = "Strain: " + String(round(stats.strain))
	($Abilities/Stats/Container/Soft/Evasion as Label).text = "Evasion: " + String(round(stats.evasion)) + "%"
	($Abilities/Stats/Container/Soft/Damage as Label).text = "Base Damage: " + String(round(stats.damage))
	
	_update_character_abilites_panel(abilities)
	

func _set_abilites(abilities : Array) -> void:
	pass

func _change_sprite_to_next() -> void:
	var found_next := false
	while not found_next:
		cur_sprite += 1
		if cur_sprite > 3:
			cur_sprite = 0
		
		if sprites[cur_sprite] != null:
			sprite.texture = sprites[cur_sprite]
			_rescale_sprite()
			found_next = true

func _rescale_sprite() -> void:
	var width_scale : float = float(size)/float(float(sprite.texture.get_size().x)/sprite.hframes)
	var heigth_scale : float = float(size)/float(float(sprite.texture.get_size().y)/sprite.vframes)
	
	var scale : float = min(width_scale, heigth_scale)
	sprite.scale = Vector2(scale, scale)

func _update_character_abilites_panel(abilities_data : Array) -> void:
	var difference : int =  abilities_data.size() - character_ability_container.get_child_count()
	
	
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