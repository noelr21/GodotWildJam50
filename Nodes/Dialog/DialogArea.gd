extends Area2D

export var dialog_key = ""
var area_active = false

func _input(event):
	if area_active and event.is_action_pressed("ui_accept"):
		DialogueSignalBus.emit_signal("display_dialog", dialog_key)

func _on_DialogArea_area_entered(_area:Area2D):
	area_active = true

func _on_DialogArea_area_exited(_area:Area2D):
	area_active = false

