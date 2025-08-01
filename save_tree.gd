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

enum VAR_CATEGORIES {
	DEFAULT,
	UPGRADE,
}

var EDITABLE_TYPES = {
	"ENTER": {"id": 0, "icon": preload("res://enter_var.png")},
	"RESET": {"id": 1, "icon": preload("res://reset_var.png")},
	"UPGRADE_SET": {"id": 0, "icon": preload("res://set_upgrade_level.png")},
	"ARCADE_UPGRADE_SET": {"id": 1, "icon": preload("res://set_arcade_upgrade_level.png")},
}

var root
@export var SaveAlert : RichTextLabel = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = create_item()
	#create_tree_from_nested_dict(SAMPLE_TREE)
	button_clicked.connect(handle_editable)
	item_edited.connect(show_editable_button)

func get_child_from_key(item : TreeItem, key):
	var children = item.get_children()
	for child in children:
		if child.get_text(0) == key: return child
	return null

func create_tree_from_nested_dict(dict):
	create_layer_of_nested_tree(root, dict, dict, [], VAR_CATEGORIES.DEFAULT)

func create_layer_of_nested_tree(layer : TreeItem, start_dict : Dictionary, input_dict : Dictionary, keypath : Array, category : VAR_CATEGORIES):
	var dict = input_dict.duplicate(true)
	var index_dict = {}
	var i = 0
	for key in dict:
		index_dict[key] = i
		i += 1
		var child = create_item(layer)
		child.set_collapsed(true)
		child.set_text(0, key)
		var value = dict[key]
		var new_path = keypath.duplicate()
		new_path.append(key)
		match typeof(value):
			Variant.Type.TYPE_DICTIONARY:
				var varcat = VAR_CATEGORIES.DEFAULT
				match layer.get_text(0):
					"upgrades": varcat = VAR_CATEGORIES.UPGRADE
					_: pass
				create_metadata(child, start_dict, new_path, Variant.Type.TYPE_DICTIONARY, value, VAR_CATEGORIES.UPGRADE)
				create_layer_of_nested_tree(child, start_dict, value, new_path, varcat)
			Variant.Type.TYPE_BOOL:
				child.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
				child.set_checked(1, value)
				create_editables(child, start_dict, new_path, Variant.Type.TYPE_BOOL, value, VAR_CATEGORIES.DEFAULT)
			var x:
				child.set_text(1, str(value))
				create_editables(child, start_dict, new_path, x, value, VAR_CATEGORIES.DEFAULT)
	match category:
		VAR_CATEGORIES.UPGRADE:
			setup_upgrade_branch(layer, index_dict)
		_: pass

var editables = []

func create_new_editable(button_type : Dictionary, item : TreeItem, dict : Dictionary, keypath : Array, type):
	item.set_editable(1, true)
	item.add_button(1, button_type.icon, button_type.id)
	item.set_button_disabled(1, button_type.id, true)

func create_editables(item, dict, keypath, type, original_value, category):
	var meta = item.get_metadata(1)
	create_new_editable(EDITABLE_TYPES.ENTER, item, dict, keypath, type)
	create_new_editable(EDITABLE_TYPES.RESET, item, dict, keypath, type)
	create_metadata(item, dict, keypath, type, original_value, category)

func create_metadata(item, dict, keypath, type, original_value, category):
	item.set_metadata(1, {
		"dict": dict,
		"keypath": keypath,
		"type": type,
		"original_value": original_value,
		"category": category,
	})

func follow_keypath(dict : Dictionary, keypath : Array):
	var road = dict.duplicate(true)
	for step in keypath:
		road = road[step]
	return road

var changes = []

func all_changes_saved():
	return changes.size() == 0

func save_change(item):
	var meta = item.get_metadata(1)
	var replace = null
	match meta.type:
		Variant.Type.TYPE_BOOL:
			replace = item.is_checked(1)
		Variant.Type.TYPE_INT:
			replace = int(item.get_text(1))
			item.set_text(1, str(replace))
		Variant.Type.TYPE_FLOAT:
			replace = float(item.get_text(1))
			item.set_text(1, str(replace))
		_:
			replace = item.get_text(1)
	DictIO.manipulate_nested_dict(meta.dict, meta.keypath, 'write', replace, [])
	item.set_button_disabled(1, 0, true)
	item.set_button_disabled(1, 1, true)
	changes.erase(item)
	return replace

func save_all_changes():
	var iterator = changes.duplicate()
	for item in iterator:
		save_change(item)
	SaveAlert.show_alert("Set value of " + str(changes.size()) + " variables!")

func reset_change(item):
	var meta = item.get_metadata(1)
	var follow = follow_keypath(meta.dict, meta.keypath)
	match meta.type:
		Variant.Type.TYPE_BOOL:
			item.set_checked(1, follow)
		_:
			item.set_text(1, str(follow))
	item.set_button_disabled(1, 0, true)
	item.set_button_disabled(1, 1, true)
	changes.erase(item)
	return follow

func reset_all_changes():
	var iterator = changes.duplicate()
	for item in iterator:
		reset_change(item)
	SaveAlert.show_alert("Reset value of " + str(changes.size()) + " variables!")

func setup_upgrade_branch(item : TreeItem, index_dict : Dictionary):
	item.set_text(1, get_child_from_key(item, "times_purchased").get_child(0).get_child(0).get_text(1))
	item.set_editable(1, true)
	item.add_button(1, EDITABLE_TYPES.UPGRADE_SET.icon, EDITABLE_TYPES.UPGRADE_SET.id)
	item.add_button(1, EDITABLE_TYPES.ARCADE_UPGRADE_SET.icon, EDITABLE_TYPES.ARCADE_UPGRADE_SET.id)


func set_upgrade_value(item, id):
	var meta = item.get_metadata(1)
	var upgrade_amount = float(item.get_text(1))
	var checked = upgrade_amount >= 1.0
	
	var UPGRADE_FLOAT_CHILDREN
	
	if id == 0: UPGRADE_FLOAT_CHILDREN = [get_child_from_key(item, "locked_in_level").get_child(0), get_child_from_key(item, "times_purchased").get_child(0).get_child(0)]
	elif id == 1: UPGRADE_FLOAT_CHILDREN = [get_child_from_key(item, "locked_in_level__arcade").get_child(0), get_child_from_key(item, "times_purchased__arcade").get_child(0)]
	var UPGRADE_BOOL_CHILDREN = [get_child_from_key(item, "applied").get_child(0), get_child_from_key(item, "purchased").get_child(0)]
	var UPGRADE_BOOL_SNOBBY_CHILDREN = [get_child_from_key(item, "revealed").get_child(0)]
	
	for child in UPGRADE_FLOAT_CHILDREN:
		child.set_text(1, str(upgrade_amount))
		save_change(child)
	for child in UPGRADE_BOOL_CHILDREN:
		child.set_checked(1, checked)
		save_change(child)
	if checked: 
		for child in UPGRADE_BOOL_SNOBBY_CHILDREN:
			child.set_checked(1, true)
			save_change(child)

	return upgrade_amount

func handle_editable(item : TreeItem, column, id, _mbi):
	var meta = item.get_metadata(1)
	match meta.category:
		VAR_CATEGORIES.UPGRADE:
			match id:
				EDITABLE_TYPES.UPGRADE_SET.id:
					SaveAlert.show_alert("Set upgrade count of " + "/".join(meta.keypath) + " to " + str(set_upgrade_value(item, id)) + "!")
				EDITABLE_TYPES.ARCADE_UPGRADE_SET.id:
					SaveAlert.show_alert("Set arcade upgrade count of " + "/".join(meta.keypath) + " to " + str(set_upgrade_value(item, id)) + "!")
				_:
					pass
		_:
			match id:
				EDITABLE_TYPES.ENTER.id:
					SaveAlert.show_alert("Set value of " + "/".join(meta.keypath) + " to " + str(save_change(item)) + "!")
				EDITABLE_TYPES.RESET.id:
					SaveAlert.show_alert("Reset value of " + "/".join(meta.keypath) + " to " + str(reset_change(item)) + "!")
				_:
					pass



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
			"category": meta.category,
		})
	total_changes = []

func show_editable_button():
	var item = get_edited()
	var meta = item.get_metadata(1)
	if meta.category != VAR_CATEGORIES.DEFAULT: return
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
