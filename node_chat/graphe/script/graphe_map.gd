#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------




extends Control
class_name GrapheMap
##当前正在编辑的节点集的引用
@onready var root:NodeRoot=NodeRoot.new()
@onready var graph: GraphEdit = $VBoxContainer/GraphEdit
@onready var pop_up_menu:PopupPanel=$PopupPanel
@onready var nodeset: MenuButton = $VBoxContainer/HBoxContainer/Nodeset
@onready var editor: MenuButton = $VBoxContainer/HBoxContainer/editor
@onready var doc: MenuButton = $VBoxContainer/HBoxContainer/doc
@onready var file_name: Label = $VBoxContainer/HBoxContainer/file_name
@onready var should_save: AcceptDialog = $should_save
@onready var debug_window: Window = $DebugWindow


##当前打开的文件路径
var now_file_path:String="(*)":
	set(val):
		file_name.text=val
		now_file_path=val
##下一步打开的路径，用来在文件之间切换时的临时存储
var next_file_path:String
##当前文件是否已经被更改但没保存
var file_changed:bool=false

func ask_save():
	should_save.show()

func open_file():
	DisplayServer.file_dialog_show("选择节点集文件"," "," ",false,DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,PackedStringArray(),opened_file_selected)
	
func opened_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		open_state_root(selected_paths[0])
		
func save_file():
	DisplayServer.file_dialog_show("保存节点集文件"," "," ",false,DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,PackedStringArray(["*.nodeset"]),save_file_selected)

func save_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		save_state_root(selected_paths[0])
	pass
func save_state_root(file_path:String):
	#print(file_path)
	
	var new_file=file_path
	if not file_path.ends_with(".nodeset"):
		new_file+=".nodeset"
	var f=FileAccess.open(new_file,FileAccess.WRITE)
	if f!=null:
		var str=Serializater.stringfy_state_root(root)
		f.store_string(str)
		f.close()
		now_file_path=new_file
			
	
func save_now_file():
	if now_file_path!="(*)":
		save_state_root(now_file_path)
		file_changed=false
		Toast.popup("保存成功")
	else:
		save_file()
		file_changed=false
		
		pass
func open_state_root(file_path:String):
	var f=FileAccess.open(file_path,FileAccess.READ)
	if f!=null:
		var str=f.get_as_text()
		f.close()
		var node=Serializater.parse_string(str)
		if node!=null:
			if file_changed:
				next_file_path=file_path
				ask_save()
			else:
				file_changed=false
				now_file_path=file_path
				if root!=null:
					root.delete()
				root=node
				reload_from_state_r()

func instance_new_graph():
	graph.queue_free()
	var new_graph=preload("res://node_chat/graphe/tscn/graph.tscn").instantiate() as GraphEdit
	$VBoxContainer.add_child(new_graph)
	graph=new_graph
	new_graph.connection_request.connect(_on_graph_edit_connection_request)
	new_graph.delete_nodes_request.connect(_on_graph_edit_delete_nodes_request)
	new_graph.disconnection_request.connect(_on_graph_edit_disconnection_request)
	new_graph.popup_request.connect(_on_graph_edit_popup_request)
	
func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from:ChatNodeGraph=graph.get_node(str(from_node)) as ChatNodeGraph
	var to:ChatNodeGraph=graph.get_node(str(to_node)) as ChatNodeGraph
	var from_real:ChatNode=from.get_real()
	var to_real:ChatNode=to.get_real()
	#print("开始链接")
	if from_real.connect_with_next_node(to_real,from_port,to_port):
		graph.connect_node(from_node,from_port,to_node,to_port)

func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	
	var from:ChatNodeGraph=graph.get_node(str(from_node)) as ChatNodeGraph
	var to:ChatNodeGraph=graph.get_node(str(to_node)) as ChatNodeGraph
	var from_real:ChatNode=from.get_real()
	var to_real:ChatNode=to.get_real()
	from_real.disconnect_with_next_node(to_real,from_port,to_port)
	graph.disconnect_node(from_node,from_port,to_node,to_port)
func _on_graph_edit_popup_request(position: Vector2) -> void:
	file_changed=true
	pop_up_menu.position=Vector2(get_window().position)+position
	pop_up_menu.show()
	pass # Replace with function body.



func _on_graph_edit_delete_nodes_request(nodes: Array[StringName]) -> void:
	file_changed=true
	for i in nodes:
		for j in graph.get_connection_list():
			#print(j)
			if j["to_node"]==i:
				graph.disconnect_node(j["from_node"],j["from_port"],j["to_node"],j["to_port"])
			elif j["from_node"]==i:
				graph.disconnect_node(j["from_node"],j["from_port"],j["to_node"],j["to_port"])
		var gra=graph.get_node(str(i))
		if gra!=null:
			var n:ChatNode=gra.get_real() as ChatNode
			var ind=root.node_list.find(n)
			n.delete()
			root.node_list.pop_at(ind)
			gra.queue_free()
	pass # Replace with function body.


func _ready() -> void:
	#IIROSE.set_information("雪村千绘莉","tsubaki","66234e757a3ce")
	#IIROSE.start_connect()
	nodeset.get_popup().index_pressed.connect(nodeset_pressed)
	pass
	
func nodeset_pressed(id:int):
	match id:
		0:
			open_file()
		1:
			save_now_file()
		2:
			save_as_other_file()
		3:
			if root!=null:
				root.delete()
			%DebugWindow._on_close_requested()
			queue_free()
			pass
	pass
func save_as_other_file():
	DisplayServer.file_dialog_show("另存为"," "," ",false,DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,PackedStringArray(["*.nodeset"]),save_as_other_file_selected)
	pass
func save_as_other_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		save_state_root(selected_paths[0])
	pass

func debug():
	var str=Serializater.stringfy_state_root(root)
	#print("调试序列化成功：")
	#print(str)
	var res=Serializater.parse_string(str)
	if res!=null:
		#print("从序列化中构建新的节点实例成功！")
		#if now_run_root!=null:
			#now_run_root.end()
			#now_run_root.delete_self()
		#now_run_root=res
		#now_run_root.start()
		$VBoxContainer/HBoxContainer/stop.disabled=false
	pass # Replace with function body.


func stop_debug() -> void:
	#if root!=null:
		#now_run_root.end()
		#now_run_root.delete()
		#now_run_root=null
		#$VBoxContainer/HBoxContainer/stop.disabled=true
	pass # Replace with function body.


func reload_from_state_r():
	if root!=null:
		instance_new_graph()
		print("正在重新从节点构建可视化")
		for i in root.node_list:
			var new_graph=preload("res://node_chat/new_graph/tscn/chat_node_graph.tscn").instantiate() as ChatNodeGraph
			new_graph.set_real(i)
			graph.add_child(new_graph)
			new_graph.init()
		for i in root.node_list:
			for j in i.next_node_array:
				var from=i.id
				graph.connect_node(from,j[1],j[0].id,j[2])



func _on_should_save_canceled() -> void:
	file_changed=false
	open_state_root(next_file_path)
	pass # Replace with function body.


func _on_should_save_confirmed() -> void:
	save_now_file()
	open_state_root(next_file_path)
	pass # Replace with function body.




func debug_message(txt:String):
	$debug/ScrollContainer/Label.append_text(txt+"\n")


func _on_debug_pressed() -> void:
	#debug_mes.show()
	var str=Serializater.stringfy_state_root(root)
	#print("调试序列化成功：")
	#print(str)
	var res=Serializater.parse_string(str)
	if res!=null:
		debug_window.create_from_instance(res)
		debug_window.popup()
	pass # Replace with function body.


func _on_doc_pressed() -> void:
	get_parent()._on_doc_pressed()
	pass # Replace with function body.


func _on_popup_panel_selected_node(mod: String, node: String) -> void:
	
	file_changed=true
	var node_class=ModLoader.get_node_class(mod,node)
	if node_class==null:
		return
	
	var new_node:ChatNode=node_class.new(root)
	new_node.mod_from=mod
	new_node.mod_node=node
	var new_graph=preload("res://node_chat/new_graph/tscn/chat_node_graph.tscn").instantiate() as ChatNodeGraph
	new_graph.position_offset=(Vector2(pop_up_menu.position)+graph.scroll_offset)/graph.zoom-Vector2(get_window().position)
	new_node.position_x=new_graph.position_offset.x
	new_node.position_y=new_graph.position_offset.y
	root.add_node(new_node)
	graph.add_child(new_graph)
	new_graph.set_real(new_node)
	new_graph.init()
	
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		
		save_now_file()
	
