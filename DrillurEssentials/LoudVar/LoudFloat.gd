class_name LoudFloat
extends LoudNumber


const ONE: float = 1.0
const ZERO: float = 0.0
const ONE_PERCENT: float = 0.01
const ONE_THIRD: float = 1.0 / 3
const FIFTY_PERCENT: float = 0.5
const NATURAL_LOGARITHM: float = 2.71828

@export var current: float:
	set = _set_current

var previous: float
var base: float
var custom_minimum_limit: = LoudNumber.MIN_FLOAT:
	set = _set_minimum_limit
var custom_maximum_limit: = LoudNumber.MAX_FLOAT:
	set = _set_maximum_limit

func _init(_base: float = 0.0) -> void :
	base = _base
	current = base
	previous = base
	changed.connect(loud_number_init)
	book = Book.new(Book.Type.FLOAT)
	book.changed.connect(sync)
	book.pending_changed.connect(pending_changed.emit)








func _set_current(val: float) -> void :
	previous = current
	val = clampf(val, custom_minimum_limit, custom_maximum_limit)
	if is_zero_approx(val):
		val = 0.0
	if not is_equal_approx(current, val):
		current = val
		text_requires_update = true
	_emit_signals(previous, current)


func _set_minimum_limit(val: float) -> void :
	custom_minimum_limit = val
	clamp_current()


func _set_maximum_limit(val: float) -> void :
	custom_maximum_limit = val
	clamp_current()


func _emit_signals(_previous: float, _current: float) -> void :
	if not _current == _previous:
		if _previous > _current:
			decreased.emit()
		elif _previous < _current:
			increased.emit()
		number_changed.emit(self)
		changed.emit()


func reset() -> void :
	current = base
	super ()


func set_to(amount: float) -> void :
	current = amount


func plus_equals(amount: float) -> void :
	if is_zero_approx(amount):
		return
	current += amount


func plus_equals_one() -> void :
	plus_equals(ONE)


func minus_equals(amount: float) -> void :
	if is_zero_approx(amount):
		return
	current -= amount


func minus_equals_one() -> void :
	minus_equals(ONE)


func times_equals(amount: float) -> void :
	if is_equal_approx(amount, ONE):
		return
	current *= amount


func divided_by_equals(amount: float) -> void :
	if is_equal_approx(amount, ONE):
		return
	current /= amount


func sync() -> void :
	if book.sync_allowed.is_true():
		set_to(book.sync.call(base))


func clamp_current() -> void :
	current = clampf(current, custom_minimum_limit, custom_maximum_limit)


func set_default_value(val: float) -> void :
	base = val


func copycat(cat: Resource) -> void :
	set_default_value(ZERO)
	set_to(ZERO)
	super (cat)


func set_bool_limiter(b: LoudBool, limit: float) -> void :
	if b.is_false():
		custom_minimum_limit = limit
		custom_maximum_limit = limit
		set_to(limit)
	b.became_true.connect(
		func():
			custom_minimum_limit = MIN_FLOAT
			custom_maximum_limit = MAX_FLOAT
			reset()
	)
	b.became_false.connect(
		func():
			custom_minimum_limit = limit
			custom_maximum_limit = limit
			set_to(limit)
	)

static func roll_as_int(value: float) -> int:
	var chance_to_return_plus_one: = get_decimals(value)
	var result: int = floori(value)
	if randf() < chance_to_return_plus_one:
		result += 1
	return result


static func get_decimals(value: float) -> float:
	return value - floorf(value)


static func to_float(_value: Variant) -> float:
	match typeof(_value):
		TYPE_FLOAT:
			return _value
		TYPE_INT:
			return float(_value)
		TYPE_OBJECT:
			if _value is Big:
				return _value.to_float()
			elif _value is LoudFloat:
				return _value.get_value()
			elif _value is LoudInt:
				return float(_value.get_value())
	return float(_value)








func get_value() -> float:
	return current


func get_effective_value() -> float:
	return current + book.get_pending()


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


func to_int() -> int:
	return int(get_value())


func is_zero() -> bool:
	return is_equal_to(ZERO)





func plus(_amount: float) -> float:
	return get_value() + _amount


func minus(_amount: float) -> float:
	return get_value() - _amount


func times(_amount: float) -> float:
	return get_value() * _amount


func divided_by(_amount: float) -> float:
	return get_value() / _amount


func to_the_power_of(_n: float) -> float:
	return pow(get_value(), _n)


func to_ceil() -> float:
	return ceilf(get_value())
