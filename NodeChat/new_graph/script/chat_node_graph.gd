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

#static var node_chat_class:Dictionary={
	#0:ChatNodeState,					#状态节点
	#1:ChatNodeTriger,					#触发器节点
	#2:ChatNodeSentBulletMessage,		#弹幕发送器
	#3:ChatNodeSentBulletMessageStatic,	#静态弹幕发送器
	#4:ChatNodeSentRoomMessage,			#房间信息发送器
	#5:ChatNodeSentRoomMessageStatic,	#静态房间信息发送器
	#6:ChatNodeDicToStr,					#字典字符串转换
	#7:ChatNodeChangeState,				#状态转换器
	#8:ChatNodeStrJudge,					#字符串判定器
	#9:ChatNodeSentRoomMessageMultiInput,#多输入房间信息发送器
	#10:ChatNodeAnd,						#与门
	#11:ChatNodeOr,						#或门
	#12:ChatNodeNot,						#非门
	#13:ChatNodeStrConnect,				#字符串链接器
	#14:ChatNodeStrOutput,				#静态字符串输出
	#15:ChatNodeAt,						#艾特器
	#16:ChatNodeSentBulletMessageMultiInput,#多输入弹幕信息发送器
	#17:ChatNodeRegex,					#正则匹配器
	#18:ChatNodeSetGlobalNum,            #全局变量设置器
	#19:ChatNodeSetGlobalNumWithControl, #带控制端口的全局变量设置器
	#20:ChatNodeGetGlobalNum,			#全局变量提取器
	#21:ChatNodeFloatOutput,				#数字输出器
	#22:ChatNodeFloatToStr,				#数字转字符串
	#23:ChatNodeStrToFloat,				#字符串转数字
	#24:ChatNodeFloatAddStatic,			#静态数字加法器
	#25:ChatNodeFloatAdd,				#数字加法器
	#26:ChatNodeFloatCompareStatic,		#静态数字比较器
	#27:ChatNodeFloatCompare,			#数字比较器
	#28:ChatNodeFloatMulti,				#数字乘法器
	#29:ChatNodeFloatMultiStatic,		#静态数字乘法器
	#30:ChatNodeFloatRandom,				#随机数发生器
	#31:ChatNodeTime,					#当前时间输出
	#32:ChatNodeFloatCeli,				#向上取整器
	#33:ChatNodeLike,					#点赞器
	#34:ChatNodeGetGlobalString,			#全局字符串读取器
	#35:ChatNodeAddGlobalString,			#全局字符串添加器
	#36:ChatNodeAddGlobalStringWithControl,#带控制端口的全局字符串添加器
	#37:ChatNodeClearGlobalString,		#全局变量清除器
	#38:ChatNodeGPTRequest,				#GPT请求器
	#39:ChatNodeGPTRequestWithName,		#带名字的GPT请求器
	#40:ChatNodeDicHub,					#字典集线器
	#41:ChatNodeFloatHub,				#数字集线器
	#42:ChatNodeGetUniqueString,			#全用户字符串读取器
	#43:ChatNodeAddUniqueString,			#全用户字符串添加器
	#44:ChatNodeAddUniqueStringWithControl,#带控制端口的全用户字符串添加器
	#45:ChatNodeClearUniqueString,		#全用户变量清除器
#}

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
		position_offset=Vector2(real_var.position_x,real_var.position_y)
		for i in range(real_var.variable_name_array.size()):
			match real_var.variable_type_array[i]:
				ChatNode.variable_type.TYPE_STRING:
					var text_edit=preload("res://NodeChat/new_graph/tscn/text_edit.tscn").instantiate() as NodeChatTextInput
					text_edit.placeholder_text=real_var.variable_name_view[i]
					text_edit.node_text_changed.connect(set_variable_name.bind(real_var.variable_name_array[i]))
					var value=real_var.get(real_var.variable_name_array[i])
					if value!=null and value is String:
						text_edit.text=value
					add_child(text_edit)
				ChatNode.variable_type.TYPE_BOOL:
					var check=preload("res://NodeChat/new_graph/tscn/check_button.tscn").instantiate() as CheckButton
					check.text=real_var.variable_name_view[i]
					check.toggled.connect(set_variable_name.bind(real_var.variable_name_array[i]))
					var value=real_var.get(real_var.variable_name_array[i])
					if value!=null and value is bool:
						check.button_pressed=value
					add_child(check)
				ChatNode.variable_type.TYPE_SELECT:
					 #[[triger_type,["弹幕","房间","私聊","进入状态","退出状态"]]]
					var map_dic:Array[String]=[]
					var data=real_var.variable_type_more[i]
					var option=preload("res://NodeChat/new_graph/tscn/option_button.tscn").instantiate() as NodeChatSelect
					for j in range(data[0].size()):
						option.add_item(data[1][j])
						map_dic.append(data[0][j])
					option.map_dic=map_dic
					option.tab_select.connect(set_variable_name.bind(real_var.variable_name_array[i]))
					add_child(option)
					option.select(map_dic.find(real_var.get(real_var.variable_name_array[i])))
		var need_port_num:int=max(real_var.input_port_array.size(),real_var.output_port_array.size())
		if need_port_num-real_var.variable_name_array.size()>0:
			for i in range(need_port_num-real_var.variable_name_array.size()):
				var new_control=preload("res://NodeChat/new_graph/tscn/space.tscn").instantiate()
				add_child(new_control)
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
		title=real_var.mod_node+real_var.id
		name=real_var.id


func set_variable_name(value,n:String):
	if real_var!=null and real_var.get(n)!=null:
		real_var.set(n,value)
	pass
