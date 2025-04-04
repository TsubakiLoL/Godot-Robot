extends Window

signal request_create_nodeset(nodeset_name:String,nodeset_introduction:String,file_path:String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_list()
	pass # Replace with function body.

func init_list():
	var nodeset_list:Array=NodeSetGlobal.get_all_nodeset_mes()
	for i in nodeset_list:
		%node_set_list.add_item(i[0])
	if nodeset_list.size()!=0:
		%file.text=nodeset_list[0][0]
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	queue_free()
	pass # Replace with function body.


func _on_accept_pressed() -> void:
	var nodeset_name:String=%nodeset_name.text
	var nodeset_introduction:String=%nodeset_introduction.text
	var file_path:String=%file.text
	if nodeset_name=="":
		return
	if not FileAccess.file_exists(file_path):
		return
	request_create_nodeset.emit(nodeset_name,nodeset_introduction,file_path)
	queue_free()


func _on_refuse_pressed() -> void:
	queue_free()
	pass # Replace with function body.




func _on_node_set_list_item_selected(index: int) -> void:
	var item:String=%node_set_list.get_item_text(index)
	%file.text=item
	


func _on_select_file_pressed() -> void:
	DisplayServer.file_dialog_show("选择节点集文件","","",false,DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,PackedStringArray(["*.nodeset"]),load_file_selected)
	pass # Replace with function body.
func load_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		%file.text=selected_paths[0]
