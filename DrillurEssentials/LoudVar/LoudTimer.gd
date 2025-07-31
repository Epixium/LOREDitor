class_name LoudTimer
extends RefCounted


signal timeout
signal started
signal stopped
signal timed_out_or_stopped
signal duration_elapsed_when_stopped(duration)

const MINIMUM_DURATION: float = 0.05

const ONE_MINUTE: int = 60
const ONE_HOUR: int = 3600
const ONE_DAY: int = 86400
const ONE_YEAR: int = 31536000

var random: bool
var ready: = LoudBool.new(false)
var running: = LoudBool.new(false)
var timer: = Timer.new()
var wait_time: LoudFloat
var wait_time_range: LoudFloatPair

func _init(_wait_time: = 0.0, optional_maximum_duration: = 0.0) -> void :
	if optional_maximum_duration > 0.0:
		wait_time_range = LoudFloatPair.new(_wait_time, optional_maximum_duration)
		wait_time = LoudFloat.new(0.0)
		random = true
	else:
		wait_time = LoudFloat.new(_wait_time)
	wait_time.custom_minimum_limit = LoudTimer.MINIMUM_DURATION

	timer.one_shot = true

	if not timer.is_node_ready():
		timer.ready.connect(ready.set_true)

	started.connect(running.set_true)
	timed_out_or_stopped.connect(running.set_false)
	timer.timeout.connect(timer_timeout)

	wait_time.changed.connect(restart_with_new_wait_time)








class TimeUnit:
	enum Type{
		SECOND, 
		MINUTE, 
		HOUR, 
		DAY, 
		YEAR, 
		DECADE, 
		CENTURY, 
		MILLENIUM, 
		EON, 
		QUETTASECOND, 
		BLACK_HOLE, 
	}
	const DIVISION: = {
		Type.SECOND: 60, 
		Type.MINUTE: 60, 
		Type.HOUR: 24, 
		Type.DAY: 365, 
		Type.YEAR: 10, 
		Type.DECADE: 10, 
		Type.CENTURY: 10, 
		Type.MILLENIUM: "1e6", 
		Type.EON: "3.1e13", 
		Type.QUETTASECOND: "6e43", 
		Type.BLACK_HOLE: 1, 
	}
	const WORD: = {
		Type.SECOND: {"SINGULAR": "second", "PLURAL": "seconds", "SHORT": "s"}, 
		Type.MINUTE: {"SINGULAR": "minute", "PLURAL": "minutes", "SHORT": "m"}, 
		Type.HOUR: {"SINGULAR": "hour", "PLURAL": "hours", "SHORT": "h"}, 
		Type.DAY: {"SINGULAR": "day", "PLURAL": "days", "SHORT": "d"}, 
		Type.YEAR: {"SINGULAR": "year", "PLURAL": "years", "SHORT": "y"}, 
		Type.DECADE: {"SINGULAR": "decade", "PLURAL": "decades", "SHORT": "dec"}, 
		Type.CENTURY: {"SINGULAR": "century", "PLURAL": "centuries", "SHORT": "cen"}, 
		Type.MILLENIUM: {"SINGULAR": "millenium", "PLURAL": "millenia", "SHORT": "mil"}, 
		Type.EON: {"SINGULAR": "eon", "PLURAL": "eons", "SHORT": "eon"}, 
		Type.QUETTASECOND: {"SINGULAR": "quettasecond", "PLURAL": "quettaseconds", "SHORT": "qs"}, 
		Type.BLACK_HOLE: {"SINGULAR": "black hole life span", "PLURAL": "consecutive black hole life spans", "SHORT": "bh"}, 
	}

	static func get_text(amount: Big, brief: bool) -> String:
		var type = Type.SECOND
		while type < Type.size() - 1:
			var division = Big.new(DIVISION[type])
			if amount.is_less_than(division):
				break
			amount.divided_by_equals(division)
			type = Type.values()[type + 1]
		var result: String = Big.round_down(amount).get_text()
		if brief:
			return result + " " + WORD[type]["SHORT"]
		return result + " " + unit_text(type, amount)

	static func unit_text(type: int, amount: Big) -> String:
		if amount.is_equal_to(1):
			return WORD[type]["SINGULAR"]
		return WORD[type]["PLURAL"]


static func format_time(seconds: float) -> String:
	if is_zero_approx(seconds):
		return "0s"
	if seconds >= ONE_HOUR:

		var time_dict = get_time_dict(int(seconds))
		return get_time_text_from_dict(time_dict)
	if seconds < ONE_MINUTE:
		if seconds < 10:
			return str(seconds).pad_decimals(2) + "s"
		return str(seconds).pad_decimals(0) + "s"
	seconds /= ONE_MINUTE
	return LoudNumber.format_number(seconds) + "m"


static func get_time_dict(time: int) -> Dictionary[StringName, float]:
	const BASE: Dictionary[StringName, float] = {
		&"days": 0, 
		&"years": 0, 
		&"hours": 0, 
		&"minutes": 0, 
		&"seconds": 0, 
	}
	var result: Dictionary[StringName, float] = BASE.duplicate()
	if time >= ONE_YEAR:
		result[&"years"] = float(time) / ONE_YEAR
		time = time % ONE_YEAR
	if time >= ONE_DAY:
		result[&"days"] = float(time) / ONE_DAY
		time = time % ONE_DAY
	if time >= ONE_HOUR:
		result[&"hours"] = float(time) / ONE_HOUR
		time = time % ONE_HOUR
	if time >= ONE_MINUTE:
		result[&"minutes"] = float(time) / ONE_MINUTE
		time = time % ONE_MINUTE
	result[&"seconds"] = float(time)
	return result


static func get_time_text_from_dict(dict: Dictionary) -> String:
	var years: int = dict.get(&"years", 0)
	var days: int = dict.get(&"days", 0)
	var hours: int = dict.get(&"hours", 0)
	var minutes: int = dict.get(&"minutes", 0)
	var seconds: int = dict.get(&"seconds", 0)
	var texts: = []
	if years > 0:
		texts.append("%sy" % years)
	if days > 0:
		texts.append("%sd" % days)
	if hours > 0:
		texts.append("%sh" % hours)
	if minutes > 0:
		texts.append("%sm" % minutes)
	if seconds > 0:
		texts.append("%ss" % seconds)
	return Main.get_list_text_from_array(texts)


static func format_big_time(time: Big) -> String:
	time = Big.new(time)
	if time.is_less_than(Big.SIXTY):
		return format_time(time.to_float())
	return TimeUnit.get_text(time, false)








func timer_timeout() -> void :
	timed_out_or_stopped.emit()
	timeout.emit()


func sync_wait_times() -> void :
	if are_wait_times_equal():
		return
	if wait_time.get_value() == 0:
		print_debug("Yeah don\'t let this happen!")
		return
	timer.wait_time = wait_time.get_value()








func are_wait_times_equal() -> bool:
	return wait_time.get_value() == timer.wait_time


func _timer_ready() -> void :
	if ready.is_true():
		return
	await ready.became_true








func start() -> void :
	await _timer_ready()
	if random:
		wait_time.edit_change(Book.Category.ADDED, wait_time_range, wait_time_range.get_random_point())
	if not are_wait_times_equal():
		sync_wait_times()
	timer.start()
	started.emit()


func stop() -> void :
	await _timer_ready()
	if is_stopped():
		return
	if not is_instance_valid(timer):
		return
	duration_elapsed_when_stopped.emit(timer.wait_time - timer.time_left)
	timer.stop()
	timed_out_or_stopped.emit()
	stopped.emit()


func restart_with_new_wait_time() -> void :
	if is_stopped():
		return
	await _timer_ready()
	var percent_progress: = get_time_left() / timer.wait_time
	stop()
	timer.start(wait_time.get_value() * percent_progress)
	sync_wait_times()


func restart() -> void :
	await _timer_ready()
	var previous_wait_time: float = timer.wait_time
	var time_elapsed: = get_time_elapsed()
	stop()
	timer.start(previous_wait_time - time_elapsed)
	sync_wait_times()


func pause() -> void :
	if timer.paused:
		return
	await _timer_ready()
	timer.set_paused(true)
	running.set_false()


func resume() -> void :
	if not timer.paused:
		return
	await _timer_ready()
	timer.set_paused(false)
	running.set_true()


func set_wait_time(value: float) -> void :
	wait_time.set_to(maxf(value, MINIMUM_DURATION))


func set_minimum_duration(value: float) -> void :
	wait_time_range.current.set_to(value)
	random = true


func set_maximum_duration(value: float) -> void :
	wait_time_range.total.set_to(value)
	random = true


func edit_divided(source, value: float) -> void :
	wait_time.edit_change(Book.Category.DIVIDED, source, value)


func edit_multiplied(source, value: float) -> void :
	wait_time.edit_change(Book.Category.MULTIPLIED, source, value)


func enable_looping() -> void :
	if not timeout.is_connected(start):
		timeout.connect(start)


func stop_loop() -> void :
	if timeout.is_connected(start):
		timeout.disconnect(start)








func get_wait_time() -> float:
	return wait_time.get_value()


func get_time_left() -> float:
	return timer.time_left


func get_time_elapsed() -> float:
	if is_running():
		return timer.wait_time - get_time_left()
	return 0.0


func get_percent() -> float:
	return 1.0 - (get_time_left() / timer.wait_time)


func get_inverted_percent() -> float:
	return get_time_left() / timer.wait_time


func is_stopped() -> bool:
	return running.is_false()


func is_running() -> bool:
	return not is_stopped()


func get_wait_time_text() -> String:
	return LoudTimer.format_time(get_wait_time())


func get_time_left_text() -> String:
	return LoudTimer.format_time(get_time_left())


func get_time_elapsed_text() -> String:
	return LoudTimer.format_time(get_time_elapsed())


func get_text() -> String:
	return "%s/%s" % [
		LoudNumber.format_number(get_time_elapsed()), 
		get_wait_time_text()
	]


func get_average_duration() -> float:
	if random:
		return wait_time_range.get_midpoint() * wait_time.get_value()
	return wait_time.get_value()


func get_maximum_duration() -> float:
	if random:
		return wait_time_range.get_total() * wait_time.get_value()
	return wait_time.get_value()
