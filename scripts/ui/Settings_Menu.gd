extends Control

class_name Settings

onready var fullscreen_button := $FullscreenButton as CheckButton
onready var vsync_button := $VsyncButton as CheckButton

func _on_FullscreenButton_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed

func _on_VsyncButton_toggled(button_pressed: bool) -> void:
	OS.vsync_enabled = button_pressed

func _on_CheckBox_60fps_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Engine.target_fps = 60

func _on_CheckBox_30fps_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Engine.target_fps = 30

func _on_exit_pressed():
	get_tree().quit()

func _on_title_screen_pressed():
	Game_Manager.goto_scene(Game_Manager.TITLE_SCREEN)
	Game_Manager.campaign_data = null
