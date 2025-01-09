#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



@tool
extends Container
##抽屉容器节点，可以用于将子节点侧滑，开启clip content可以做到完全隐藏子节点
class_name DrawerContainer
##按钮大小
@export var custom_button_size:Vector2=Vector2.ZERO:
	set(val):
		custom_button_size=val
		side_button_size_changed()
		fit_children()
		fit_side_button()
var button_size:Vector2=Vector2(100,200):
	set(val):
		button_size=val
		fit_children()
		fit_side_button()
##按钮场景，根节点必须为basebutton或继承自basebutton，留空则使用默认按钮
@export var button_tscn:PackedScene
##布局模式
@export var button_model:BUTTON_MODEL=BUTTON_MODEL.TOP
enum BUTTON_MODEL{
	##按钮在上方,向下收纳
	TOP=0,
	##按钮在下方，向上收纳
	END=1,
	##按钮在左方，向右收纳
	LEFT=2,
	##按钮在右方，向左收纳
	RIGHT=3,
}
##是否禁用按钮
@export var disable_button:bool=false:
	set(val):
		disable_button=val
		fit_side_button()
		fit_side_button()
		if side_button!=null:
			if val :
				side_button.hide()
			else:
				side_button.show()
##动画过渡模式
@export var animation_model:Tween.TransitionType=Tween.TransitionType.TRANS_BACK
##当前持有的动画
var now_keep_tween:Tween
##当前是否打开
@export var is_open:bool=true
##持有的抽屉控制按钮的实例（内部节点）
var side_button:BaseButton

##获取当前持有的侧边按钮
func get_side_button()->BaseButton:
	return side_button
	
##当前动画状态，0为完全打开，1为完全关闭
var rag:float=0:
	set(val):
		rag=val
		fit_side_button()
		fit_children()

func _ready() -> void:
	if is_open:
		rag=0
	else:
		rag=1
	if button_tscn!=null:
		var new_btn=button_tscn.instantiate()
		if new_btn is BaseButton:
			side_button=new_btn
			add_child(new_btn,false,Node.INTERNAL_MODE_FRONT)
		else:
			new_btn=Button.new()
			side_button=new_btn
			add_child(new_btn,false,Node.INTERNAL_MODE_FRONT)
	else:
		var new_btn=Button.new()
		side_button=new_btn
		add_child(new_btn,false,Node.INTERNAL_MODE_FRONT)
	side_button.pressed.connect(change_open)
	side_button.minimum_size_changed.connect(side_button_size_changed)
	side_button_size_changed()
	if disable_button:
		side_button.hide()
	resized.connect(resize)
	resize()
	_re_ready()
	pass # Replace with function body.
##因为占用了ready函数，所以留了一个新的虚函数给使用节点重写
func _re_ready()->void:
	
	
	
	pass
##对侧边栏按钮进行适配
func fit_side_button()->void:
	var rect:Rect2
	if side_button!=null:
		match  button_model:
			BUTTON_MODEL.TOP:
				rect=Rect2(0,(size.y-button_size.y)*rag,size.x,button_size.y)
			BUTTON_MODEL.END:
				rect=Rect2(0,(size.y-button_size.y)*(1-rag),size.x,button_size.y)
			BUTTON_MODEL.LEFT:
				rect=Rect2((size.x-button_size.x)*rag,0,button_size.x,size.y)
			BUTTON_MODEL.RIGHT:
				rect=Rect2((size.x-button_size.x)*(1-rag),0,button_size.x,size.y)
			
			_:
				rect=Rect2()
		fit_child_in_rect(side_button,rect)
##对子节点进行适配
func fit_children()->void:
	var rect:Rect2
	if !disable_button:
		match  button_model:
			BUTTON_MODEL.TOP:
				rect=Rect2(0,(size.y-button_size.y)*rag+button_size.y,size.x,size.y-button_size.y)
			BUTTON_MODEL.END:
				rect=Rect2(0,(size.y-button_size.y)*(-rag),size.x,size.y-button_size.y)
			BUTTON_MODEL.LEFT:
				rect=Rect2((size.x-button_size.x)*rag+button_size.x,0,size.x-button_size.x,size.y)
			BUTTON_MODEL.RIGHT:
				rect=Rect2((size.x-button_size.x)*(-rag),0,size.x-button_size.x,size.y)
			_:
				rect=Rect2()
	else:
		match  button_model:
			BUTTON_MODEL.TOP:
				rect=Rect2(0,(size.y)*rag+button_size.y,size.x,size.y)
			BUTTON_MODEL.END:
				rect=Rect2(0,(size.y)*(-rag),size.x,size.y)
			BUTTON_MODEL.LEFT:
				rect=Rect2((size.x)*rag,0,size.x,size.y)
			BUTTON_MODEL.RIGHT:
				rect=Rect2((size.x)*(-rag),0,size.x,size.y)
			_:
				rect=Rect2()
		
		
		pass
	for i in get_children():
		if i is Control:
			fit_child_in_rect(i,rect)

##更改窗口的开闭状态，使用动画
func change_open():
	if now_keep_tween!=null:
		now_keep_tween.kill()
	if is_open:
		now_keep_tween=get_tree().create_tween()
		now_keep_tween.set_trans(animation_model)
		now_keep_tween.tween_property(self,"rag",1,0.2)
	else:
		now_keep_tween=get_tree().create_tween()
		now_keep_tween.set_trans(animation_model)
		now_keep_tween.tween_property(self,"rag",0,0.2)
	is_open=!is_open

	
	
	pass
##当此节点大小改变时触发
func resize():
	fit_side_button()
	fit_children()
##重写的虚函数，用于获取当前节点的最小大小
func _get_minimum_size() -> Vector2:
	var res:Vector2=Vector2.ZERO
	
	for i in get_children():
		if i is Control:
			var i_size:Vector2=i.get_minimum_size()
			res=Vector2(max(res.x,i_size.x),max(res.y,i_size.y))
	if !disable_button:
		match button_model:
			BUTTON_MODEL.TOP:
				res=Vector2(max(res.x,button_size.x),res.y+button_size.y)
			BUTTON_MODEL.END:
				res=Vector2(max(res.x,button_size.x),res.y+button_size.y)
			BUTTON_MODEL.LEFT:
				res=Vector2(res.x+button_size.x,max(res.y,button_size.y))
			BUTTON_MODEL.RIGHT:
				res=Vector2(res.x+button_size.x,max(res.y,button_size.y))
			_:
				res=Vector2.ZERO
	
	return res
##当侧边栏按钮大小更改时调用
func side_button_size_changed()->void:
	if side_button:
		var new_size=side_button.get_minimum_size()
		button_size=Vector2(max(custom_button_size.x,new_size.x),max(custom_button_size.y,new_size.y))
