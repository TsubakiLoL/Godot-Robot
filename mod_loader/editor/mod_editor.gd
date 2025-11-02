extends Control
const ROBOT_ICON = preload("res://RobotIcon.png")
@export var member_keywords_dic:Dictionary={
	"extends":Color("ffaea1"),
	"func":Color("ffaea1"),
	"var":Color("ffaea1"),
	"if":Color("ffaea1"),
	"else":Color("ffaea1"),
	"elif":Color("ffaea1"),
	"for":Color("ffaea1"),
	"in":Color("ffaea1"),
	"and":Color("ffaea1"),
	"or":Color("ffaea1"),
	"super":Color("ffaea1"),
	"true":Color("ffaea1"),
	"false":Color("ffaea1"),
	"ModLoader":Color("ffaea1"),
	"pass":Color("ffaea1"),
	
}
@export var color_regins:Dictionary={
	'" "':Color.YELLOW,
	'# ':Color("585858"),
}

@export var code_completion:Dictionary={
	"extends":"extends",
	"ChatNode":"ChatNode",
	"func":"func",
	"var":"var",
	"if":"if",
	"else":"else",
	"elif":"elif",
	"for":"for",
	"in":"in",
	"and":"and",
	"or":"or",
	"input_port_array":"input_port_array",
	
}
func _ready() -> void:
	init_code_edit_high_light(%editor)
	var new_instance=ChatNode.new(NodeRoot.new())
	var list=new_instance.get_property_list()
	for i in list:
		%editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT,i["name"],i["name"],Color.AQUAMARINE,ROBOT_ICON)
	for i in code_completion.keys():
		
		%editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT,i,code_completion[i],Color.AQUAMARINE,ROBOT_ICON)
	%editor.update_code_completion_options(false)
func init_code_edit_high_light(editor:CodeEdit):
	var highlighter:CodeHighlighter=editor.syntax_highlighter
	highlighter.member_keyword_colors=member_keywords_dic
	highlighter.color_regions=color_regins
	
	
	pass


func _on_editor_text_changed() -> void:
	%editor.request_code_completion(false)
	pass # Replace with function body.


func _on_editor_code_completion_requested() -> void:
	print("代码补全")
	pass # Replace with function body.


func _on_editor_symbol_lookup(symbol: String, line: int, column: int) -> void:
	print(symbol)
	pass # Replace with function body.


func _on_editor_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save()
	pass # Replace with function body.

var now_select_path:String=""
func save():
	if now_select_path!="" and not now_select_path.ends_with(".tscn") and FileAccess.file_exists(now_select_path):
		var text:String=%editor.text
		var f=FileAccess.open(now_select_path,FileAccess.WRITE)
		if f!=null:
			f.store_string(text)
			show_mes("文件:"+now_select_path+"保存成功")

	
	
	
	
	pass


func _on_file_tree_file_selected(global_path: String) -> void:
	save()
	for i in %tscn_panel.get_children():
		i.queue_free()
	%FilePath.text=global_path
	if global_path.ends_with(".tscn"):
		var tscn=load(global_path)
		if tscn is PackedScene and tscn.can_instantiate():
			%tscn_panel.show()
			%editor_panel.hide()
			%tscn_panel.add_child(tscn.instantiate())
			now_select_path=""
			pass
		pass
	else:
		var f=FileAccess.open(global_path,FileAccess.READ)
		if f!=null:
			%editor_panel.show()
			%tscn_panel.hide()
			var str=f.get_as_text()
			%editor.text=str
			now_select_path=global_path
		pass # Replace with function body.


func _on_load_config_pressed() -> void:
	var path:String=root_path
	if not path.ends_with("/"):
		path+="/"
	var f=FileAccess.open(path+"config.json",FileAccess.READ)
	if f!=null:
		var json=JSON.parse_string(f.get_as_text())
		if json is Dictionary:
			%ConfigPanel.load_config(json)
		else:
			show_mes("格式配置错误")
		
		pass
	else:
		show_mes("配置文件不存在")
	pass # Replace with function body.


func _on_save_config_pressed() -> void:
	var path:String=root_path
	if not path.ends_with("/"):
		path+="/"
	var f=FileAccess.open(path+"config.json",FileAccess.WRITE)
	if f!=null:
		var config=%ConfigPanel.get_config()
		if config==null:
			return
		f.store_string(JSON.stringify(config))
		f.close()
	else:
		show_mes("保存出错")
	pass # Replace with function body.

var root_path:String
func load_from_root_path(path:String):
	root_path=path
	%FileTree.root_path=path
	%FileTree.reload()
	_on_load_config_pressed()
	
	pass

func show_mes(mes:String):
	var win=get_window()
	if win is BaseWindow:
		win.popup_mes(mes)
