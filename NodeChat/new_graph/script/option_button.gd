#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends OptionButton

class_name NodeChatSelect
signal tab_select(ind:int)
var map_dic:Array=[]

func _on_item_selected(index: int) -> void:
	if index<map_dic.size():
		tab_select.emit(map_dic[index])
	pass # Replace with function body.
