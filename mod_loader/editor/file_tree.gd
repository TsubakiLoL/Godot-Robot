extends Tree
#加载文件夹结构的根路径
@export var root_path:String
const DIR_ICON = preload("res://mod_loader/editor/res/dir_icon.png")
const FILE_ICON = preload("res://mod_loader/editor/res/file_icon.png")
signal file_selected(global_path:String)
signal dir_selected(globla_path:String)
func _ready() -> void:
	#self.hide_root=true
	root_path="user://mod/iirose"
	reload()
	

var tree_cache_file:Dictionary={}
var tree_cache_dir:Dictionary={}
func reload(regex_text:String=""):
	tree_cache_dir.clear()
	tree_cache_file.clear()
	clear()
	var root=create_item()
	tree_cache_dir[root]=root_path
	root.set_icon(0,DIR_ICON)
	root.set_text(0,root_path)
	var dir := DirAccess.open(root_path)
	var file_name := ""
	if dir:
		var dir_arr:Array[DirAccess]=[dir]
		var dir_tree_item:Array[TreeItem]=[root]
		dir.list_dir_begin()
		
		while dir_arr.size()!=0:
			file_name=dir_arr.back().get_next()
			if file_name=="":
				
				dir_tree_item.back().set_collapsed(true)
				dir_tree_item.pop_back()
				dir_arr.back().list_dir_end()
				dir_arr.pop_back()
				continue
			if dir_arr.back().current_is_dir():
				
				var new_dir_tree_item=create_item(dir_tree_item.back())
				new_dir_tree_item.set_icon(0,DIR_ICON)
				new_dir_tree_item.set_text(0,file_name)
				
				dir_tree_item.append(new_dir_tree_item)
				var new_dir_path:String=dir_arr.back().get_current_dir()+"/"+file_name
				var new_dir=DirAccess.open(dir_arr.back().get_current_dir()+"/"+file_name)
				tree_cache_dir[new_dir_tree_item]=new_dir_path
				new_dir.list_dir_begin()
				dir_arr.append(new_dir)
			else:
				var new_dir_tree_item=create_item(dir_tree_item.back())
				new_dir_tree_item.set_icon(0,FILE_ICON)
				new_dir_tree_item.set_text(0,file_name)
				var new_file_path:String=dir_arr.back().get_current_dir()+"/"+file_name
				tree_cache_file[new_dir_tree_item]=new_file_path
		dir.list_dir_end()
	else:
		print("Failed to open:"+root_path)
##扫描一个目录下的所有文件和文件夹
func find_all_files(path:String)->Array:
	var size_index:int=0
	var file_name := ""
	var files :Array[String]= []
	var dirs:Array[String]=[]
	var dir := DirAccess.open(path)
	if dir:
		var dir_arr:Array[DirAccess]=[dir]
		dir.list_dir_begin()
		while dir_arr.size()!=0:
			file_name=dir_arr.back().get_next()
			if file_name=="":
				dir_arr.back().list_dir_end()
				dir_arr.pop_back()
				continue
			if dir_arr.back().current_is_dir():
				var new_dir_path:String=dir_arr.back().get_current_dir()+"/"+file_name
				var new_dir=DirAccess.open(dir_arr.back().get_current_dir()+"/"+file_name)
				dirs.push_back(dir_arr.back().get_current_dir()+"/"+file_name)
				new_dir.list_dir_begin()
				dir_arr.append(new_dir)
			else:
				var new_file_path:String=dir_arr.back().get_current_dir()+"/"+file_name
				var f=FileAccess.open(new_file_path,FileAccess.READ)
				size_index+=f.get_length()
				f.close()
				files.push_back(new_file_path)
		dir.list_dir_end()
	else:
		print("Failed to open:"+path)
	return [files,dirs,size_index]


func _on_item_selected() -> void:
	var item=get_selected()
	if item!=null:
		if tree_cache_file.has(item):
			file_selected.emit(tree_cache_file[item])
		if tree_cache_dir.has(item):
			dir_selected.emit(tree_cache_dir[item])
	pass # Replace with function body.


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_right"):
		var item=get_selected()
		if item==null:
			return
		if tree_cache_dir.has(item):
			var path:String=tree_cache_dir[item]
			popup_right_window(path)
			pass
		elif tree_cache_file.has(item):
			var path:String=tree_cache_file[item]
			popup_right_window(path)
			pass

	pass # Replace with function body.

##弹出右键菜单
func popup_right_window(path:String):
	%menu.position=Vector2i(get_global_mouse_position())+get_tree().root.position
	%menu.popup()
	pass


func _on_popup_menu_id_pressed(id: int) -> void:
	print(id)
	match id:
		0:
			new_file()
		1:
			new_dir()
			
		2:
			delete()
	pass # Replace with function body.
func get_now_dir()->Array:
	var item=get_selected()
	if item==null:
		return[false]
	if tree_cache_dir.has(item):
		var path:String=tree_cache_dir[item]
		return[true,0,path]
		pass
	elif tree_cache_file.has(item):
		var path:String=tree_cache_file[item]
		return [true,1,path]
	else:
		return [false]

func delete():
	var res=get_now_dir()
	if not res[0]:
		return
	if res[1]==0:
		#目录
		OS.move_to_trash(ProjectSettings.globalize_path(res[2]))
		pass
	else:
		#文件
		OS.move_to_trash(ProjectSettings.globalize_path(res[2]))
	reload()
#弹出输入框的模式
var mode_cache:int=-1
func new_dir():
	%input.title="新文件夹"
	mode_cache=0
	%input.popup()

func new_file():
	%input.title="新文件"
	mode_cache=1
	%input.popup()


func _on_input_popup_hide() -> void:
	#清空模式
	mode_cache=-1
	pass # Replace with function body.


func _on_input_finish_pressed() -> void:
	var input_line:String=%line_input.text
	%line_input.text=""
	if not input_line.is_valid_filename():
		Toast.popup("名称不合法！")
		return
	if mode_cache==-1:
		return
	var res=get_now_dir()
	if not res[0]:
		Toast.popup("当前未选中路径！")
		return
	match mode_cache:
		0:
			var path:String=res[2]
			if res[1]!=0:
				path=path.get_base_dir()
			if not path.ends_with("/"):
				path+="/"
			var dir=DirAccess.open(path)
			if dir==null:
				Toast.popup("出错")
				return
			dir.make_dir(path+input_line)
		1:
			var path:String=res[2]
			if res[1]!=0:
				path=path.get_base_dir()
			if not path.ends_with("/"):
				path+="/"
			var dir=DirAccess.open(path)
			if dir==null:
				return
			var f=FileAccess.open(path+input_line,FileAccess.WRITE)
			f.close()
	reload()
	%input.hide()
	pass # Replace with function body.
