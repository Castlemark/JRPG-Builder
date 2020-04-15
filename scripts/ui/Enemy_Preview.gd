extends VBoxContainer

class_name Enemy_preview

var character_ability_res : Resource = preload("res://scenes/ui/party/Character_Ability.tscn")

onready var sprite : Sprite = $BG/VBoxContainer/Color_BG/Sprite as Sprite
onready var enemy_name : Label = $BG/VBoxContainer/Name as Label
onready var character_ability_container : HBoxContainer = $Abilities2/Scroll/Container as HBoxContainer

var ability_button_group := ButtonGroup.new()

var sprites : Array = []
var cur_sprite: int

var data := Model.Enemy_Data.new()

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

var size : int = 380

func _ready() -> void:
	self.sprites = [sprite.texture, sprite.texture, sprite.texture, sprite.texture]

func set_data(enemy_data : Model.Enemy_Data, abilities_data : Dictionary, is_animated : bool, sprites : Array) -> void:
	data = enemy_data
	enemy_name.text = data.name
	
	_set_stats(data.stats, abilities_data.values())
	
	elapsed_frame_time = 0.0
	sprite.frame = 0
	if is_animated:
		_set_up_animation(data.animation_data)
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

func _set_up_animation(animation_info) -> void:
	sprite.vframes = animation_info.vframes
	sprite.hframes = animation_info.hframes
	frames = animation_info.total_frames
	duration = animation_info.duration

func _set_stats(stats : Model.Stats_Data, abilities : Array) -> void:
	
	($Abilities/Stats/Container/Soft/Critic/Amount as Label).text = String(round(stats.critic * 100)) + "%"
	($Abilities/Stats/Container/Soft/Speed/Amount as Label).text = String(round(stats.speed))
	
	($Abilities/Stats/Container/Soft/HP/Amount as Label).text = String(round(stats.health))
	($Abilities/Stats/Container/Soft/Strain/Amount as Label).text = String(round(stats.strain))
	($Abilities/Stats/Container/Soft/Evasion/Amount as Label).text = String(round(stats.evasion * 100)) + "%"
	($Abilities/Stats/Container/Soft/Damage/Amount as Label).text = String(round(stats.damage))
	
	_update_character_abilites_panel(abilities)
	

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
