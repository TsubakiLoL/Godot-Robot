#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends GraphEdit
class_name DebugGraph
var focus_zoom:float=1.2
var animation_time:float=0.2

var now_id:String:
	set(val):
		focus_id(val)
		now_id=val
func reload_from_state_r(root):
	if root!=null:
		print("正在重新从节点构建可视化")
		for i in root.node_list:
			var new_graph=preload("res://node_chat/new_graph/tscn/chat_node_graph.tscn").instantiate() as ChatNodeGraph
			new_graph.set_real(i)
			add_child(new_graph)
			new_graph.init()
		for i in root.node_list:
			for j in i.next_node_array:
				var from=i.id
				connect_node(from,j[1],j[0].id,j[2])
func focus_id(id:String,data:Dictionary={}):
	#new_graph.position_offset=(Vector2(pop_up_menu.position)+graph.scroll_offset)/graph.zoom
	var graph_node=get_node(id)
	if graph_node is GraphNode:
		var new_tween=create_tween()
		new_tween.tween_property(self,"scroll_offset",(graph_node.position_offset+graph_node.size/2)*focus_zoom-size/2,animation_time)
		new_tween.set_parallel()
		new_tween.tween_property(self,"zoom",focus_zoom,animation_time)
		set_selected(graph_node)
		pass
	pass


func _on_focus_pressed() -> void:
	if now_id!="":
		focus_id(now_id)
	pass # Replace with function body.
