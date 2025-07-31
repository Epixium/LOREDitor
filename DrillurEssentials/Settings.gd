extends Node


signal notation_changed

enum Notation{
	STANDARD, 
	SCIENTIFIC, 
	ENGINEERING, 
	LOGARITHMIC, 
	LETTERS, 
}
enum Resolution{
	_1920x1080, 
	_1920x1200, 
	_2048x1536, 
	_2160x1440, 
}

static  var done: = LoudBool.new(false)


@export var fullscreen: = LoudBool.new(false)
@export var resolution: = LoudInt.new(0)
@export var stretch_mode: = LoudBool.new(true)
@export var stretch_scale: = LoudFloat.new(1.0)
@export var display_fps: = LoudBool.new(false)
@export var max_fps: = LoudInt.new(240)


@export var audio_enabled: = LoudBool.new(true)
@export var master_volume: = LoudFloat.new(0.5)
@export var ui_volume: = LoudFloat.new(0.5)


@export var offline_earnings: = LoudBool.new(true)


@export var flying_texts: = LoudBool.new(true)
@export var critical_flying_texts: = LoudBool.new(false)
@export var consolidate_flying_texts: = LoudBool.new(false)
@export var play_animations: = LoudBool.new(true)
@export var play_bar_animations: = LoudBool.new(true)
@export var collapse_upgrades_when_purchased: = LoudBool.new(false)


@export var joypad_allowed: = LoudBool.new(true)

var previous_stretch_mode: bool
var joypad_detected: = LoudBool.new(false)

func _ready() -> void :
	get_viewport().focus_exited.connect(joypad_detected.set_false)
	done.set_true()
