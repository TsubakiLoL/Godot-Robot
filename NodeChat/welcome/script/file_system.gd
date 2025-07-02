#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------


extends Control
signal edit_file(path:String)
var single:PackedScene=preload("res://NodeChat/welcome/tscn/single_file.tscn")
func _ready() -> void:
	recreate()
	NodeSetGlobal.node_set_update.connect(recreate)
#重构列表
func recreate():
	for i in %add_pos.get_children():
		i.queue_free()
	var file_array=NodeSetGlobal.get_all_nodeset_mes()
	for i in file_array:
		var new_single=single.instantiate() as SingleFile
		new_single.root_path=i[0]
		new_single.data_path=i[1]
		%add_pos.add_child(new_single)
		new_single.edit_file_request.connect(edit_file_request)
		




func delete_request(s:SingleFile):
	if s.is_run:
		s._on_run_pressed()
	s.queue_free()
	await  get_tree().create_timer(0.2).timeout

	

func _on_load_file_pressed() -> void:
	DisplayServer.file_dialog_show("选择节点集文件","","",false,DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,PackedStringArray(["*.nodeset"]),load_file_selected)

	pass # Replace with function body.
func load_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		NodeSetGlobal.add_nodeset(selected_paths[0],"")


func _on_add_file_pressed() -> void:
	DisplayServer.file_dialog_show("保存节点集文件为","","",false,DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,PackedStringArray(["*.nodeset"]),add_file_selected)
	pass # Replace with function body.
func add_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		add_new_file(selected_paths[0])
func add_new_file(path:String):
	if not path.ends_with(".nodeset"):
		path+=".nodeset"
	var f=FileAccess.open(path,FileAccess.WRITE)
	if f!=null:
		f.store_string('[{"0":{"from_node_array":[],"next_node_array":[],"position_x":0,"position_y":0,"type":0,"mod_from":"basemod","mod_node":"状态节点"}},{"init_state":"0","judge_time":2,"time_to_delete_instance":30}]')
		f.close()
		NodeSetGlobal.add_nodeset(path,"")

func edit_file_request(path:String):
	edit_file.emit(path)


func _on_refresh_file_pressed() -> void:
	recreate()


const NODESET_CLOUD = preload("res://NodeChat/welcome/tscn/nodeset_cloud.tscn")
func _on_cloud_run_pressed() -> void:
	var new_cloud_window=NODESET_CLOUD.instantiate()
	add_child(new_cloud_window)
	new_cloud_window.popup()
	
