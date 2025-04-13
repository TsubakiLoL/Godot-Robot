extends Window

signal selected(data:Array[String])
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_from_nodeset()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	queue_free()
	pass # Replace with function body.
var selected_nodeset:Array[String]=[]

func create_from_nodeset():
	selected_nodeset=[]
	for i in %addpos.get_children():
		i.queue_free()
	var all_nodeset=NodeSetGlobal.get_all_nodeset_mes()
	for i in all_nodeset:
		var new_check=CheckBox.new()
		new_check.text=i[0]
		new_check.toggled.connect(
			(func(is_select:bool,path:String):
				if is_select:
					if not path in selected_nodeset:
						selected_nodeset.append(path)
				else:
					if path in selected_nodeset:
						selected_nodeset.pop_at(selected_nodeset.find(path))
				pass)
			.bind(i[0])
		)
		%addpos.add_child(new_check)
		


func _on_accept_pressed() -> void:
	selected.emit(selected_nodeset)
	queue_free()
	pass # Replace with function body.
