class_name LoudTexture2D
extends Resource


var base: Texture2D
var icon: Texture2D:
    set(val):
        if icon != val:
            icon = val
            changed.emit()



func _init(_base: = Texture2D.new()) -> void :
    base = _base
    icon = base






func reset() -> void :
    icon = base


func set_to(val: Texture2D) -> void :
    icon = val









func get_value() -> Texture2D:
    return icon


func get_icon() -> Texture2D:
    return icon
