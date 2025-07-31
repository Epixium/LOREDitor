class_name BigFloatPair
extends Resource


@export var current: BigFloat

var total: BigFloat

var cap_current: = true
var full: = LoudBool.new(false)
var empty: = LoudBool.new(false)





func _init(base_value = 1.0, base_total = base_value) -> void :
	current = BigFloat.new(base_value)
	total = BigFloat.new(base_total)

	current.changed.connect(emit_changed)
	current.increased.connect(check_if_full)
	current.decreased.connect(check_if_empty)
	total.changed.connect(emit_changed)
	total.changed.connect(check_if_full)
	total.changed.connect(check_if_empty)

	check_if_full()
	check_if_empty()



func load_finished() -> void :
	if cap_current:
		check_if_full()


func check_if_full() -> void :
	if current.is_greater_than(get_total()):
		if cap_current:
			fill()
		full.set_true()
	elif current.is_equal_to(get_total()):
		full.set_true()
	else:
		full.set_false()


func check_if_empty() -> void :
	empty.set_to(current.is_zero())









func reset():
	current.reset()
	total.reset()


func change_base(new_base_value: float) -> void :
	current.change_base(new_base_value)


func do_not_cap_current() -> BigFloatPair:
	cap_current = false
	return self



func plus_equals(amount: Variant) -> void :
	amount = set_amount_to_deficit_if_necessary(amount)
	current.plus_equals(amount)


func plus_equals_one() -> void :
	plus_equals(1)


func minus_equals(amount: Variant) -> void :
	current.minus_equals(Big.to_big(amount))


func add_percent(percent: float) -> void :
	var added_amount: Big = Big.multiply(get_total(), percent)
	plus_equals(added_amount)


func set_amount_to_deficit_if_necessary(amount: Variant) -> Big:
	amount = Big.to_big(amount)
	if not cap_current:
		return amount
	var deficit = get_deficit()
	if deficit.is_less_than(amount):
		return deficit
	return amount


func increase_added(amount: Variant) -> void :
	total.increase_added(amount)


func decrease_added(amount: Variant) -> void :
	total.decrease_added(amount)


func increase_subtracted(amount: Variant) -> void :
	total.increase_subtracted(amount)


func decrease_subtracted(amount: Variant) -> void :
	total.decrease_subtracted(amount)


func increase_multiplied(amount: Variant) -> void :
	total.increase_multiplied(amount)


func decrease_multiplied(amount: Variant) -> void :
	total.decrease_multiplied(amount)


func increase_divided(amount: Variant) -> void :
	total.increase_divided(amount)


func decrease_divided(amount: Variant) -> void :
	total.decrease_divided(amount)


func set_from_level(amount: Variant) -> void :
	total.set_from_level(Big.to_big(amount))


func set_d_from_lored(amount: Variant) -> void :
	total.set_d_from_lored(Big.to_big(amount))


func set_m_from_lored(amount: Variant) -> void :
	total.set_m_from_lored(Big.to_big(amount))


func set_to(amount: Variant) -> void :
	current.set_to(Big.to_big(amount))
	check_if_full()




func set_to_percent(percent: float, with_random_range: = false) -> void :
	var multiplier: = 1.0 if not with_random_range else randf_range(0.8, 1.2)
	percent *= multiplier
	set_to(get_x_percent(percent))


func fill() -> void :

	set_to(get_total())






func get_current() -> Big:
	return current.current


func get_value() -> Big:
	return get_current()


func get_current_percent() -> float:
	return get_current().percent_of(get_total())


func get_unclamped_percent() -> float:
	return Big.divide(get_current(), get_total()).to_float()


func get_pending() -> Big:
	return current.get_pending()


func get_pending_percent() -> float:
	return Big.new(current.get_effective_value()).percent_of(get_total())


func get_x_percent(float_between_0_and_1: float) -> Big:
	return Big.multiply(get_total(), float_between_0_and_1)


func get_x_percent_text(percent: float) -> String:
	return get_x_percent(percent).text


func get_randomized_total(min_range: = 0.8, max_range: = 1.2) -> Big:
	return Big.multiply(get_total(), randf_range(min_range, max_range))


func get_midpoint() -> Big:
	if is_full() and cap_current:
		return get_total()
	return Big.add(get_current(), get_total()).divided_by(2)


func get_average() -> Big:
	return get_midpoint()


func get_random_point() -> Big:
	if is_full() and cap_current:
		return get_total()
	return Big.rand_range(get_current(), get_total())


func get_total() -> Big:
	return total.current


func get_total_text() -> String:
	return total.get_text()


func get_as_float() -> float:
	return total.get_as_float()


func get_as_int() -> int:
	return total.get_as_int()


func get_current_text() -> String:
	return current.get_text()


func get_deficit() -> Big:
	return Big.subtract(get_total(), get_current())


func get_surplus() -> Big:
	if current.current.is_greater_than_or_equal_to(total.current):
		return Big.subtract(get_current(), get_total())
	return Big.ZERO


func get_base() -> Big:
	return total.base


func get_deficit_text() -> String:
	return get_deficit().text


func get_text() -> String:
	return get_current_text() + "/" + get_total_text()


func is_empty() -> bool:
	return get_current().is_zero()


func is_full() -> bool:
	return get_current().is_greater_than_or_equal_to(get_total())


func is_not_full() -> bool:
	return not is_full()
