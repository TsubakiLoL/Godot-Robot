#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends Control
var single=preload("res://node_chat/graphe/tscn/type_color_single.tscn")

@onready var add_position=$VBoxContainer


func _ready() -> void:
	for i in ChatNodeGraph.type_num.keys():
		var s=single.instantiate() as TypeColorSingle
		s.set_information(ChatNodeGraph.type_color[i],ChatNodeGraph.type_name[i])
		add_position.add_child(s)
		
