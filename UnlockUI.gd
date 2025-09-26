extends Label

func show_unlock(text_to_show: String) -> void:
	text = text_to_show
	visible = true
	modulate.a = 0.0
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.4) # fade in
	t.tween_interval(2.2)                          # stay visible
	t.tween_property(self, "modulate:a", 0.0, 0.4) # fade out
