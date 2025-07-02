#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------


extends TextEdit

class_name NodeChatTextInput
signal node_text_changed(txt:String)

func _on_text_changed() -> void:
	node_text_changed.emit(text)
	pass # Replace with function body.
func set_value(value):
	if value is String:
		text=value
