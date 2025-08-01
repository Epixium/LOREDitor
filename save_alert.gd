extends RichTextLabel

var tween : Tween

func show_alert(alert_text):
	text = "[wave amp=20.0 freq=6.0]" + alert_text + "[/wave]"
	modulate = Color(1, 1, 1, 1)
	if tween: tween.stop()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 3)
