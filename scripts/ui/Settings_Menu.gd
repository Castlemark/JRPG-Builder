extends Control

class_name Settings

onready var fullscreen_button := $Panel/Settings/FullscreenButton as CheckButton
onready var vsync_button := $Panel/Settings/VsyncButton as CheckButton

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
