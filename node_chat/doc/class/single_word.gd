#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends Resource
class_name SingleWord

@export var name:String=""
@export_multiline var doc:String=""
@export var next_word_array:Array[SingleWord]=[]
