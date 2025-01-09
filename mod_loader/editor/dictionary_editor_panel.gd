extends VBoxContainer
const DICTIONARY_EDITOR_PANEL_MONO = preload("res://mod_loader/editor/dictionary_editor_panel_mono.tscn")

@export var dic_name:String="字典名":
	set(value):
		dic_name=value
		%name.text=value

@export var file_select_root_path:String=""
#后缀名
@export var file_prefix=""

#键名缓存
var key_group:Array[String]=[]
#用于代表当前编辑的文件
var dictionary:Dictionary={}:
	set(value):
		dictionary=value
		init_from_dic()
#存储字典引用的字典
var dictionary_mono:Array[DictionaryPanelMono]=[]
func _ready() -> void:
	#初始化
	dic_name=dic_name
	dictionary=dictionary
	
	add_new_mono("test")
	add_new_mono("test2")
func _on_panel_control_pressed() -> void:
	%panel.visible=not %panel.visible
	
	pass # Replace with function body.


func _on_add_btn_pressed() -> void:
	var new_key=get_default_key()
	add_new_mono(new_key)
	dictionary[new_key]="default"
	pass # Replace with function body.
#当字典键改变时发出
func key_value_changed(before_key:String,to_key:String):
	var ind=key_group.find(before_key)
	if ind!=-1:
		key_group[ind]=to_key
	dictionary[to_key]=dictionary[before_key]
	if before_key!=to_key:
		dictionary.erase(before_key)
	update_key_group()
	#print(dictionary)
#当字典值改变时发出
func value_changed(key:String,changed_value:Dictionary):
	dictionary[key]=changed_value
	#print(dictionary)
	
	
	pass

#当键被删除时发出
func key_delete(key:String):
	var search_index:int=-1
	for i in dictionary_mono.size():
		if dictionary_mono[i].before_key==key:
			search_index=i
			dictionary_mono[i].queue_free()
	if search_index!=-1:
		dictionary_mono.pop_at(search_index)
		key_group.pop_at(key_group.find(key))
		update_key_group()
	dictionary.erase(key)
	#print(key)
	#print(dictionary)
	pass

#获取默认key
func get_default_key()->String:
	var key:String="default"
	var index:int=1
	while key+str(index) in key_group:
		index+=1
	return key+str(index)

func update_key_group():
	for i in dictionary_mono:
		i.key_group=key_group
#从字典中实例化
func init_from_dic():
	for i in %add_pos.get_children():
		i.queue_free()
		key_group.clear()
		dictionary_mono.clear()
	for i in dictionary.keys():
		add_new_mono(i,dictionary[i])
	#print(dictionary)
func add_new_mono(key:String,value={"tscn":"default","script":"default"}):
	if key in key_group:
		return
	key_group.append(key)
	var new_mono=DICTIONARY_EDITOR_PANEL_MONO.instantiate()
	new_mono.key_changed.connect(key_value_changed)
	new_mono.value_changed.connect(value_changed)
	new_mono.delete.connect(key_delete)
	new_mono.before_key=key
	dictionary_mono.append(new_mono)
	%add_pos.add_child(new_mono)
	new_mono.set_value(value)
	dictionary[key]=value
	update_key_group()
	#print(dictionary)
