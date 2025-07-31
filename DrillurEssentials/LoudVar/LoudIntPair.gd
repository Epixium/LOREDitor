class_name LoudIntPair
extends Resource


@export var current: LoudInt:
	set = _set_current

var total: LoudInt

var full: = LoudBool.new(false)
var empty: = LoudBool.new(false)

var text: String
var text_requires_update: = true
var limit_to_zero: = true
var limit_to_total: = true

var result_of_previous_random_point: int





func _init(base_value: int, base_total: int, _limit_to_total = true):
	current = LoudInt.new(base_value)
	total = LoudInt.new(base_total)
	limit_to_total = _limit_to_total
	if current.is_greater_than_or_equal_to(get_total()):
		full.set_default_value(true)
		full.reset()
	elif current.is_less_than_or_equal_to(0):
		empty.set_default_value(true)
		empty.reset()
	total.text_changed.connect(text_changed)
	total.changed.connect(check_if_full)
	total.changed.connect(emit_changed)

func _game_loaded() -> void :
	clamp_current()
	check_if_empty()
	check_if_full()








func _set_current(val: LoudInt) -> void :
	if current:
		if current == val:
			return
		current.text_changed.disconnect(text_changed)
		current.changed.disconnect(check_if_empty)
		current.changed.disconnect(check_if_full)
		current.changed.disconnect(emit_changed)
	current = val
	current.text_changed.connect(text_changed)
	current.changed.connect(check_if_empty)
	current.changed.connect(check_if_full)
	current.changed.connect(emit_changed)








func text_changed() -> void :
	text_requires_update = true


func check_if_full() -> void :
	full.set_to(current.is_greater_than_or_equal_to(get_total()))


func check_if_empty() -> void :
	empty.set_to(current.is_less_than_or_equal_to(0))








func do_not_limit_to_total() -> LoudIntPair:
	limit_to_total = false
	return self


func do_not_limit_to_zero() -> LoudIntPair:
	limit_to_zero = false
	return self


func plus_equals(amount: int) -> void :
	if limit_to_total and full.is_true():
		return
	current.plus_equals(amount)
	check_if_full()
	clamp_current()


func plus_equals_one() -> void :
	plus_equals(LoudInt.ONE)


func minus_equals(amount: int) -> void :
	if limit_to_zero and empty.is_true():
		return
	current.minus_equals(amount)
	check_if_empty()
	clamp_current()


func minus_equals_one() -> void :
	minus_equals(LoudInt.ONE)


func clamp_current() -> void :
	if limit_to_total:
		if limit_to_zero:
			current.current = clampi(get_current(), 0, get_total())
		else:
			current.current = mini(get_current(), get_total())
	else:
		if limit_to_zero:
			current.current = maxi(get_current(), 0)


func fill() -> void :
	if full.is_false():
		current.set_to(get_total())


func dump() -> void :
	if empty.is_false():
		current.set_to(LoudInt.ZERO)








func get_value() -> int:
	return current.get_value()


func get_current() -> int:
	return get_value()


func get_total() -> int:
	return total.get_value()


func get_current_percent() -> float:
	return float(get_value()) / get_total()


func get_pending_percent() -> float:
	return float(current.get_effective_value()) / get_total()


func get_deficit() -> int:
	return abs(get_total() - get_current())


func get_surplus(amount: int) -> int:
	if full.is_true() or get_value() + amount > get_total():
		return (get_current() + amount) - get_total()
	return 0


func get_midpoint() -> int:
	if is_full():
		return get_total()
	return roundi(float(get_current() + get_total()) / 2)


func get_random_point() -> int:
	result_of_previous_random_point = get_total() if is_full() else randi_range(get_current(), get_total())
	return get_previous_random_point()


func get_average() -> int:
	return roundi(float(get_current() + get_total()) / 2)


func get_previous_random_point() -> int:
	return result_of_previous_random_point


func get_text() -> String:
	if text_requires_update:
		text_requires_update = false
		text = "%s/%s" % [get_current_text(), get_total_text()]
	return text


func get_current_text() -> String:
	return current.get_text()


func get_total_text() -> String:
	return total.get_text()


func is_full() -> bool:
	return get_current() >= get_total()


func is_effectively_full() -> bool:
	return current.get_effective_value() >= get_total()


func is_not_full() -> bool:
	return full.is_false()


func is_empty() -> bool:
	return current.is_zero()
