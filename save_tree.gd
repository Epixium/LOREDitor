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
var enter_button_icon = preload("res://enter_var.png")

var root
@export var SaveAlert : RichTextLabel = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = create_item()
	#create_tree_from_nested_dict(SAMPLE_TREE)
	button_clicked.connect(handle_editable)

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
				create_new_editable(child, start_dict, new_path, Variant.Type.TYPE_BOOL)
			var x:
				child.set_text(1, str(value))
				create_new_editable(child, start_dict, new_path, x)

var tween : Tween

func handle_editable(treeitem : TreeItem, column, _id, _mbi):
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
	if tween: tween.stop()
	SaveAlert.text = "[wave amp=20.0 freq=6.0]Set value of " + "/".join(meta.keypath) + " to " + str(replace) + "![/wave]"
	SaveAlert.modulate = Color(1, 1, 1, 1)
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(SaveAlert, "modulate", Color(1, 1, 1, 0), 3)
	tween.play()

func create_new_editable(treeitem : TreeItem, dict : Dictionary, keypath : Array, type):
	treeitem.set_editable(1, true)
	treeitem.add_button(1, enter_button_icon)
	treeitem.set_metadata(1, {
		"dict": dict,
		"keypath": keypath,
		"type": type,
	})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
