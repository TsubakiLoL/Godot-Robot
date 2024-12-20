#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends Window

var root_instance:NodeRoot
var driver:MessageDriver
const DEBUG_WINDOW_SIDE_BTN = preload("res://NodeChat/message_debug_driver/tscn/debug_window_side_btn.tscn")


@onready var graph_add_pos: PanelContainer = $Control/VBoxContainer/HBoxContainer2/VSplitContainer/graph_add_pos
@onready var tree: Tree = $Control/VBoxContainer/HBoxContainer2/VSplitContainer/Panel/HSplitContainer/Tree

var graph:DebugGraph
var tree_cache:Dictionary={}


const DEBUG_GRAPH = preload("res://NodeChat/message_debug_driver/tscn/debug_graph.tscn")

var id_arr:Array[String]=[]
var triger_type_arr:Array[int]
var type_array:Dictionary={
	
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.
func create_from_instance(root:NodeRoot):
	if root_instance!=null:
		if root_instance.debug_cache_update.is_connected(debug_cache_update):
			root_instance.debug_cache_update.disconnect(debug_cache_update)
		root_instance.delete()
		root_instance=null
	root_instance=root
	instance_graph()
	root_instance.is_in_debug=true
	root_instance.start()
	root_instance.debug_cache_update.connect(debug_cache_update)

func instance_graph():
	if graph!=null:
		graph.queue_free()
	var newgraph=DEBUG_GRAPH.instantiate() as DebugGraph
	graph_add_pos.add_child(newgraph)
	newgraph.reload_from_state_r(root_instance)
	graph=newgraph
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_about_to_popup() -> void:
	instance_graph()
	create_tree_from_frame(root_instance.debug_cache)
	pass # Replace with function body.
func create_tree_from_frame(debug_cache:Array):
	tree.clear()
	tree_cache.clear()
	tree.create_item()
	for i in root_instance.debug_cache:
		var item=tree.create_item()
		tree_cache[item]=i["frame"][0]
		item.set_text(0,i.id)
		for j in i.frame:
			var it=item.create_child()
			tree_cache[it]=j
			it.set_text(0,j.type+str(j.id))
			var input=it.create_child()
			input.set_text(0,"输入")
			tree_cache[input]=j
			var output=it.create_child()
			output.set_text(0,"输出")
			tree_cache[output]=j
			for k in j.input_data_arr.size():
				var m=input.create_child()
				m.set_text(0,"端口"+str(k)+":"+str(j.input_data_arr[k]))
				m.set_custom_color(0,ChatNodeGraph.type_color[j.input_data_type[k]])
				tree_cache[m]=j
				
			for k in j.output_data_arr.size():
				var m=output.create_child()
				m.set_text(0,"端口"+str(k)+":"+str(j.output_data_arr[k]))
				m.set_custom_color(0,ChatNodeGraph.type_color[j.output_data_type[k]])
				tree_cache[m]=j
			it.set_collapsed(true)
	pass







func _on_tree_item_selected() -> void:
	var item=tree.get_selected()
	if tree_cache.has(item):
		graph.focus_id(tree_cache[item].id)
	pass # Replace with function body.


func _on_close_requested() -> void:
	self.hide()
	if root_instance!=null:
		if root_instance.debug_cache_update.is_connected(debug_cache_update):
			root_instance.debug_cache_update.disconnect(debug_cache_update)
		root_instance.delete()
		root_instance=null
		pass
	pass # Replace with function body.
#调试信息更新时触发
func debug_cache_update():
	if root_instance!=null:
		create_tree_from_frame(root_instance.debug_cache)
	
	pass
