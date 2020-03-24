extends Control

class_name Menu_Dialogue

signal on_dialogue_toggle(is_active)
signal on_dialogue_finished()

onready var dialogue_box := $Dialogue_Box as Panel
onready var text := $Dialogue_Box/RichTextLabel as RichTextLabel

onready var character_1 := $Character_1 as Control
onready var char_1_portrait := $Character_1/Portrait as TextureRect
onready var char_1_name := $Character_1/Panel/Name as Label

onready var character_2 := $Character_2 as Control
onready var char_2_portrait := $Character_2/Portrait as TextureRect
onready var char_2_name := $Character_2/Panel/Name as Label

func _ready():
	dialogue_box.set_position(Vector2(672, 702))
	character_1.set_position(Vector2(96, 702))
	character_2.set_position(Vector2(1344, 702))
	
	self.visible = false

func start_dialogue(dialogue_data : Dictionary) -> void:
	emit_signal("on_dialogue_toggle", true)
	
	dialogue_box.set_position(Vector2(672, 702))
	character_1.set_position(Vector2(96, 702))
	character_2.set_position(Vector2(1344, 702))
	
	self.visible = true
	
	# Logic stuff
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	print("executing dialogue")
	
	emit_signal("on_dialogue_finished")
	emit_signal("on_dialogue_toggle", false)
