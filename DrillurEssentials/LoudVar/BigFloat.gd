class_name BigFloat
extends LoudNumber


signal amount_increased(amount: Big)

@warning_ignore("unused_private_class_variable")
@export var saved_value: String
@export var saved_pending_value: String

var current: = Big.new(0)
var base: Big
var previous: Big
var cat: Variant
var custom_minimum_limit: Big:
	set = _set_minimum_limit
var custom_maximum_limit: Big:
	set = _set_maximum_limit
var save_pending: bool = false





func _init(x: Variant = 1.0) -> void :
	base = Big.new(x)
	current = Big.new(base)
	changed.connect(loud_number_init)
	book = Book.new(Book.Type.BIG)
	book.changed.connect(sync)
	book.pending_changed.connect(pending_changed.emit)








func _set_current(val: Big) -> void :
	previous = Big.new(current)
	if custom_maximum_limit:
		val = Big.get_min(val, custom_maximum_limit)
	if custom_minimum_limit:
		val = Big.get_max(val, custom_minimum_limit)
	if not current.is_equal_to(val):
		current.set_to(val)
		text_requires_update = true
	_emit_signals(previous, current)


func _set_minimum_limit(val: Big) -> void :
	custom_minimum_limit = val
	clamp_current()


func _set_maximum_limit(val: Big) -> void :
	custom_maximum_limit = val
	clamp_current()








func save(_save_pending_too: bool) -> void :
	save_pending = _save_pending_too
	save_current_value()


func save_current_value() -> void :
	saved_value = current.to_plain_scientific()
	if save_pending:
		saved_pending_value = book.get_pending().to_plain_scientific()


func load_saved_value() -> void :
	var _saved_value: = saved_value
	if not saved_value.is_empty():
		set_to(Big.new(_saved_value))


	if save_pending and not saved_pending_value.is_empty():
		plus_equals(Big.new(saved_pending_value))








func _emit_signals(previous_value: Big, current_value: Big) -> void :
	if not current_value.is_equal_to(previous_value):
		if previous_value.is_greater_than(current_value):
			decreased.emit()
		elif previous_value.is_less_than(current_value):
			increased.emit()
			amount_increased.emit(current_value.minus(previous_value))
		number_changed.emit(self)
		changed.emit()








func reset() -> void :
	current = Big.new(base)
	super ()


func set_to(amount: Variant) -> void :
	_set_current(Big.to_big(amount))


func plus_equals(amount: Variant) -> void :
	set_to(Big.add(current, amount))


func plus_equals_one() -> void :
	set_to(Big.add(current, LoudInt.ONE))


func minus_equals(amount: Variant) -> void :
	set_to(Big.subtract(current, amount))


func minus_equals_one() -> void :
	set_to(Big.subtract(current, LoudInt.ONE))


func times_equals(amount: Variant) -> void :
	set_to(Big.multiply(current, amount))


func divided_by_equals(amount: Variant) -> void :
	set_to(Big.divide(current, amount))


func sync() -> void :
	if book.sync_allowed.is_true():
		set_to(book.sync.call(base))


func clamp_current() -> void :
	if custom_maximum_limit:
		if current.is_greater_than(custom_maximum_limit):
			current = Big.new(custom_maximum_limit)
	if custom_minimum_limit:
		if current.is_less_than(custom_minimum_limit):
			current = Big.new(custom_minimum_limit)


func set_default_value(val: Variant) -> void :
	base = Big.new(val)


func set_default_value_and_reset(val: Variant) -> void :
	set_default_value(val)
	reset()


func copycat(_cat: Variant) -> void :
	cat = _cat
	set_default_value_and_reset(0.0)
	copy()
	cat.changed.connect(copy)


func copy() -> void :
	book.edit_change(Book.Category.ADDED, cat, cat.get_value())


func clear_copycat() -> void :
	cat.changed.disconnect(copy)
	cat = null


func update_text(_value = current) -> void :
	text_requires_update = false
	text = _value.get_text()








func get_value() -> Big:
	return current


func get_effective_value() -> Big:
	return Big.add(current, book.get_pending())


func get_text() -> String:
	if text_requires_update:
		update_text()
	return text


func get_pending() -> Big:
	return book.get_pending()


func get_pending_text() -> String:
	return get_pending().get_text()


func is_positive() -> bool:
	return current.is_positive()


func is_greater_than(val: Variant) -> bool:
	return not is_less_than_or_equal_to(val)


func is_greater_than_or_equal_to(val: Variant) -> bool:
	return not is_less_than(val)


func is_equal_to(val: Variant) -> bool:
	return current.is_equal_to(val)


func is_less_than_or_equal_to(val: Variant) -> bool:
	return is_less_than(val) or is_equal_to(val)


func is_less_than(val: Variant) -> bool:
	return current.is_less_than(val)


func is_zero() -> bool:
	return is_equal_to(Big.ZERO)
