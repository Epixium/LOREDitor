@tool
class_name Main
extends Utility


signal checked_for_save
signal globals_done
signal prestiged

enum Tab{
	NONE, 
	UPGRADES, 
	CURRENCY_WATCHER_WINDOW, 
	MENU, 
	SETTINGS, 
	LOAD_MENU, 
	OFFLINE_EARNINGS, 
	DIFFICULTY_WINDOW, 
	SOURCE_CODE, 
}

const STAGE_2_ENABLED: bool = true
const STAGE_3_ENABLED: bool = false
const STAGE_4_ENABLED: bool = false

const APP_ID: String = "3418150"


static  var instance: Main
static  var done: = LoudBool.new(false)
static  var init_done: = LoudBool.new(false)
static  var prestiging: = false
static  var discord_working: = false

@export_group("Saved Variables")
@export var loreds: = {}
@export var currencies: = {}
@export var upgrades: = {}
@export var upgrade_trees: = {}
@export var stages: = {}
@export var scripted_emotes: = {}
@export var welcome_screen_viewed: = false
@export var thingies: = {}

@export var best_hands: Dictionary = {}

@export_group("")

var tab: = LoudInt.new()




@onready var tab_container: TabContainer = %TabContainer as TabContainer
@onready var intro_upgrades: VBoxContainer = %IntroUpgrades
@onready var margin_container: MarginContainer = %MarginContainer







func _init() -> void :
	if Engine.is_editor_hint():
		return
	Main.instance = self
	super ()

	init_done.set_true()

func _kill_stage_specific_nodes() -> void :
	if not STAGE_2_ENABLED:
		const GROUP_NAME: StringName = &"stage 2"
		for node: Node in get_tree().get_nodes_in_group(GROUP_NAME):
			node.queue_free()
	if not STAGE_3_ENABLED:
		const GROUP_NAME: StringName = &"stage 3"
		for node: Node in get_tree().get_nodes_in_group(GROUP_NAME):
			node.queue_free()
	if not STAGE_4_ENABLED:
		const GROUP_NAME: StringName = &"stage 4"
		for node: Node in get_tree().get_nodes_in_group(GROUP_NAME):
			node.queue_free()

static func get_color_from_string(x: String) -> Color:
	if x == "game":
		return game_color.get_value()

	if x.count(", ") == 2:

		var color_data: Array = x.split(", ")
		return Color(float(color_data[0]), float(color_data[1]), float(color_data[2]))

	if x.begins_with("#"):
		return Color.html(x)

	var split: = x.split(" ")
	
	match split[0]:
		_:
			printerr("Unknown 2nd word in color string: ", split[1], "(%s)" % x)
			return Color.WHITE


static func set_tab(val: int) -> void :
	if val == Tab.NONE:
		reset_tab()
		return
	if Main.DEMO:
		assert (val != Tab.SOURCE_CODE)
		if val == Tab.SOURCE_CODE:
			return
	instance.tab.set_to(val)
	instance.tab_container.show()


static func get_tab() -> int:
	return instance.tab.get_value()


static func reset_tab() -> void :
	instance.tab.reset()
	instance.tab_container.hide()

func dev() -> void :

	if not DEV_MODE:
		return
	super ()

func report_current_focus_owner_loop() -> void :
	while true:
		await one_second()
		var node: Node = get_viewport().gui_get_focus_owner()
		if node:
			printt(node.name)
		else:
			printt("(no focus)")

func _cache_lored_costs(_val: bool) -> void :
	if not Engine.is_editor_hint():
		return

	const PATH: String = "res://assets/LORED 3 Data.json"
	const LEVELS_TO_CACHE: int = 1000
	const PRICE_INCREASE: float = 3.0

	var file: = FileAccess.open(PATH, FileAccess.READ)
	var text: = file.get_as_text()
	var json: = JSON.new()
	json.parse(text)
	var data: Dictionary = json.data
	var lored_data: Dictionary = data.get("LOREDs")
	var lored_keys: Array[StringName]
	for key: String in lored_data.keys():
		if key == "":
			continue
		lored_keys.append(key)
	var start_time: = Time.get_unix_time_from_system()
	var costs: Dictionary[StringName, Dictionary]
	for key: StringName in lored_keys:
		var cost_string: String = lored_data[key]["Price"]
		var base_cost: Dictionary
		for x: String in cost_string.split(", "):
			var split: = x.split(" ")
			var amount: String = split[0]
			var currency_key: StringName = split[1]
			base_cost[currency_key] = amount
		var my_costs: Dictionary[int, Dictionary]
		for i: int in LEVELS_TO_CACHE:
			var my_cost_at_this_level: Dictionary[StringName, String]
			for currency_key: StringName in base_cost.keys():
				var big: = Big.multiply(base_cost[currency_key], Big.power(PRICE_INCREASE, i))
				my_cost_at_this_level[currency_key] = big.to_plain_scientific()
			my_costs[i] = my_cost_at_this_level
		costs[key] = my_costs

	print("LORED Prices cached in %s." % LoudTimer.format_time(Time.get_unix_time_from_system() - start_time))

	file = FileAccess.open_compressed("res://assets/LORED Cached Prices.txt", FileAccess.WRITE, FileAccess.COMPRESSION_DEFLATE)
	file.store_line(JSON.stringify(costs))
