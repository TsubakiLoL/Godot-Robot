extends ColorPickerButton


func set_value(value):
	if value is String:
		color=Color(value)
