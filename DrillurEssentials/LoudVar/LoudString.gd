class_name LoudString
extends Resource


signal changed_from_empty
signal set_to_non_empty

@export var current: String:
	set = set_text

var copycat_string: LoudString

var base: String







func _init(_base: = "") -> void :
	base = _base
	current = base


func set_text(val) -> void :
	if current != val:
		var previous_value: String = current
		current = val
		changed.emit()
		if previous_value == "":
			changed_from_empty.emit()
	if current != "":
		set_to_non_empty.emit()








func reset() -> void :
	set_to(base)


func set_to(val: String) -> void :
	current = val


func attach_resource(_resource: Resource) -> void :
	var update = func():
		set_to(_resource.get_text())
	_resource.changed.connect(update)
	update.call()


func copycat(_string: LoudString) -> void :
	copycat_string = _string
	copycat_string.changed.connect(copycat_string_changed)
	copycat_string_changed()


func copycat_string_changed() -> void :
	set_to(copycat_string.get_text())


func clear_copycat() -> void :
	if copycat_string:
		copycat_string.changed.disconnect(copycat_string_changed)
	copycat_string = null









func get_value() -> String:
	return current


func get_text() -> String:
	return current


func is_equal_to(_text: String) -> bool:
	return current == _text


func is_empty() -> bool:
	return current.is_empty()


func split(delimiter: String = "", allow_empty: bool = true, maxsplit: int = 0) -> Array:
	return current.split(delimiter, allow_empty, maxsplit)
