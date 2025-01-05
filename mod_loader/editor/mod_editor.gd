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
		Toast.popup("保存成功")
	pass # Replace with function body.

var now_select_path:String=""
func save():
	if now_select_path!="":
		var text:String=%editor.text
		var f=FileAccess.open(now_select_path,FileAccess.WRITE)
		if f!=null:
			f.store_string(text)

	
	
	
	
	pass


func _on_file_tree_file_selected(global_path: String) -> void:
	var f=FileAccess.open(global_path,FileAccess.READ)
	if f!=null:
		var str=f.get_as_text()
		%editor.text=str
		%FilePath.text=global_path
		now_select_path=global_path
	pass # Replace with function body.
