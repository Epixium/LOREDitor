class_name LoudNumber
extends Resource


@warning_ignore("unused_signal")
signal pending_changed
@warning_ignore("unused_signal")
signal increased
@warning_ignore("unused_signal")
signal decreased
@warning_ignore("unused_signal")
signal number_changed(number)
signal text_changed

const MAX_INT: = 9223372036854775807
const MIN_INT: = -9223372036854775808
const MAX_FLOAT: = 1.79769e+308
const MIN_FLOAT: = -1.79769e+308
const STANDARD_SUFFIXES: PackedStringArray = [
	"", 
	"K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", 
	"Dc", "UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "OcDc", "NoDc", 
	"Vg", "UVg", "DVg", "TVg", "QaVg", "QiVg", "SxVg", "SpVg", "OcVg", "NoVg", 
	"Tg", "UTg", "DTg", "TTg", "QaTg", "QiTg", "SxTg", "SpTg", "OcTg", "NoTg", 
]
const LETTER_SUFFIXES: PackedStringArray = [
	"", 
	"K", "a", "b", "c", "d", "e", "f", "g", "h", "i", 
	"j", "k", "l", "m", "n", "o", "p", "q", "r", "s", 
	"t", "u", "v", "w", "x", "y", "z", "aa", "ab", "ac", 
	"ad", "ae", "af", "ag", "ah", "ai", "aj", "ak", "al", "am", 
	"an", "ao", "ap", "aq", "ar", "as", "at", "au", "av", "aw", 
	"ax", "ay", "az", "ba", "bb", "bc", "bd", "be", "bf", "bg", 
	"bh", "bi", "bj", "bk", "bl", "bm", "bn", "bo", "bp", "bq", 
	"br", "bs", "bt", "bu", "bv", "bw", "bx", "by", "bz", "ca", 
	"cb", "cc", "cd", "ce", "cf", "cg", "ch", "ci", "cj", "ck", 
	"cl", "cm", "cn", "co", "cp", "cq", "cr", "cs", "ct", "cu", 
]


var book: Book
var copycat_num: LoudNumber
var initialized: = false

var text: String
var text_requires_update: = true:
	set = _set_text_requires_update





func loud_number_init() -> void :
	if initialized:
		return
	initialized = true
	changed.disconnect(loud_number_init)








func _set_text_requires_update(val: bool) -> void :
	if text_requires_update == val:
		return
	text_requires_update = val
	if val:
		text_changed.emit()








func update_text(value) -> void :
	text_requires_update = false
	text = format_number(value)


func reset() -> void :
	book.reset()


func is_copycat() -> bool:
	return copycat_num != null





func edit_change(category: Book.Category, source, amount) -> void :
	book.edit_change(category, source, amount)


func edit_added(source: Variant, amount: Variant) -> void :
	edit_change(Book.Category.ADDED, source, amount)


func edit_subtracted(source: Variant, amount: Variant) -> void :
	edit_change(Book.Category.SUBTRACTED, source, amount)


func edit_multiplied(source: Variant, amount: Variant) -> void :
	edit_change(Book.Category.MULTIPLIED, source, amount)


func edit_divided(source: Variant, amount: Variant) -> void :
	edit_change(Book.Category.DIVIDED, source, amount)


func edit_pending(source, _amount) -> void :
	edit_change(Book.Category.PENDING, source, _amount)


func remove_change(category: Book.Category, source) -> void :
	book.remove_change(category, source)


func remove_added(source) -> void :
	remove_change(Book.Category.ADDED, source)


func remove_subtracted(source) -> void :
	remove_change(Book.Category.SUBTRACTED, source)


func remove_multiplied(source) -> void :
	remove_change(Book.Category.MULTIPLIED, source)


func remove_divided(source) -> void :
	remove_change(Book.Category.DIVIDED, source)


func remove_pending(source: Variant) -> void :
	remove_change(Book.Category.PENDING, source)











func copycat(cat: Resource) -> void :
	copycat_num = cat
	copycat_num.changed.connect(copycat_changed)
	copycat_changed()


func copycat_changed() -> void :
	book.edit_change(Book.Category.ADDED, copycat_num, copycat_num.get_value())


func clear_copycat() -> void :
	copycat_num.changed.disconnect(copycat_changed)
	copycat_num = null





















static func format_number(value: Variant, override_decimals: int = -1) -> String:
	if is_zero_approx(value):
		return "0"

	var _sign: = signf(value)
	value = abs(value)
	var floored_value: int = floori(value)
	var result: String

	if floored_value >= 100000:
		var index: int = 1
		value /= 1000
		while value >= 1000:
			value /= 1000
			index += 1
		var suffix: String = STANDARD_SUFFIXES[index]
		result = "%s%s" % [String.num(floorf(value) * _sign, 0), suffix]
		return result

	elif floored_value >= 1000:
		var output: = ""
		var i: int = value
		var sign_text: String = "-" if _sign < 0 else ""
		while i >= 1000:
			output = ",%03d%s" % [i % 1000, output]
			i /= 1000
		result = "%s%s%s" % [sign_text, i, output]
		return result

	if value is int:
		result = str(value * _sign).pad_decimals(0)
		return result

	var floor_log: = floori(Big.log10(value))


	if floor_log <= -6:
		return "0"

	if is_equal_approx(value, int(value)):
		result = String.num(value * _sign, 0)
		return result

	var decimals: int = (
		override_decimals if override_decimals >= 0 else
		0 if floor_log >= 1 else
		absi(floor_log) + 2
	)

	if decimals == 0:
		value = roundf(value)

	result = String.num(value * _sign, decimals)
	return result


static func format_percent(value: float) -> String:

	if value < 0.0:
		return "What the fuck did you do%"
	if is_zero_approx(value):
		return "0%"
	value *= 100
	var _text = "%s%%"
	var floor_log: = floori(log(value) / log(10))

	if floor_log <= -10:
		return "0%"

	var decimals: int
	match floor_log:
		1, 2:
			decimals = 0
			value = roundf(value)
		0:
			decimals = 1
		_:
			decimals = absi(floor_log) + 1

	return _text % str(value).pad_decimals(decimals)


static func format_distance(distance: int) -> String:
	if distance < 1000:
		return str(distance) + "m"
	var kilometers: = float(distance) / 1000
	if kilometers < 1000:
		if kilometers < 10:
			return str(kilometers).pad_decimals(1) + "km"
		return str(ceilf(kilometers)) + "km"
	var megameters: = kilometers / 1000
	if megameters < 1000:
		if megameters < 10:
			return str(megameters).pad_decimals(1) + "Mm"
		return str(ceilf(megameters)) + "Mm"
	return "What the fuck meters"


static func factorial(n: int) -> int:
	if n <= 1:
		return 1
	var result: = n
	for x in range(n - 1, 1, -1):
		result *= x
	return result


static func binomial_coefficient(n: int, k: int) -> float:
	return float(factorial(n)) / (factorial(k) * factorial(n - k))
