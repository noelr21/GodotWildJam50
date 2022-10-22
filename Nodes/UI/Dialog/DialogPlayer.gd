extends CanvasLayer

export (String, FILE, "*json") var scene_text_file
export(float, EXP, 1, 100, 0.5) var characters_per_second


var scene_text = {}
var selected_text = []
var current_text = ""
var char_index = 0
var in_progress = false
var printing_line = false
var wait_timer = 1

onready var background = $Background
onready var text_label = $TextLabel
onready var timer = $Timer

func _ready():
	background.visible = false
	scene_text = load_scene_text()
	self.offset = Vector2(0, ProjectSettings.get_setting("display/window/size/height") - background.texture.get_height())
	DialogueSignalBus.connect("display_dialog", self, "on_display_dialog")

func load_scene_text():
	var file = File.new()
	if file.file_exists(scene_text_file):
		file.open(scene_text_file, File.READ)
		return parse_json(file.get_as_text())

func show_text():
	current_text = selected_text.pop_front()
	char_index = 0
	printing_line = true
	text_label.text = ""
	print_next_char()
	wait_timer /= characters_per_second #calculate characters per second
	timer.start(wait_timer)

func next_line():
	#check if line is currently printing if so skip and show entire line otherwise move on to next line
	if printing_line:
		timer.stop()
		text_label.text = current_text
		printing_line = false
		return
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish():
	text_label.text = ""
	background.visible = false
	in_progress = false
	get_tree().paused = false

func on_display_dialog(text_key):
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		background.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()

func print_next_char():
	#grab next character and validate
	var newChar = current_text.substr(char_index, 1)
	#stop printing if line is empty
	if newChar.empty():
		printing_line = false
		return
	#print next character
	var output_text = text_label.text
	output_text += newChar
	text_label.text = output_text
	#TODO: play sound note
	#increment character index and start timer again
	char_index += 1
	timer.start(wait_timer)


func _on_Timer_timeout():
	print_next_char()