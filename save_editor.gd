extends Control

enum SaveMethod {TO_FILE, TO_CLIPBOARD, TO_CONSOLE, SET_DEFAULT_DATA, TEST}
enum LoadMethod {FROM_FILE_COMPRESSED, FROM_FILE_NOT_COMPRESSED, FROM_CLIPBOARD, TEST}

const SAVE_EXTENSION: String = ".lored"

var default_save_method: = SaveMethod.TO_FILE
var default_load_method: = LoadMethod.FROM_FILE_COMPRESSED

var fullfile

func get_filename_from_filepath(path : String):
	return path.split("/")[-1].replace(SAVE_EXTENSION, "")

func get_save_data(_filepath: String, _method : LoadMethod = default_load_method, _save_text: String = get_save_text(_filepath, _method)) -> Dictionary:
	if (_save_text == ""): return {}
	print(get_filename_from_filepath(_filepath) + " LOCATED!!!")
	var json: = JSON.new()
	var error: = json.parse(_save_text)
	return json.data

func get_save_text(_filepath: String, _method: LoadMethod = default_load_method) -> String:
	var save_text: String
	match _method:
		LoadMethod.FROM_FILE_COMPRESSED:
			var save_file: = FileAccess.open_compressed(_filepath, FileAccess.READ, FileAccess.CompressionMode.COMPRESSION_DEFLATE)
			if not save_file:
				return get_save_text(_filepath, LoadMethod.FROM_FILE_NOT_COMPRESSED)
			save_text = save_file.get_line()
		LoadMethod.FROM_FILE_NOT_COMPRESSED:
			var save_file: = FileAccess.open(_filepath, FileAccess.READ)
			var line: = save_file.get_line()
			save_text = Marshalls.base64_to_variant(line)
		LoadMethod.FROM_CLIPBOARD:
			var clipboard_contents = DisplayServer.clipboard_get()
			if clipboard_contents == null or not clipboard_contents is String or clipboard_contents.length() < 1000:
				return ""
			var serialized = Marshalls.base64_to_variant(clipboard_contents)
			if serialized == null:
				return ""
			save_text = serialized
	return save_text

func is_compatible_save(data: Dictionary) -> bool:
	if data == {}:
		return false
	return true

var tween : Tween

func save_game(_filepath : String, method := default_save_method) -> void :
	var packed_vars: Dictionary = fullfile

	if is_compatible_save(packed_vars):
		var save_text: String = JSON.stringify(packed_vars)
		match method:
			SaveMethod.TO_FILE:
				var path_extensionless : String = _filepath.replace(SAVE_EXTENSION, "")
				var i = 1
				var path = path_extensionless + " (" + str(i) + ")" + SAVE_EXTENSION
				while true:
					if FileAccess.file_exists(path_extensionless + " (" + str(i) + ")" + SAVE_EXTENSION): 
						i += 1
						continue
					path = path_extensionless + " (" + str(i) + ")" + SAVE_EXTENSION
					break
				var save_file: = FileAccess.open_compressed(path, FileAccess.WRITE, FileAccess.CompressionMode.COMPRESSION_DEFLATE)
				save_file.store_line(save_text)
				%SaveAlert.text = "[wave amp=20.0 freq=6.0]Saved file at " + path + "![/wave]"
				%SaveAlert.modulate = Color(1, 1, 1, 1)
				tween = get_tree().create_tween()
				tween.set_ease(Tween.EASE_IN)
				tween.set_trans(Tween.TRANS_CIRC)
				tween.tween_property(%SaveAlert, "modulate", Color(1, 1, 1, 0), 3)

			SaveMethod.TO_CLIPBOARD:
				save_text = Marshalls.variant_to_base64(save_text)
				DisplayServer.clipboard_set(save_text)
				%SaveAlert.text = "[wave amp=20.0 freq=6.0]Copied file to clipboard![/wave]"

			SaveMethod.TO_CONSOLE:
				print("LORED Save:")
				print(Marshalls.variant_to_base64(save_text))
				%SaveAlert.text = "[wave amp=20.0 freq=6.0]Printed file to console![/wave]"

		%SaveAlert.modulate = Color(1, 1, 1, 1)
		tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(%SaveAlert, "modulate", Color(1, 1, 1, 0), 3)

	else:
		printerr("SaveManager error: `packed_vars` is not compatible, so it will not be written to file.")

func follow_filepath(dict, path, settable = null):
	var current = dict
	for step in path:
		current = current[step]
	if settable != null:
		current = settable
	return current

func _on_file_dialog_file_selected(path: String) -> void:
	fullfile = get_save_data(path, LoadMethod.FROM_FILE_COMPRESSED)
	%SaveTree.create_tree_from_nested_dict(fullfile)
	%FileButton.text = path

@onready var fbbase = %FileButton.text

func _on_button_pressed() -> void:
	if %FileButton.text == fbbase:
		var data_dir = OS.get_user_data_dir()
		var splot = data_dir.split("/")
		splot.remove_at(splot.size()-1)
		data_dir = "/".join(splot) + "/LORED/"
		%FileButton.text = data_dir + "ClipboardSave.lored"
	
	save_game(%FileButton.text, SaveMethod.TO_FILE)

func _on_clip_file_button_pressed() -> void:
	fullfile = get_save_data("", LoadMethod.FROM_CLIPBOARD)
	if fullfile == {}: 
		%ClipFileButton.text = "Something went wrong!"
		return
	%ClipFileButton.text = "Load from clipboard!"
	%SaveTree.create_tree_from_nested_dict(fullfile)

func _on_clip_save_button_pressed() -> void:
	save_game("", SaveMethod.TO_CLIPBOARD)

# only here for legacy reasons
"""
func _on_line_edit_text_submitted(new_text: String) -> void:
	var paths = new_text.split("#")
	var finder = fullfile.duplicate(false)
	var follow = []
	for thing in paths:
		match thing:
			"FULL":
				print(finder)
				return
			"KEYS":
				print(finder.keys())
				return
			"VARS":
				print(finder.vars())
				return
			var x when x.contains("SET"):
				var operation = x.split(" ")[0]
				var value = x.replace(operation + " ", "")
				match operation:
					_:
						DictIO.manipulate_nested_dict(fullfile, follow, 'write', value, [])
				print(fullfile.Main.currencies.stone)
				return
			_:
				finder = finder[thing]
				follow.append(thing)
				if finder is Dictionary: print(finder.keys())
				else: print(finder)
"""
