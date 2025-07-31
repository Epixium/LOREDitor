extends FileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var data_dir = OS.get_user_data_dir()
	var splot = data_dir.split("/")
	splot.remove_at(splot.size()-1)
	data_dir = "/".join(splot) + "/LORED/"
	set_current_path(data_dir)

func _on_file_button_pressed() -> void:
	show()
