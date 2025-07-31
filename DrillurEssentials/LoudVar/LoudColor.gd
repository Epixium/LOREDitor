class_name LoudColor
extends Resource


signal changed_with_color(color)

@export var current: Color:
    set(val):
        if current != val:
            current = val
            emit_changed()
            changed_with_color.emit(val)

var base: Color





func _init(r: Variant = Color.WHITE, g: = 1.0, b: = 1.0, a: = 1.0) -> void :
    if r is Color:
        base = r
    else:
        base = Color(r, g, b, a)
    current = base








func set_to(val: Color) -> void :
    current = val


func set_default_value(val: Color) -> void :
    base = val


func reset() -> void :
    current = base


func subscribe_node(node: CanvasItem) -> void :
    var has_color: bool = node.get("color") != null
    var is_scroll_container: bool = node is ScrollContainer
    var is_tab_container: bool = node is TabContainer
    var update_color: = func():
        if has_color:
            node.color = get_value()
        elif is_scroll_container:
            node.get_v_scroll_bar().modulate = get_value()
        elif is_tab_container:
            const _NAME: String = "font_selected_color"
            node.add_theme_color_override(_NAME, get_value())
        else:
            node.modulate = get_value()
    node.tree_exiting.connect( func(): changed.disconnect(update_color))
    changed.connect(update_color)
    update_color.call()








func get_value() -> Color:
    return current








static func get_color_from_dict(_data: Dictionary) -> Color:
    return Color(
        _data.get("r", 1.0), 
        _data.get("g", 1.0), 
        _data.get("b", 1.0), 
        _data.get("a", 1.0), 
    )
