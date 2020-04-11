extends Panel

class_name Cutscene_Menu

const CHARS_PER_SECONDS : float = 30.0

signal on_cutscene_toggle(is_active)
signal on_cutscene_finished()
signal on_cutscene_node_next()

onready var image := $Image as TextureRect
onready var text := $Text as RichTextLabel
onready var tween := $Tween as Tween

func _ready():
	self.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		
		if tween.is_active():
			tween.stop_all()
			text.percent_visible = 1.0
			tween.emit_signal("tween_all_completed")
		else:
			emit_signal("on_cutscene_node_next")

func play_cutscene(cutscene_id : String) -> void:
	emit_signal("on_cutscene_toggle", true)
	
	var cutscene_data := Game_Manager.campaign_data.cutscenes[cutscene_id] as Model.Cutscene_Data
	
	for cutscene_node in cutscene_data.nodes:
		image.texture = cutscene_node.image
		
		text.percent_visible = 0
		text.bbcode_text = cutscene_node.text
		self.visible = true
		
		tween.interpolate_property(text, "percent_visible", 0.0, 1.0, text.text.length() / CHARS_PER_SECONDS, Tween.TRANS_LINEAR)
		tween.start()
		yield(tween, "tween_all_completed")
		yield(self, "on_cutscene_node_next")
	
	self.visible = false
	
	emit_signal("on_cutscene_toggle", false)
	emit_signal("on_cutscene_finished")
