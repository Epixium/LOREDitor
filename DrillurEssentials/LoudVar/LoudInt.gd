class_name LoudInt
extends LoudNumber


const ZERO: int = 0
const ONE: int = 1

@warning_ignore("unused_private_class_variable")
@export var current: int:
	set = _set_current

var previous: int
var base: int
var custom_minimum_limit: = MIN_INT:
	set = _set_minimum_limit
var custom_maximum_limit: = MAX_INT:
	set = _set_maximum_limit



func _init(_base: int = ZERO) -> void :
	base = _base
	current = base
	previous = base
	changed.connect(loud_number_init)

func _set_current(val: int) -> void :
	previous = current
	val = clampi(val, custom_minimum_limit, custom_maximum_limit)
	if is_zero_approx(val):
		val = 0
	if not is_equal_approx(current, val):
		current = val
		text_requires_update = true
	_emit_signals(previous, current)


func _set_minimum_limit(val: int) -> void :
	custom_minimum_limit = val
	clamp_current()


func _set_maximum_limit(val: int) -> void :
	custom_maximum_limit = val
	clamp_current()

func _emit_signals(_previous: int, _current: int) -> void :
	if not is_equal_approx(_current, _previous):
		if _previous > _current:
			decreased.emit()
		elif _previous < _current:
			increased.emit()
		number_changed.emit(self)
		changed.emit()

func reset() -> void :
	if current == base:
		return
	current = base
	super ()


func set_to(amount: int) -> void :
	current = amount


func plus_equals(amount: int) -> void :
	if is_zero_approx(amount):
		return
	current += amount


func plus_equals_one() -> void :
	plus_equals(ONE)


func minus_equals(amount: int) -> void :
	if is_zero_approx(amount):
		return
	current -= amount


func minus_equals_one() -> void :
	minus_equals(ONE)


func times_equals(amount: int) -> void :
	if is_equal_approx(amount, 1):
		return
	current *= amount


func divided_by_equals(amount: int) -> void :
	if is_equal_approx(amount, 1):
		return
	current /= amount

func set_default_value(val: int) -> void :
	base = val


func clamp_current() -> void :
	current = clampi(current, custom_minimum_limit, custom_maximum_limit)


func copycat(cat: Resource) -> void :
	set_default_value(0)
	set_to(0)
	super (cat)


func set_bool_limiter(b: LoudBool, limit: int) -> void :
	if b.is_false():
		custom_minimum_limit = limit
		custom_maximum_limit = limit
		set_to(limit)
	b.became_true.connect(
		func():
			custom_minimum_limit = MIN_INT
			custom_maximum_limit = MAX_INT
	)
	b.became_false.connect(
		func():
			custom_minimum_limit = limit
			custom_maximum_limit = limit
			set_to(limit)
	)

func get_value() -> int:
	return current


func get_effective_value() -> int:
	return current


func get_text() -> String:
	if text_requires_update:
		update_text(current)
	return text


func is_positive() -> bool:
	return current >= ZERO


func is_greater_than(val) -> bool:
	return not is_less_than_or_equal_to(val)


func is_greater_than_or_equal_to(val) -> bool:
	return not is_less_than(val)


func is_equal_to(val) -> bool:
	return is_equal_approx(current, val)


func is_less_than_or_equal_to(val) -> bool:
	return is_less_than(val) or is_equal_to(val)


func is_less_than(val) -> bool:
	return current < val


func to_float() -> float:
	return float(current)


func get_random_point(between: = 0) -> float:
	return randf_range(between, get_value())


func get_x_percent(x: float) -> float:
	return roundf(float(get_value()) * x)


func is_zero() -> bool:
	return is_equal_to(ZERO)





func plus(_amount: int) -> int:
	return get_value() + _amount


func minus(_amount: int) -> int:
	return get_value() - _amount


func times(_amount: float) -> float:
	return to_float() * _amount


func divided_by(_amount: float) -> float:
	return to_float() / _amount


func to_the_power_of(_n: float) -> float:
	return pow(get_value(), _n)


func modulo(_amount: int) -> int:
	return get_value() %_amount
