extends MarginContainer
const CONFIG_SECTION = preload("res://node_chat/welcome/tscn/config_section.tscn")

# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func rebuild():
	for i in %add_pos.get_children():
		i.queue_free()
	for i in GlobalConfig.get_all_section():
		var new_section=CONFIG_SECTION.instantiate()
		%add_pos.add_child(new_section)
		new_section.build_section(i)
