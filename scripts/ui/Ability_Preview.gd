extends VBoxContainer

class_name Ability_Preview

onready var sprite := $BG/VBoxContainer/Color_BG/Sprite as Sprite
onready var ability_name := $BG/VBoxContainer/Name as Label

onready var ability_description := $Info/ScrollContainer/Stats/Description as Label
onready var ability_level := $Info/ScrollContainer/Stats/Level as Label
onready var ability_damage := $Info/ScrollContainer/Stats/Damage as Label
onready var ability_cost := $Info/ScrollContainer/Stats/Cost as Label

var data := Model.Ability_Data.new()

const size : int = 380

func set_data(ability_data : Model.Ability_Data, ability_texture = null) -> void:
	data = ability_data
	
	ability_name.text = data.name
	sprite.texture = data.icon_texture
	_rescale_sprite()
	
	ability_description.text = data.description
	ability_level.text = "Level: " + String(data.min_level)
	ability_cost.text = "Costs " + String(data.cost) + " stamina points"
	
	var damage := "Effect: " + String(data.amount) + " * character damage " + data.type
	if data.amount == 0:
		damage = " Effect: none"
	ability_damage.text = damage

func _rescale_sprite() -> void:
	var width_scale : float = float(size)/float(float(sprite.texture.get_size().x)/sprite.hframes)
	var heigth_scale : float = float(size)/float(float(sprite.texture.get_size().y)/sprite.vframes)
	
	var scale : float = min(width_scale, heigth_scale)
	sprite.scale = Vector2(scale, scale)

