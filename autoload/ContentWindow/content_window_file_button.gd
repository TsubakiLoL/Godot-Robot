extends Button


signal file_selected(file:String)


var back_end:Array[String]=[]
# Called when the node enters the scene tree for the first time.



func _on_pressed() -> void:
	DisplayServer.file_dialog_show("选择文件","","",false,DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,PackedStringArray(back_end),load_file_selected)
	pass # Replace with function body.


func load_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		file_selected.emit(selected_paths[0])
