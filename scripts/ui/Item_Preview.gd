extends Panel

class_name Item_Preview

signal equip_cur_item_request()
signal consume_cur_item_request()

onready var item_icon := $Icon as TextureRect
onready var item_name := $Basic_Info/Name as Label
onready var item_description := $Basic_Info/Description as RichTextLabel

onready var equipment_info := $Equipment_Info as Control

onready var evasion_amount := $Equipment_Info/Stat_Info/Evasion/Amount as Label
onready var health_amount := $Equipment_Info/Stat_Info/Health/Amount as Label
onready var damage_amount := $Equipment_Info/Stat_Info/Damage/Amount as Label
onready var strain_amount := $Equipment_Info/Stat_Info/Strain/Amount as Label
onready var critic_amount := $Equipment_Info/Stat_Info/Critic/Amount as Label
onready var speed_amount := $Equipment_Info/Stat_Info/Speed/Amount as Label

onready var equipment_min_level := $Equipment_Info/Extra_Info/Min_Level/Amount as Label
onready var equipment_rarity := $Equipment_Info/Extra_Info/Rarity/Amount as Label
onready var equipment_type := $Equipment_Info/Extra_Info/Type/Amount as Label

onready var button_equip := $Equipment_Info/Equip_Button as Button

onready var consumable_info := $Consumable_Info as Control

onready var consumable_type := $Consumable_Info/Extra_Info/Type/Amount as Label
onready var consumable_amount := $Consumable_Info/Extra_Info/Amount/Amount as Label

func preview(item_data):
	item_icon.texture = item_data.icon_texture
	item_name.text = item_data.name
	item_description.bbcode_text = item_data.description
	
	if item_data is Model.Item_Data.Equipment_Item_Data:
		consumable_info.visible = false
		
		var stats := item_data.stats as Model.Stats_Data
		evasion_amount.text = String(stats.evasion)
		health_amount.text = String(stats.health)
		damage_amount.text = String(stats.damage)
		strain_amount.text = String(stats.strain)
		critic_amount.text = String(stats.critic)
		speed_amount.text = String(stats.speed)
		
		equipment_min_level.text = String(item_data.min_level)
		equipment_rarity.text = String(item_data.rarity)
		equipment_type.text = item_data.type
		
		equipment_info.visible = true
	else:
		equipment_info.visible = false
		
		consumable_type.text = item_data.effect.type
		consumable_amount.text = String(item_data.effect.value)
		
		consumable_info.visible = true


func _on_Consume_Button_pressed() -> void:
	emit_signal("consume_cur_item_request")


func _on_Equip_Button_pressed() -> void:
	emit_signal("equip_cur_item_request")
