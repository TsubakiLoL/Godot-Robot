
#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------


extends HBoxContainer
class_name TypeColorSingle
func set_information(color:Color,text:String):
	$TextureRect.modulate=color
	$Label.text=text
