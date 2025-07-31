class_name LoudBool
extends Resource


signal became_true
signal became_false

@export var current: bool:
	set = _set_current

var base: bool
var copied_bool: LoudBool
var button: Control
var display_node: Control





func _init(_base: bool = false) -> void :
	base = _base
	current = _base








func _set_current(val: bool) -> void :
	if current == val:
		return
	current = val
	emit_changed()
	if val:
		became_true.emit()
	else:
		became_false.emit()








func invert() -> void :
	set_to( not current)


func invert_default_value() -> void :
	set_default_value( not base)


func set_true() -> void :
	set_to(true)


func set_false() -> void :
	set_to(false)


func set_to(val: bool) -> void :
	current = val


func set_default_value(val: bool) -> void :
	base = val


func reset() -> void :
	set_to(base)


func tie_button_pressed(_button: Control) -> void :
	if button:
		pass
	button = _button
	button.button_pressed = is_true()
	if not changed.is_connected(_update_button_pressed):
		changed.connect(_update_button_pressed)
	if not button.toggled.is_connected(_button_toggled):
		button.toggled.connect(_button_toggled)


func clear_button() -> void :
	changed.disconnect(_update_button_pressed)
	if button:
		button.toggled.disconnect(_button_toggled)
	button = null


func _button_toggled(_toggled: bool) -> void :
	button.toggled.disconnect(_button_toggled)
	set_to(_toggled)
	await Main.process_frame()
	if not button:
		clear_button()
	else:
		button.toggled.connect(_button_toggled)


func _update_button_pressed() -> void :
	if not button:
		clear_button()
		return
	button.button_pressed = is_true()








func copycat(_copied_bool: LoudBool) -> void :
	copied_bool = _copied_bool
	copied_bool.changed.connect(copycat_changed)
	copycat_changed()


func copycat_changed() -> void :
	set_to(copied_bool.get_value())


func remove_copycat() -> void :
	if not copied_bool:
		return
	copied_bool.changed.disconnect(copycat_changed)
	copied_bool = null


func contradict(_bool: LoudBool) -> void :
	set_to( not _bool.get_value())
	_bool.changed.connect(invert)


func is_copycat() -> bool:
	return copied_bool != null











func get_value() -> bool:
	return current


func is_true() -> bool:
	return get_value()


func is_false() -> bool:
	return not is_true()


func get_default_value() -> bool:
	return base


func is_true_by_default() -> bool:
	return get_default_value()


func is_false_by_default() -> bool:
	return not is_true_by_default()
