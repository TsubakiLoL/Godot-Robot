#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends Node
class_name MessageDriver
var now_instance:NodeRoot
func emit_message(id:String,triger_type:String,data:Dictionary):
	if now_instance!=null:
		now_instance.prompt_message(id,triger_type,data)
	
	
	
	pass
