class_name LoudArray
extends Resource



var array: Array
var size: = LoudInt.new(0)



func _init(_array: = []) -> void :
	array = _array.duplicate(true)
	size.changed.connect(emit_changed)






func append(value) -> void :
	array.append(value)
	size.plus_equals(1)


func erase(value) -> void :
	array.erase(value)
	size.minus_equals(1)


func set_to(_array: Array) -> void :
	array = _array.duplicate(true)
	size.set_to(array.size())


func add(_array: Array) -> void :
	array += _array.duplicate(true)
	size.plus_equals(_array.size())








func get_value() -> Array:
	return array


func get_size() -> int:
	return size.get_value()


func get_duplicate() -> Array:
	return array.duplicate(true)


func is_empty() -> bool:
	return array.is_empty()
