class_name LoudFloatPair
extends Resource


@export var current: LoudFloat
var total: LoudFloat

var full: = LoudBool.new(false)
var empty: = LoudBool.new(false)

var text: String
var text_requires_update: = true
var limit_to_zero: = true
var limit_to_total: = true

var result_of_previous_random_point: float


func _init(base_value: float, base_total: float, _limit_to_total = true):
	current = LoudFloat.new(base_value)
	total = LoudFloat.new(base_total)
	limit_to_total = _limit_to_total
	if current.is_equal_to(total.get_value()):
		full.set_default_value(true)
		full.reset()
	elif current.is_zero():
		empty.set_default_value(true)
		empty.reset()
	current.changed.connect(text_changed)
	total.changed.connect(text_changed)
	current.changed.connect(check_if_full)
	current.changed.connect(check_if_empty)
	total.changed.connect(check_if_full)
	current.changed.connect(emit_changed)
	total.changed.connect(emit_changed)






func text_changed() -> void :
	text_requires_update = true


func check_if_full() -> void :
	full.set_to(current.is_greater_than_or_equal_to(get_total()))


func check_if_empty() -> void :
	empty.set_to(current.is_zero())








func do_not_limit_to_total() -> LoudFloatPair:
	limit_to_total = false
	return self


func do_not_limit_to_zero() -> LoudFloatPair:
	limit_to_zero = false
	return self


func plus_equals(amount: float) -> void :
	if limit_to_total and full.is_true():
		return
	current.plus_equals(amount)
	check_if_full()
	clamp_current()


func plus_equals_one() -> void :
	plus_equals(LoudFloat.ONE)


func minus_equals(amount: float) -> void :
	if limit_to_zero and empty.is_true():
		return
	current.minus_equals(amount)
	check_if_empty()
	clamp_current()


func minus_equals_one() -> void :
	minus_equals(LoudFloat.ONE)


func clamp_current() -> void :
	if limit_to_total:
		if limit_to_zero:
			current.current = clampf(get_current(), 0.0, get_total())
		else:
			current.current = minf(get_current(), get_total())
	else:
		if limit_to_zero:
			current.current = maxf(get_current(), 0.0)


func fill() -> void :
	if full.is_false():
		plus_equals(get_deficit())


func dump() -> void :
	if empty.is_false():
		minus_equals(get_current())








func get_value() -> float:
	return current.get_value()


func get_current() -> float:
	return get_value()


func get_total() -> float:
	return total.get_value()


func get_current_percent() -> float:
	return get_value() / get_total()


func get_pending_percent() -> float:
	return current.get_effective_value() / get_total()


func get_deficit() -> float:
	return absf(get_total() - get_current())


func get_surplus(amount: float = get_current()) -> float:
	if full.is_true() or get_value() + amount > get_total():
		return (get_current() + amount) - get_total()
	return 0.0


func get_midpoint() -> float:
	if is_full():
		return get_total()
	return (get_current() + get_total()) / 2


func get_random_point() -> float:
	result_of_previous_random_point = get_total() if is_full() else randf_range(get_current(), get_total())
	return get_previous_random_point()


func get_average() -> float:
	return get_midpoint()


func get_previous_random_point() -> float:
	return result_of_previous_random_point


func get_text() -> String:
	if text_requires_update:
		text_requires_update = false
		text = get_current_text() + "/" + get_total_text()
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


func has(amount: int) -> bool:
	return current.is_greater_than_or_equal_to(amount)
