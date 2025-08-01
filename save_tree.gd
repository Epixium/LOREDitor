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
				child.set_metadata(1, {"original_value" = value})
				create_editables(child, start_dict, new_path, Variant.Type.TYPE_BOOL)
			var x:
				child.set_text(1, str(value))
				child.set_metadata(1, {"original_value" = value})
				create_editables(child, start_dict, new_path, x)

var editables = []

func create_editables(item, dict, keypath, type):
	#editables.append(item)
	create_new_editable(EDITABLE_TYPES.ENTER, item, dict, keypath, type)
	create_new_editable(EDITABLE_TYPES.RESET, item, dict, keypath, type)
	item.set_metadata(1, {
		"dict": dict,
		"keypath": keypath,
		"type": type,
		"original_value": item.get_metadata(1).original_value,
	})

func follow_keypath(dict : Dictionary, keypath : Array):
	var road = dict.duplicate(true)
	for step in keypath:
		road = road[step]
	return road

var changes = []

func all_changes_saved():
	return changes.size() == 0

func save_change(treeitem):
	var meta = treeitem.get_metadata(1)
	var replace = null
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
	treeitem.set_button_disabled(1, 0, true)
	treeitem.set_button_disabled(1, 1, true)
	changes.erase(treeitem)
	return replace

func save_all_changes():
	var iterator = changes.duplicate()
	for item in iterator:
		save_change(item)
	SaveAlert.show_alert("Set value of " + str(changes.size()) + " variables!")

func reset_change(treeitem):
	var meta = treeitem.get_metadata(1)
	var follow = follow_keypath(meta.dict, meta.keypath)
	match meta.type:
		Variant.Type.TYPE_BOOL:
			treeitem.set_checked(1, follow)
		_:
			treeitem.set_text(1, str(follow))
	treeitem.set_button_disabled(1, 0, true)
	treeitem.set_button_disabled(1, 1, true)
	changes.erase(treeitem)
	return follow

func reset_all_changes():
	var iterator = changes.duplicate()
	for item in iterator:
		reset_change(item)
	SaveAlert.show_alert("Reset value of " + str(changes.size()) + " variables!")

func handle_editable(treeitem : TreeItem, column, id, _mbi):
	var meta = treeitem.get_metadata(1)
	match id:
		EDITABLE_TYPES.ENTER.id:
			SaveAlert.show_alert("Set value of " + "/".join(meta.keypath) + " to " + str(save_change(treeitem)) + "!")
		EDITABLE_TYPES.RESET.id:
			SaveAlert.show_alert("Reset value of " + "/".join(meta.keypath) + " to " + str(reset_change(treeitem)) + "!")
		_:
			pass

func create_new_editable(button_type : Dictionary, treeitem : TreeItem, dict : Dictionary, keypath : Array, type):
	treeitem.set_editable(1, true)
	treeitem.add_button(1, button_type.icon, button_type.id)
	treeitem.set_button_disabled(1, button_type.id, true)

var total_changes = []

func all_changes_default():
	return total_changes.size() == 0

func set_all_original_values():
	for item in total_changes:
		var meta = item.get_metadata(1)
		item.set_metadata(1, {
			"dict": meta.dict,
			"keypath": meta.keypath,
			"type": meta.type,
			"original_value": follow_keypath(meta.dict, meta.keypath),
		})
	total_changes = []

func show_editable_button():
	var item = get_edited()
	var meta = item.get_metadata(1)
	var edited : bool = true
	var new_value
	match meta.type:
		Variant.Type.TYPE_BOOL: new_value = item.is_checked(1)
		Variant.Type.TYPE_INT: new_value = int(item.get_text(1))
		Variant.Type.TYPE_FLOAT: new_value = float(item.get_text(1))
		_: new_value = item.get_text(1)
	edited = follow_keypath(meta.dict, meta.keypath) != new_value
	for i in range(2):
		item.set_button_disabled(1, i, !edited)
	if edited and item not in changes: changes.append(item)
	else: changes.erase(item)
	if new_value != meta.original_value: total_changes.append(item)
	else: total_changes.erase(item)
