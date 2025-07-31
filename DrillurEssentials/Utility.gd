class_name Utility
extends Node


signal _one_second
signal _physics_frame
signal _process_frame
signal unfocused_duration(time_away: float)

enum Platform{
	PC, BROWSER, 
}
enum AudioLayer{
	Master, Ui, 
}

const DEV_MODE: = false
const DEMO: bool = false
const TEST: bool = true
const PLATFORM: Platform = Platform.PC

const MINIMUM_FPS: = 60
const OPTIMAL_FPS: = 165
const SCROLL_SPEED: int = 25
const ICON_HEIGHT: int = 16

static  var rng: = RandomNumberGenerator.new()
static  var class_data: Dictionary
static  var viewport: Viewport
static  var window: Window
static  var holding_rt: = LoudBool.new()
static  var game_color: = LoudColor.new(1, 0, 0.235)

static  var discord_details_cooldown: = LoudInt.new(0)

@export_group("Saved Variables")
@export var current_clock: float = Time.get_unix_time_from_system()
@export var total_duration_played: LoudInt
@export var times_played: LoudInt
@export var events: Dictionary
@export var window_position_x: float
@export var window_position_y: float
@export var window_size_x: float
@export var window_size_y: float
@export_group("")

var blur_tween: Tween
var time_left_game: float
var game_has_focus: = LoudBool.new(true)
var audio_stream_players: Array[AudioStreamPlayer]



@onready var blur_texture_rect: TextureRect = %Blur
@onready var blur_material: ShaderMaterial = blur_texture_rect.material







func _init() -> void :
	discord_details_cooldown.custom_minimum_limit = 0
	for x in ProjectSettings.get_global_class_list():
		class_data[x["class"]] = x["path"]


func _ready() -> void :
	viewport = get_viewport()
	window = viewport.get_window()
	times_played = LoudInt.new()
	session_tracker()
	get_tree().physics_frame.connect(_physics_frame.emit)
	get_tree().process_frame.connect(_process_frame.emit)
	unblur()
	_ready_kill_non_demo_elements()
	_ready_subscribe_all_nodes_to_game_color()
	_one_second.connect(discord_details_cooldown.minus_equals_one)
	setup_audio_stream_players()
	set_physics_process(false)
	setup_dev()

func update_window_rect() -> void :
	window_position_x = window.position.x
	window_position_y = window.position.y
	window_size_x = window.size.x
	window_size_y = window.size.y


func _ready_subscribe_all_nodes_to_game_color() -> void :
	await Main.done.became_true
	for node in get_tree().get_nodes_in_group("game_color"):
		game_color.subscribe_node(node)


func _ready_kill_non_demo_elements() -> void :
	if DEMO:
		for node: Node in get_tree().get_nodes_in_group(&"non_demo_elements"):
			node.queue_free()

func setup_audio_stream_players() -> void :
	for i: int in range(1, 33):
		var player: AudioStreamPlayer = get_node("%AudioStreamPlayer" + str(i))
		player.finished.connect( func(): audio_stream_players.append(player))
		audio_stream_players.append(player)








func _notification(what: int) -> void :
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		time_left_game = Time.get_unix_time_from_system()
		game_has_focus.set_false()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		var current_time: float = Time.get_unix_time_from_system()
		var time_away: float = current_time - current_clock
		if time_away > 1:
			unfocused_duration.emit(time_away)
		game_has_focus.set_true()








static func set_input_as_handled() -> void :
	viewport.set_input_as_handled()


static func get_list_text_from_array(arr: Array) -> String:
	var text: = ""
	var size = arr.size()
	var i = 0
	while size >= 1:
		text += arr[i]
		if size >= 3:
			text += ", "
		elif size >= 2 and arr.size() >= 3:
			text += ", and "
		elif size >= 2:
			text += " and "
		size -= 1
		i += 1
	return text


static func get_random_color() -> Color:
	return Color(
		randf(), 
		randf(), 
		randf(), 
		1.0
	)


static func get_random_bright_color() -> Color:
	return validate_color_brightness(get_random_color())


static func get_random_dark_color() -> Color:
	return validate_color_darkness(get_random_color())


static func validate_color_brightness(color: Color, minimum: = 1.0) -> Color:
	if color.r + color.g + color.b == LoudFloat.ZERO:
		color.r = minimum / 3 + 0.01
		color.r = minimum / 3 + 0.01
		color.r = minimum / 3 + 0.01
	while color.r + color.g + color.b < minimum:
		color.r *= 1.1
		color.g *= 1.1
		color.b *= 1.1
	return color


static func validate_color_darkness(color: Color, limit: = 1.0) -> Color:
	while color.r + color.g + color.b > limit:
		color.r /= 1.1
		color.g /= 1.1
		color.b /= 1.1
	return color


static func modulate_node_to_ensure_readability(node: Control, limit: = 1.75, color: Color = node.modulate) -> void :
	if color.r + color.g + color.b >= limit:
		node.modulate = Color(0.2, 0.2, 0.2)


static func node_has_point(node: Node, point: Vector2) -> bool:
	return node.get_global_rect().has_point(point)


static func get_random_point_in_rect(rect: Rect2) -> Vector2:
	return Vector2(
		rect.position.x + (randf() * rect.size.x), 
		rect.position.y + (randf() * rect.size.y)
	)


static func get_script_variables(script: Script) -> Array[String]:
	const ALLOWED_USAGES: Array[int] = [
		PROPERTY_USAGE_SCRIPT_VARIABLE, 
		4102
	]
	var variable_names: Array[String] = []
	for property in script.get_script_property_list():
		if ALLOWED_USAGES.has(property.usage):
			variable_names.append(property.name)
	return variable_names


static func report(object: Object, max_depth: = 1) -> void :
	if not Main.DEV_MODE:
		return
	var _class_name: String = object.get_class()
	printt("Report:", _class_name, object)
	print(get_object_report_text(object, 1, max_depth))


static func get_object_report_text(object: Object, depth: int, max_depth: int) -> String:
	if depth > max_depth:
		return str(object)
	if object.get_script() == null:
		return ""
	var vars: = get_script_variables(object.get_script())
	var text: String = ""
	for x in vars:
		if x == "_class_name":
			continue

		text += "\n"
		for i in depth:
			text += "-\t"
		text += x + ": "

		if object.get(x) is LoudBool or object.get(x) is LoudColor:
			text += str(object.get(x).get_value())
		elif object.get(x) is LoudNumber:
			text += get_object_report_text(object.get(x), depth + 1, max_depth)
		elif object.get(x) is Object:
			if object.get(x).has_method("get_text"):
				text += object.get(x).get_text()
			else:
				text += get_object_report_text(object.get(x), depth + 1, max_depth)
		elif object.get(x) is Dictionary:
			for y in object.get(x):
				text += "\n"
				for i in depth + 1:
					text += "-\t"
				text += str(y) + ": "
				text += get_object_report_text(object.get(x)[y], depth + 1, max_depth)
		elif typeof(object.get(x)) == TYPE_ARRAY:
			for y in object.get(x):
				if y is Object:
					text += get_object_report_text(y, depth + 1, max_depth)
				else:
					text += "\n"
					for i in depth + 1:
						text += "-\t"
					text += str(y)
		else:
			text += str(object.get(x))
	return text


static func get_formatted_json_text(original: String) -> String:
	var new: = original
	new = new.replace("; ", ";")
	new = new.replace("\n", "")
	new = new.replace(", ", ",")
	return new


static func get_json_array(text: String) -> Array[Dictionary]:

	text = get_formatted_json_text(text)
	var sections: Array = text.split(";")
	var array: Array[Dictionary]
	for x in sections:
		if x == "":

			continue
		var dict: Dictionary
		var sub_section: Array = x.split(",")


		if sub_section[0].contains(":"):

			var split: Array = sub_section[0].split(":")
			dict[split[0]] = split[1]
		else:
			dict["key"] = sub_section[0]


		for n in range(1, sub_section.size()):
			var split: Array = sub_section[n].split(":")
			dict[split[0]] = split[1]

		array.append(dict)

	return array


static func blur_upon_node_visibility_changed(node: CanvasItem) -> void :
	node.visibility_changed.connect(
		func() -> void :
			if node.visible:
				blur()
			else:
				unblur()
	)


static func blur() -> void :
	var me: Main = Main.instance
	if me.blur_tween:
		me.blur_tween.kill()
	me.blur_texture_rect.show()
	me.blur_tween = me.create_tween()
	me.blur_material.set("shader_parameter/amount", 0.0)
	me.blur_tween.tween_property(me.blur_material, "shader_parameter/amount", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	me.blur_tween.finished.connect(me.blur_tween.kill)


static func unblur() -> void :
	var me: Main = Main.instance
	if me.blur_tween:
		me.blur_tween.kill()
	me.blur_texture_rect.hide()


static func load_file_at_path(_path: String, _await_physics: = false) -> ResourceLoader.ThreadLoadStatus:



	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_path)
	while load_status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		if _await_physics:
			await Main.physics_frame()
		else:
			await timer(0.1)
		load_status = ResourceLoader.load_threaded_get_status(_path)
		match load_status:
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				printerr("ResourceLoader THREAD_LOAD_FAILED. Path: " + _path)
				return load_status
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:

				ResourceLoader.load_threaded_request(_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	return load_status


static func get_class_path(_class_key: String) -> String:
	return class_data.get(_class_key, "")

static func is_a_alphabetically_higher_than_b(a: String, b: String) -> bool:
	return a.naturalnocasecmp_to(b) < 0


static func get_sum_of_int_array(array: Array[int]) -> int:
	var sum: = func(_accum: int, _value: int):
		return _accum + _value
	return array.reduce(sum)


static func get_red_to_green_color_from_percent(percent: float) -> Color:
	var r: float = minf(2 - (percent / 0.5), 1.0)
	var g: float = minf(percent / 0.5, 1.0)
	return Color(r, g, 0.0)


static func kill_tween(tween: Tween) -> void :
	if tween and tween.is_running():
		tween.kill()





static func timer(time: float) -> void :
	await Main.instance.get_tree().create_timer(time).timeout


static func physics_frame(_count: int = 1) -> void :
	assert (_count >= 1, "What the hell you think y\'er doin, boy?")
	if Engine.is_editor_hint():
		return
	for __ in _count:
		await Main.instance._physics_frame


static func process_frame(_count: int = 1) -> void :
	assert (_count >= 1, "You plum sonnuva beitch!")
	if Engine.is_editor_hint():
		return
	for __ in _count:
		await Main.instance._process_frame


static func one_second(_count: int = 1) -> void :
	assert (_count >= 1, "What in gawt-daymed tarnation?!")
	if Engine.is_editor_hint():
		return
	for __ in _count:
		await Main.instance._one_second











static func play_audio(audio: AudioStream, layer: AudioLayer) -> void :
	if (
		Main.instance.audio_stream_players.is_empty() or 
		Main.done.is_false() or 
		audio == null
	):
		return
	var player: AudioStreamPlayer = Main.instance.get_audio_player()
	player.stream = audio
	player.pitch_scale = randf_range(0.9, 1.1)
	player.bus = AudioLayer.keys()[layer]
	player.volume_db = AudioServer.get_bus_volume_db(layer)
	player.play()


func get_audio_player() -> AudioStreamPlayer:
	return audio_stream_players.pop_back()








@export_group("Dev")
@export var editor_button: = false:
	set = _editor_button_clicked
@export var btn_calculate: bool:
	set = _calc_shit
@export var start: float = 1.0
@export var end: float = 5.0
@export var intervals: int = 3
@export var resulting_multiplier: String = ""
@export_group("")


func _calc_shit(_val: bool) -> void :
	if not Engine.is_editor_hint():
		return
	var big: = Big.new("100e3")
	for x in 50:
		print(big.to_letters_notation())
		big.times_equals(100)
	calculate_log_scale(start, end, intervals)


func calculate_log_scale(_start: float, _end: float, _intervals: int) -> void :
	if _start >= _end:
		print("Start >= end. u trying to break a dev tool, fucker? ur cooked")
		return
	var multiplier: = nth_root(_start, _end, _intervals)
	resulting_multiplier = str(multiplier)
	var sequence: = [_start]
	var current: = _start
	for x in range(1, _intervals + 1):
		current *= multiplier
		var value: = snappedf(current, 0.01)
		sequence.append(value)
	printt(
		"%s to %s over %s intervals (multiplier of %s)\n\t" % [
			LoudNumber.format_number(_start), 
			LoudNumber.format_number(_end), 
			str(_intervals), 
			LoudNumber.format_number(multiplier)
		], 
		sequence
	)


static func nth_root(_start: float, _end: float, _intervals: int) -> float:
	return pow((_end / _start), 1.0 / _intervals)

func session_tracker() -> void :
	total_duration_played = LoudInt.new(LoudInt.ZERO)
	if Engine.is_editor_hint():
		return
	await Main.instance.done.became_true
	var t: = Timer.new()
	t.one_shot = false
	t.wait_time = 1
	add_child(t)
	t.timeout.connect(_second_passed)
	t.start()


func _second_passed() -> void :
	current_clock = Time.get_unix_time_from_system()
	total_duration_played.plus_equals_one()
	_one_second.emit()

func _unhandled_key_input(event: InputEvent) -> void :
	if event.is_action_pressed(&"dev") and DEV_MODE:
		set_input_as_handled()
		dev()


func _physics_process(_delta: float) -> void :
	if Engine.is_editor_hint():
		return
	if holding_rt.is_true():
		if not Input.is_action_pressed(&"joy_rt"):
			holding_rt.set_false()

func setup_dev() -> void :
	dev()


func _editor_button_clicked(_val: bool) -> void :
	if not Engine.is_editor_hint():
		return
	dev()


func dev() -> void :
	if not DEV_MODE:
		return
