extends HBoxContainer

class_name VariableHbox
const CONTENT_WINDOW_FILE_BUTTON = preload("res://autoload/ContentWindow/content_window_file_button.tscn")
const CONTENT_WINDOW_LABEL = preload("res://autoload/ContentWindow/content_window_label.tscn")
const CONTENT_WINDOW_LINE_EDIT = preload("res://autoload/ContentWindow/content_window_line_edit.tscn")
const CONTENT_WINDOW_TEXT_EDIT = preload("res://autoload/ContentWindow/content_window_text_edit.tscn")
const CONTENT_WINDOW_SELECT_LIST = preload("res://autoload/ContentWindow/content_window_select_list.tscn")

var variable_config:VariablePopupWindow.VariableConfig

var text_source

func instantiate_variable(variable_name:String,variable_config:VariablePopupWindow.VariableConfig):
	self.variable_config=variable_config
	#不同的文本输入类型
	var name_label=CONTENT_WINDOW_LABEL.instantiate()
	add_child(name_label)
	name_label.text=variable_name
	#实例化输入框
	match variable_config.type:
		VariablePopupWindow.VariableConfig.TEXT_TYPE.SINGLE:
			var new_edit=CONTENT_WINDOW_LINE_EDIT.instantiate()
			add_child(new_edit)
			text_source=new_edit
			pass
		VariablePopupWindow.VariableConfig.TEXT_TYPE.MULTI:
			var new_edit=CONTENT_WINDOW_TEXT_EDIT.instantiate()
			add_child(new_edit)
			text_source=new_edit
	#初始化
	if variable_config.extra_data.has("init_value"):
		text_source.text=variable_config.extra_data["init_value"]
	#不可编辑
	if variable_config.has_tag(VariablePopupWindow.VariableConfig.TAG.CANT_EDIT):
		text_source.editable=false
	if variable_config.has_tag(VariablePopupWindow.VariableConfig.TAG.SELECT_FILE):
		var backend_array:Array[String]=variable_config.get_backend_array()
		var new_file_select_btn=CONTENT_WINDOW_FILE_BUTTON.instantiate()
		new_file_select_btn.back_end=backend_array
		new_file_select_btn.file_selected.connect(
			func(path:String):
				self.text_source.text=path)
		add_child(new_file_select_btn)
	if variable_config.has_tag(VariablePopupWindow.VariableConfig.TAG.LIST_SELECT):
		var select_list:Array[String]=variable_config.get_select_list()
		var new_item_select=CONTENT_WINDOW_SELECT_LIST.instantiate()
		new_item_select.list=select_list
		new_item_select.item_select.connect(
			func(path:String):
				self.text_source.text=path)
		add_child(new_item_select)
		
func is_pass()->bool:
	if variable_config.has_tag(VariablePopupWindow.VariableConfig.TAG.NOT_EMPTY):
		var text=text_source.text
		if text!="":
			return true
		else:
			return false
	return true
func get_value()->String:
	
	return text_source.text
