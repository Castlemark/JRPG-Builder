extends Control

class_name Menu_Dialogue

const MAX_CHAR_HEIGHT_POS := -76
const MIN_HEIGHT_POS := 702

const MAX_DIALOGUE_HEIGHT_POS := 204.8
const DIALOGUE_LEFT_POS := Vector2(0.05, 0.65)
const DIALOGUE_RIGHT_POS := Vector2(0.35, 0.95)

const CHARS_PER_SECONDS : float = 35.0

signal on_dialogue_toggle(is_active)
signal on_dialogue_finished()
signal on_dialogue_next()

onready var ui_tween := $Tween as Tween
onready var dialogue_tween := $Dialogue_Box/RichTextLabel/Tween as Tween

onready var dialogue_box := $Dialogue_Box as Panel
onready var text_label := $Dialogue_Box/RichTextLabel as RichTextLabel

onready var character_1 := $Character_1 as Control
onready var character_2 := $Character_2 as Control

func _ready():
	dialogue_box.set_position(Vector2(672, 702))
	character_1.set_position(Vector2(96, 702))
	character_2.set_position(Vector2(1344, 702))
	
	self.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		
		if dialogue_tween.is_active():
			dialogue_tween.stop_all()
			text_label.percent_visible = 1.0
			dialogue_tween.emit_signal("tween_all_completed")
		else:
			emit_signal("on_dialogue_next")

func start_dialogue(dialogue_id : String) -> void:
	emit_signal("on_dialogue_toggle", true)
	
	var dialogue_data := Game_Manager.campaign_data.dialogues[dialogue_id] as Model.Dialogue_Data
	
	dialogue_box.set_position(Vector2(672, 702))
	character_1.set_position(Vector2(96, 702))
	character_2.set_position(Vector2(1344, 702))
	
	self.visible = true
	
	dialogue_box.anchor_left = DIALOGUE_RIGHT_POS.x if dialogue_data.nodes[0].side == "l" else DIALOGUE_LEFT_POS.x
	dialogue_box.anchor_right = DIALOGUE_RIGHT_POS.y if dialogue_data.nodes[0].side == "l" else DIALOGUE_LEFT_POS.y
	var dialogue_box_pos_y := dialogue_box.rect_position.y
	dialogue_box_pos_y = MAX_DIALOGUE_HEIGHT_POS
	
	var target_dialog_pos : Vector2
	var cur_character_panel : Control
	for dialogue_node in dialogue_data.nodes:
		if dialogue_node.side == "l":
			cur_character_panel = character_1
			target_dialog_pos = DIALOGUE_RIGHT_POS
		else:
			cur_character_panel = character_2
			target_dialog_pos = DIALOGUE_LEFT_POS
		
		cur_character_panel.get_node("Portrait").texture = Game_Manager.campaign_data.portraits[dialogue_node.character]
		cur_character_panel.get_node("Panel/Name").text = dialogue_node.character
		ui_tween.interpolate_property(cur_character_panel, "rect_position", null, Vector2(cur_character_panel.rect_position.x, MAX_CHAR_HEIGHT_POS), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		ui_tween.interpolate_property(dialogue_box, "rect_position:y", null, dialogue_box_pos_y, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		ui_tween.interpolate_property(dialogue_box, "anchor_left", null, target_dialog_pos.x, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		ui_tween.interpolate_property(dialogue_box, "anchor_right", null, target_dialog_pos.y, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		
		ui_tween.start()
		yield(ui_tween, "tween_all_completed")
		
		text_label.percent_visible = 0
		text_label.bbcode_text = dialogue_node.text
		
		dialogue_tween.interpolate_property(text_label, "percent_visible", 0.0, 1.0, text_label.bbcode_text.length() / CHARS_PER_SECONDS, Tween.TRANS_LINEAR)
		dialogue_tween.start()
		yield(dialogue_tween, "tween_all_completed")
		yield(self, "on_dialogue_next")
		
		text_label.bbcode_text = ""
		
		ui_tween.interpolate_property(cur_character_panel, "rect_position", null, Vector2(cur_character_panel.rect_position.x, MIN_HEIGHT_POS), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		ui_tween.start()
		yield(ui_tween, "tween_all_completed")
	
	ui_tween.interpolate_property(dialogue_box, "rect_position", null, Vector2(dialogue_box.rect_position.x, MIN_HEIGHT_POS), 0.5,  Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	ui_tween.start()
	yield(ui_tween, "tween_all_completed")
	dialogue_box.anchor_left = DIALOGUE_RIGHT_POS.x
	dialogue_box.anchor_right = DIALOGUE_RIGHT_POS.y
	
	self.visible = false
	emit_signal("on_dialogue_finished")
	emit_signal("on_dialogue_toggle", false)
