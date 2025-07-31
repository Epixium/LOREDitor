extends OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_save_mode()

func set_save_mode():
	match text:
		"File":
			%FileSaver.show()
			%ClipboardSaver.hide()
		"Clipboard":
			%FileSaver.hide()
			%ClipboardSaver.show()

func _on_item_selected(index: int) -> void:
	set_save_mode()
