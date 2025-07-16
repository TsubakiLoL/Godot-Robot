#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------


extends PanelContainer
class_name SingleFile
const STOP = preload("res://NodeChat/welcome/res/stop.png")
const START = preload("res://NodeChat/welcome/res/start.png")
signal delete_self(s:SingleFile)
signal edit_file_request(path:String)
var root_path:String


func _ready() -> void:
	%name.text=root_path
	%run.icon= STOP if NodeSetGlobal.has_instance(root_path) else START
	pass

func _on_run_pressed() -> void:
	if NodeSetGlobal.has_instance(root_path):
		NodeSetGlobal.stop_instance(root_path)
	else:
		NodeSetGlobal.open_instance(root_path)
	pass


func _on_edit_pressed() -> void:
	edit_file_request.emit(root_path)
	pass # Replace with function body.


func _on_delete_pressed() -> void:
	NodeSetGlobal.delete_nodeset(root_path)
	pass # Replace with function body.
