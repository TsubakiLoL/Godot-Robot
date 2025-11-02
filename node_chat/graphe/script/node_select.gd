#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends Control
@onready var line_edit: LineEdit = $LineEdit
@onready var item_list: ItemList = $ItemList
signal selected(type:int)

signal select_node(mod:String,node:String)
var now_contain_item:Array=[]
func _ready() -> void:
	update("")
	pass

func update(str:String):
	now_contain_item.clear()
	item_list.clear()
	var all_class:Array=ModLoader.get_all_node_class()
	if str!="":
		#for i in ChatNodeGraph.node_name.keys():
			#if ChatNodeGraph.node_name[i].contains(str):
				#now_contain_item.append([i,ChatNodeGraph.node_name[i]])
				#item_list.add_item(ChatNodeGraph.node_name[i])
		for i in all_class:
			var node_all_name:String=i[0]+"/"+i[1]
			if node_all_name.contains(str):
				now_contain_item.append(i)
				item_list.add_item(node_all_name)
		pass
	else:
		#for i in ChatNodeGraph.node_name.keys():
			#now_contain_item.append([i,ChatNodeGraph.node_name[i]])
			#item_list.add_item(ChatNodeGraph.node_name[i])
		now_contain_item=all_class
		for i in all_class:
			item_list.add_item(i[0]+"/"+i[1])
		
			
		pass


func _on_item_list_item_selected(index: int) -> void:
	#selected.emit(now_contain_item[index][0])
	select_node.emit(now_contain_item[index][0],now_contain_item[index][1])
	pass # Replace with function body.


func _on_line_edit_text_changed(new_text: String) -> void:
	update(new_text)
	pass # Replace with function body.
