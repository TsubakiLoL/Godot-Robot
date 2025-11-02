#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends HBoxContainer
@onready var name_btn: Button = $name_btn
@onready var delete: Button = $delete
var triger_type:int=0
signal focus(ind:int)
signal free(ind:int)



func _on_name_btn_pressed() -> void:
	focus.emit(get_index())
	pass # Replace with function body.


func _on_delete_pressed() -> void:
	free.emit(get_index())
	pass # Replace with function body.
