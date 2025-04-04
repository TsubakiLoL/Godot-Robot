extends Window
class_name VariablePopupWindow
#示例数据格式
static var example_data={
	
	"variable_name":[VariableConfig,{}]
	
}
const VARIABLE_HBOX = preload("res://autoload/ContentWindow/variable_hbox.tscn")
#对实例化节点的引用
var variable_instance:Dictionary[String,VariableHbox]={
	
}

var call_back
func request_pop(data:Dictionary,callback=null):
	for i in data.keys():
		var value=data[i]
		if value is Array and value[0] is VariableConfig:
			var new_hbox=VARIABLE_HBOX.instantiate()
			%item_add_pos.add_child(new_hbox)
			var ex_data={}
			if value.size()==2:
				ex_data=value[1]
			new_hbox.instantiate_variable(i,value[0],value[1])
			variable_instance[i]=new_hbox
	self.call_back=callback
	popup()
func _on_close_requested() -> void:
	hide()
	pass # Replace with function body.
	




#每个条目代表的
class VariableConfig:
	enum TEXT_TYPE{
		SINGLE,
		MULTI,
	}
	#标志
	enum TAG{
		NOT_EMPTY,
		LIST_SELECT,
		SELECT_FILE,
		CANT_EDIT,
	}
	var type:TEXT_TYPE=TEXT_TYPE.SINGLE
	var tags:Array[TAG]=[]
	var extra_data:Dictionary={}
	func _init(type:TEXT_TYPE,tags:Array[TAG],extra_data:Dictionary={}):
		self.type=type
		self.tags=tags
		self.extra_data=extra_data
	func has_tag(tag:TAG):
		return tags.has(tag)
	
	func can_empty():
		return not tags.has(TAG.NOT_EMPTY)
	
	
	func get_select_list()->Array[String]:
		var data:Array[String]=[]
		if extra_data.has("select_list"):
			var select_list=extra_data["select_list"]
			for i in select_list:
				data.push_back(i)
		return data
	#获取后缀数组
	func get_backend_array()->Array[String]:
		var data:Array[String]=[]
		if extra_data.has("backend"):
			var select_list=extra_data["backend"]
			for i in select_list:
				data.push_back(i)
		return data



func _on_accept_pressed() -> void:
	var result:Dictionary={}
	for i in variable_instance.keys():
		
		if variable_instance[i].is_pass():
			result[i]=variable_instance[i].get_value()
		else:
			return
	if call_back is Callable and call_back.is_valid():
		call_back.call(result)
	pass # Replace with function body.


func _on_refuse_pressed() -> void:
	queue_free()
	pass # Replace with function body.
