class_name LoudDict
extends Resource



class Int:
	extends LoudDict

	var sum: = 0

	func _init(_data: = {}) -> void :
		super (_data)
		if multiplicative:
			add_to_sum = func(value):
				sum *= value
			subtract_from_sum = func(value):
				sum /= value
			reset_sum = func():
				sum = 1
		else:
			add_to_sum = func(value):
				sum += value
			subtract_from_sum = func(value):
				sum -= value
			reset_sum = func():
				sum = 0
		reset_sum.call()


class Float:
	extends LoudDict


	var sum: = 0.0


	func _init(_data: = {}) -> void :
		super (_data)
		if multiplicative:
			add_to_sum = func(value):
				if value is Big:
					value = value.to_float()
				sum *= value
			subtract_from_sum = func(value):
				if value is Big:
					value = value.to_float()
				sum /= value
			reset_sum = func():
				sum = 1.0
		else:
			add_to_sum = func(value):
				if value is Big:
					value = value.to_float()
				sum += value
			subtract_from_sum = func(value):
				if value is Big:
					value = value.to_float()
				sum -= value
			reset_sum = func():
				sum = 0.0
		reset_sum.call()


class _Big:
	extends LoudDict


	var sum: Big


	func _init(_data: = {}) -> void :
		super (_data)
		if multiplicative:
			reset_sum = func():
				sum = Big.new(1.0)
			add_to_sum = func(value):
				sum.times_equals(value)
			subtract_from_sum = func(value):
				sum.divided_by_equals(value)
		else:
			reset_sum = func():
				sum = Big.new(0.0)
			add_to_sum = func(value):
				sum.plus_equals(value)
			subtract_from_sum = func(value):
				sum.minus_equals(value)
		reset_sum.call()


var data: = {}
var base: = {}
var multiplicative: bool
var add_to_sum: Callable
var subtract_from_sum: Callable
var reset_sum: Callable
var is_value_redundant: Callable
var would_divide_by_zero: Callable



var _changed: = true
var _keys: Array
var _values: PackedFloat32Array




func _init(_data: = {}) -> void :
	multiplicative = _data.get("multiplicative", false)
	_data.erase("multiplicative")
	base = _data
	data = base
	if multiplicative:
		is_value_redundant = func(value) -> bool:
			match typeof(value):
				TYPE_INT, TYPE_FLOAT:
					return is_equal_approx(value, 1)
				_:
					return value.is_equal_to(1)
		would_divide_by_zero = func(value) -> bool:
			match typeof(value):
				TYPE_INT, TYPE_FLOAT:
					return is_zero_approx(value)
				_:
					return value.is_zero()
	else:
		is_value_redundant = func(value) -> bool:
			match typeof(value):
				TYPE_INT, TYPE_FLOAT:
					return is_zero_approx(value)
				_:
					return value.is_zero()
		would_divide_by_zero = func(_value) -> bool:
			return false





func recalculate_sum() -> void :
	reset_sum.call()
	for value in data.values():
		add_to_sum.call(value)


func are_values_equal(value1, value2) -> bool:
	match typeof(value1):
		TYPE_INT, TYPE_FLOAT:
			match typeof(value2):
				TYPE_INT, TYPE_FLOAT:
					return is_equal_approx(value1, value2)
				_:
					return value2.is_equal_to(value1)
		_:
			return value1.is_equal_to(value2)


func add(key: Variant, value: Variant) -> void :
	if is_value_redundant.call(value):
		return
	if value is Big:
		data[key] = Big.new(value)
	else:
		data[key] = value
	_changed = true
	add_to_sum.call(value)


func erase(key: Variant) -> void :
	if not data.keys().has(key):
		return
	if would_divide_by_zero.call(get_value(key)):
		data.erase(key)
		recalculate_sum()
		return
	var value: Variant = get_value(key)
	subtract_from_sum.call(value)
	_changed = true
	data.erase(key)


func get_random_value(rng: RandomNumberGenerator) -> Variant:
	if _changed:
		_update_keys_and_values()
	return _values[rng.rand_weighted(_values)]


func get_random_key(rng: RandomNumberGenerator = Main.rng) -> Variant:
	if _changed:
		_update_keys_and_values()
	return _keys[rng.rand_weighted(_values)]


func get_specific_number_of_random_keys(n: int, rng: RandomNumberGenerator = Main.rng) -> Array[Variant]:
	var result: Array[Variant]
	var _data: Dictionary = data.duplicate()
	var __keys: Array = _data.keys().duplicate()
	var __values: PackedFloat32Array = _data.values().duplicate()
	for __ in range(n):
		var key: Variant = __keys[rng.rand_weighted(__values)]
		var index: int = __keys.find(key)
		__keys.remove_at(index)
		__values.remove_at(index)
		result.append(key)
	return result


func _update_keys_and_values() -> void :
	if not _changed:
		return
	_changed = false
	_keys = data.keys()
	_values = data.values()








func reset() -> void :
	data.clear()
	for x in base.keys():
		data[x] = base[x]
	recalculate_sum()


func edit(key: Variant, value: Variant) -> void :
	if key in data.keys():
		if are_values_equal(get_value(key), value):
			return
		erase(key)
	add(key, value)








func has(key: Variant) -> bool:
	return data.has(key)


func get_value(key: Variant) -> Variant:
	return data.get(key, null)


func keys() -> Array:
	return data.keys()


func values() -> Array:
	return data.values()


func size() -> int:
	return data.size()


func is_empty() -> bool:
	return data.is_empty()
