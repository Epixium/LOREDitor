extends Control

enum SaveMethod {TO_FILE, TO_CLIPBOARD, TO_CONSOLE, SET_DEFAULT_DATA, TEST}
enum LoadMethod {FROM_FILE_COMPRESSED, FROM_FILE_NOT_COMPRESSED, FROM_CLIPBOARD, TEST}

const SAVE_EXTENSION: String = ".lored"

var default_save_method: = SaveMethod.TO_FILE
var default_load_method: = LoadMethod.FROM_FILE_COMPRESSED

var fullfile

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)

var changes_made = false
var quitting = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if %SaveTree.all_changes_default(): get_tree().quit()
		else:
			quitting = true
			$SaveAllPopup.show()

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
				%SaveAlert.show_alert("Saved file at " + path + "!")

			SaveMethod.TO_CLIPBOARD:
				save_text = Marshalls.variant_to_base64(save_text)
				DisplayServer.clipboard_set(save_text)
				%SaveAlert.show_alert("Copied file to clipboard!")

			SaveMethod.TO_CONSOLE:
				print("LORED Save:")
				print(Marshalls.variant_to_base64(save_text))
				%SaveAlert.show_alert("Printed file to console!")
		
		%SaveTree.set_all_original_values()
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
	savemethod = SaveMethod.TO_FILE
	fullfile = get_save_data(path, LoadMethod.FROM_FILE_COMPRESSED)
	%SaveTree.create_tree_from_nested_dict(fullfile)
	%FileButton.text = path

@onready var fbbase = %FileButton.text

var savemethod 

func _on_button_pressed() -> void:
	savemethod = SaveMethod.TO_FILE
	
	if %FileButton.text == fbbase:
		var data_dir = OS.get_user_data_dir()
		var splot = data_dir.split("/")
		splot.remove_at(splot.size()-1)
		data_dir = "/".join(splot) + "/LORED/"
		%FileButton.text = data_dir + "ClipboardSave.lored"
	
	if not %SaveTree.all_changes_saved():
		%SaveAllPopup.show()
		return
	
	save_game(%FileButton.text, SaveMethod.TO_FILE)

func _on_clip_file_button_pressed() -> void:
	savemethod = SaveMethod.TO_CLIPBOARD
	fullfile = get_save_data("", LoadMethod.FROM_CLIPBOARD)
	if fullfile == {}: 
		%ClipFileButton.text = "Something went wrong!"
		return
	%ClipFileButton.text = "Load from clipboard!"
	%SaveTree.create_tree_from_nested_dict(fullfile)

func _on_clip_save_button_pressed() -> void:
	savemethod = SaveMethod.TO_CLIPBOARD
	if not %SaveTree.all_changes_saved():
		%SaveAllPopup.show()
		return
	save_game("", SaveMethod.TO_CLIPBOARD)

func _on_save_changes_pressed() -> void:
	%SaveTree.save_all_changes()
	%SaveAllPopup.hide()
	save_game(%FileButton.text, savemethod)
	if quitting: get_tree().quit()

func _on_do_not_pressed() -> void:
	%SaveAllPopup.hide()
	if quitting: get_tree().quit()
	else: save_game(%FileButton.text, savemethod)
	

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
