#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends GraphNode
class_name ChatNodeGraph
var real_var:ChatNode


static var type_num:Dictionary={
	"String":0,
	"Dictionary":1,
	"StateWithTriger":3,
	"ChangeState":4,
	"Bool":5,
	"Float":6
}

static var type_color:Dictionary={
	"String":Color.GREEN,
	"Dictionary":Color.RED,
	"StateWithTriger":Color.WHITE,
	"ChangeState":Color.BLACK,
	"Bool":Color.PURPLE,
	"Float":Color.PINK
}
static var type_name:Dictionary={
	"String":"字符串",
	"Dictionary":"字典",
	"StateWithTriger":"触发器信号",
	"ChangeState":"状态转换信号",
	"Bool":"布尔类型",
	"Float":"数字"
}

func _ready() -> void:
	position_offset_changed.connect(_on_position_offset_changed)
	resize_request.connect(_on_resize_request)

func set_real(real:ChatNode):
	real_var=real
func get_real():
	return real_var
func _on_position_offset_changed() -> void:
	if real_var!=null:
		real_var.position_x=position_offset.x
		real_var.position_y=position_offset.y
	pass # Replace with function body.
func _on_resize_request(new_minsize: Vector2) -> void:
	self.size=new_minsize
	pass # Replace with function body.
func init():
	if real_var!=null:
		var hbox_array:Array=[]
		position_offset=Vector2(real_var.position_x,real_var.position_y)
		for i in range(real_var.variable_name_array.size()):
			var new_hbox=preload("res://NodeChat/new_graph/tscn/chat_node_graph_hbox.tscn").instantiate()
			add_child(new_hbox)
			hbox_array.append(new_hbox)
			match real_var.variable_type_array[i]:
				ChatNode.variable_type.TYPE_STRING:
					var text_edit=preload("res://NodeChat/new_graph/tscn/text_edit.tscn").instantiate() as NodeChatTextInput
					text_edit.placeholder_text=real_var.variable_name_view[i]
					text_edit.node_text_changed.connect(set_variable_name.bind(real_var.variable_name_array[i]))
					var value=real_var.get(real_var.variable_name_array[i])
					if value!=null and value is String:
						text_edit.text=value
					new_hbox.init(text_edit)
				ChatNode.variable_type.TYPE_BOOL:
					var check=preload("res://NodeChat/new_graph/tscn/check_button.tscn").instantiate() as CheckButton
					check.text=real_var.variable_name_view[i]
					check.toggled.connect(set_variable_name.bind(real_var.variable_name_array[i]))
					var value=real_var.get(real_var.variable_name_array[i])
					if value!=null and value is bool:
						check.button_pressed=value
					new_hbox.init(check)
				ChatNode.variable_type.TYPE_SELECT:
					 #[[triger_type,["弹幕","房间","私聊","进入状态","退出状态"]]]
					var map_dic:Array=[]
					var data=real_var.variable_type_more[i]
					var option=preload("res://NodeChat/new_graph/tscn/option_button.tscn").instantiate() as NodeChatSelect
					for j in range(data[0].size()):
						option.add_item(data[1][j])
						map_dic.append(data[0][j])
					option.map_dic=map_dic
					option.tab_select.connect(set_variable_name.bind(real_var.variable_name_array[i]))
					new_hbox.init(option)
					var ind=map_dic.find(real_var.get(real_var.variable_name_array[i]))
					option.select(ind)
				ChatNode.variable_type.TYPE_COLOR:
					var color_picker = preload("res://NodeChat/new_graph/tscn/color_picker.tscn").instantiate()
					var value=real_var.get(real_var.variable_name_array[i])
					new_hbox.init(color_picker)
					if value!=null and value is String:
						color_picker.color=Color(value)
					color_picker.color_changed.connect(
						func(color:Color):
							set_variable_name(color.to_html(false),real_var.variable_name_array[i])
					)
		var need_port_num:int=max(real_var.input_port_array.size(),real_var.output_port_array.size())
		if need_port_num-real_var.variable_name_array.size()>0:
			for i in range(need_port_num-real_var.variable_name_array.size()):
				var new_hbox=preload("res://NodeChat/new_graph/tscn/chat_node_graph_hbox.tscn").instantiate()
				hbox_array.append(new_hbox)
				add_child(new_hbox)
		for i in range(real_var.input_port_array.size()):
			if real_var.input_port_array[i] in type_num:
				set_slot_enabled_left(i,true)
				set_slot_color_left(i,type_color[real_var.input_port_array[i]])
				set_slot_type_left(i,type_num[real_var.input_port_array[i]])
		for i in range(real_var.output_port_array.size()):
			if real_var.output_port_array[i] in type_num:
				set_slot_enabled_right(i,true)
				set_slot_color_right(i,type_color[real_var.output_port_array[i]])
				set_slot_type_right(i,type_num[real_var.output_port_array[i]])
		for i in range(hbox_array.size()):
			var name_arr=get_index_left_and_right_name(i)
			print(name_arr)
			hbox_array[i].set_left_right_name(name_arr[0],name_arr[1])
		title=real_var.mod_node+real_var.id
		name=real_var.id
func get_index_left_and_right_name(ind:int)->Array[String]:
	var res:Array[String]=[]
	if real_var==null:
		return ["",""]
	if ind>=real_var.input_port_name.size():
		res.append("")
	else:
		res.append(real_var.input_port_name[ind])
	if ind>=real_var.output_port_name.size():
		res.append("")
	else:
		res.append(real_var.output_port_name[ind])
	return res

func set_variable_name(value,n:String):
	if real_var!=null and real_var.get(n)!=null:
		real_var.set(n,value)
	pass
