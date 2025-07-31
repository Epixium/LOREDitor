extends Tree

var SAMPLE_TREE = {
	"thing1": {
		"subthing1": 30,
		"subthing2": 25,
	},
	"thing2": {},
	"thing3": {
		"subthing1": {
			"subsubthing1": {
				"subsubsubthing": 100,
				"boolval": true,
				"boolval2": false,
			}
		}
	}
}

var EDITABLE_TYPES = {
	"ENTER": {"id": 0, "icon": preload("res://enter_var.png")},
	"RESET": {"id": 1, "icon": preload("res://reset_var.png")},
}

var root
@export var SaveAlert : RichTextLabel = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = create_item()
	#create_tree_from_nested_dict(SAMPLE_TREE)
	button_clicked.connect(handle_editable)
	item_edited.connect(show_editable_button)

func create_tree_from_nested_dict(dict):
	create_layer_of_nested_tree(root, dict, dict, [])

func create_layer_of_nested_tree(layer, start_dict : Dictionary, input_dict : Dictionary, keypath : Array):
	var dict = input_dict.duplicate(true)
	for key in dict:
		var child = create_item(layer)
		child.set_collapsed(true)
		child.set_text(0, key)
		var value = dict[key]
		var new_path = keypath.duplicate()
		new_path.append(key)
		match typeof(value):
			Variant.Type.TYPE_DICTIONARY:
				create_layer_of_nested_tree(child, start_dict, value, new_path)
			Variant.Type.TYPE_BOOL:
				child.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
				child.set_checked(1, value)
				create_editables(child, start_dict, new_path, Variant.Type.TYPE_BOOL)
			var x:
				child.set_text(1, str(value))
				create_editables(child, start_dict, new_path, x)

func create_editables(item, dict, keypath, type):
	create_new_editable(EDITABLE_TYPES.ENTER, item, dict, keypath, type)
	create_new_editable(EDITABLE_TYPES.RESET, item, dict, keypath, type)
	item.set_metadata(1, {
		"dict": dict,
		"keypath": keypath,
		"type": type,
	})

func follow_keypath(dict : Dictionary, keypath : Array):
	var road = dict.duplicate(true)
	for step in keypath:
		road = road[step]
	return road

var tween : Tween

func handle_editable(treeitem : TreeItem, column, id, _mbi):
	var meta = treeitem.get_metadata(1)
	var replace = null
	match id:
		EDITABLE_TYPES.ENTER.id:
			match meta.type:
				Variant.Type.TYPE_BOOL:
					replace = treeitem.is_checked(1)
				Variant.Type.TYPE_INT:
					replace = int(treeitem.get_text(1))
					treeitem.set_text(1, str(replace))
				Variant.Type.TYPE_FLOAT:
					replace = float(treeitem.get_text(1))
					treeitem.set_text(1, str(replace))
				_:
					replace = treeitem.get_text(1)
			DictIO.manipulate_nested_dict(meta.dict, meta.keypath, 'write', replace, [])
			if tween: tween.stop()
			SaveAlert.text = "[wave amp=20.0 freq=6.0]Set value of " + "/".join(meta.keypath) + " to " + str(replace) + "![/wave]"
			SaveAlert.modulate = Color(1, 1, 1, 1)
			tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(SaveAlert, "modulate", Color(1, 1, 1, 0), 3)
			tween.play()
		EDITABLE_TYPES.RESET.id:
			var follow = follow_keypath(meta.dict, meta.keypath)
			match meta.type:
				Variant.Type.TYPE_BOOL:
					treeitem.set_checked(1, follow)
				_:
					treeitem.set_text(1, str(follow))
			if tween: tween.stop()
			SaveAlert.text = "[wave amp=20.0 freq=6.0]Reset value of " + "/".join(meta.keypath) + " to " + str(follow) + "![/wave]"
			SaveAlert.modulate = Color(1, 1, 1, 1)
			tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(SaveAlert, "modulate", Color(1, 1, 1, 0), 3)
			tween.play()
		_:
			pass
	treeitem.set_button_disabled(1, 0, true)
	treeitem.set_button_disabled(1, 1, true)
	

func create_new_editable(button_type : Dictionary, treeitem : TreeItem, dict : Dictionary, keypath : Array, type):
	treeitem.set_editable(1, true)
	treeitem.add_button(1, button_type.icon, button_type.id)
	treeitem.set_button_disabled(1, button_type.id, true)

func show_editable_button():
	var item = get_edited()
	var meta = item.get_metadata(1)
	var edited : bool = true
	match meta.type:
		Variant.Type.TYPE_BOOL:
			edited = follow_keypath(meta.dict, meta.keypath) != item.is_checked(1)
		Variant.Type.TYPE_INT:
			edited = follow_keypath(meta.dict, meta.keypath) != int(item.get_text(1))
		Variant.Type.TYPE_FLOAT:
			edited = follow_keypath(meta.dict, meta.keypath) != float(item.get_text(1))
		_:
			edited = follow_keypath(meta.dict, meta.keypath) != item.get_text(1)
	for i in range(2):
		item.set_button_disabled(1, i, !edited)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
