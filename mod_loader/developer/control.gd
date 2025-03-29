extends Control
const ADD_PLUGIN_MES = preload("res://mod_loader/developer/add_plugin_mes.tscn")
const ADD_VERSION_MES = preload("res://mod_loader/developer/add_version_mes.tscn")
const UPDATE_PLUGIN_MES = preload("res://mod_loader/developer/update_plugin_mes.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if AuthorAccount.has_account():
		request_author_plugin(AuthorAccount.account_data[0])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
#请求某个作者的插件列表
func request_author_plugin(author_id:String):
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.GET_AUTHOR_PLUGIN,{"id":author_id},plugin_get)

func plugin_get(is_success:bool,mes:Dictionary):
	if is_success:
		create_tree(mes)
	
	pass
var data_cache:Dictionary={}


var tree_item_and_item_dic:Dictionary={}
func create_tree(data:Dictionary):
	tree_item_and_item_dic.clear()
	%Tree.clear();
	%Tree.create_item().set_text(0,data["name"])
	var arrar:Array=data["plugin"]
	for i in arrar:
		var item:TreeItem=%Tree.create_item()
		
		item.set_text(0,i["plugin_name"])
		var plugin_id=i["plugin_id"]
		tree_item_and_item_dic[item]=Plugin.new(i["plugin_id"],i["plugin_name"],i["author_id"],i["introduction"])
		var version:Dictionary=i["version"]
		for j in version.keys():
			var version_item:TreeItem=%Tree.create_item(item)
			version_item.set_text(0,j)
			tree_item_and_item_dic[version_item]=Version.new(j,version[j]["path"],plugin_id,version[j]["package_name"])
		pass
	
	
	pass


func _on_add_plugin_pressed() -> void:
	if AuthorAccount.has_account():
		var new_window=ADD_PLUGIN_MES.instantiate()
		add_child(new_window)
		new_window.create_plugin.connect(request_create_new_plugin)
		new_window.popup()
	else:
		$DrawerContainer.change_open()
		Toast.popup("你还没有账户！")
	pass # Replace with function body.

#当弹出框要求创建新插件时触发
func request_create_new_plugin(plugin_name:String,plugin_introduction:String):
	#检测用户存不存在账户
	if AuthorAccount.has_account():
		#发送请求
		AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.CREATE_PLUGIN,{
			"author_id":AuthorAccount.account_data[0],
			"password":AuthorAccount.account_data[1].md5_text(),
			"plugin_name":plugin_name,
			"introduction":plugin_introduction
		},create_plugin_request_complete)
		


func create_plugin_request_complete(is_success:bool,data:Dictionary):
	if is_success:
		request_author_plugin(AuthorAccount.account_data[0])


func _on_tree_item_selected() -> void:
	var selected_item=%Tree.get_selected()
	if selected_item!=null and selected_item in tree_item_and_item_dic.keys():
		var item=tree_item_and_item_dic[selected_item]
		if item is Plugin:
			print("选中插件")
			pass
		elif item is Version:
			
			print("选中版本")
			pass
		
		
		pass
	pass # Replace with function body.


func _on_tree_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_right"):
		var item=%Tree.get_item_at_position(%Tree.get_local_mouse_position())
		if item in tree_item_and_item_dic.keys():
			%Tree.set_selected(item,0)
			var real_item=tree_item_and_item_dic[item]
			
			var mouse_position=get_global_mouse_position()
			var window_pos=Vector2i(mouse_position.x,mouse_position.y)+get_window().position
			if real_item is Plugin:
				#弹出插件右键菜单
				%plugin_menu.position=window_pos
				%plugin_menu.popup()
				pass
			elif real_item is Version:
				%version_menu.position=window_pos
				%version_menu.popup()
				#弹出版本右键菜单
				
				pass
		else:
			var mouse_position=get_global_mouse_position()
			var window_pos=Vector2i(mouse_position.x,mouse_position.y)+get_window().position
			%fresh_menu.position=window_pos
			%fresh_menu.popup()
			%fresh_menu.size.x=150
	pass # Replace with function body.


func _on_version_menu_id_pressed(id: int) -> void:
	match id:
		0:
			
			pass
		1:
			var version:Version=tree_item_and_item_dic[%Tree.get_selected()]
			generate_new_confirm('你确定要删除插件版本"'+version.version_name+'"吗？',
			func():
				AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.DELETE_VERSION,
				{
					"author_id":AuthorAccount.account_data[0],
					"password":AuthorAccount.account_data[1].md5_text(),
					"plugin_id":version.plugin_id,
					"version":version.version_name
				},
				func(is_success:bool,data:Dictionary):
					if is_success:
						Toast.popup("删除成功")
					else:
						Toast.popup("出现错误")
					fresh()
					
				)
			)

func _on_plugin_menu_id_pressed(id: int) -> void:
	match id:
		0:
			var new_window=ADD_VERSION_MES.instantiate()
			add_child(new_window)
			new_window.set_plugin(tree_item_and_item_dic[%Tree.get_selected()])
			new_window.create_plugin_version.connect(create_plugin_version_request)
			new_window.popup()
			pass
			pass
		1:
			
			
			pass
		
		
		2:
			var new_window=UPDATE_PLUGIN_MES.instantiate()
			add_child(new_window)
			new_window.set_plugin(tree_item_and_item_dic[%Tree.get_selected()])
			new_window.update_pluign_mes.connect(update_plugin_mes_request)
			new_window.popup()
			
			
			pass
		
	pass # Replace with function body.

func create_plugin_version_request(plugin:Plugin,version_name:String,file_path:String,package_name:String):
	if file_path.begins_with("mod:"):
		var mod_name=file_path.right(file_path.length()-4)
		if ModLoader.has_mod(mod_name):
			var mod_path=ModLoader.get_mod_path(mod_name)
			var path_cache=mod_path
			if path_cache.ends_with("/"):
				path_cache=path_cache.left(path_cache.length()-1)
			var file_name=path_cache.get_base_dir()+"/"+path_cache.get_file()+".zip"
			Zip.start_mission("正在打包插件",Zip.Type.ZIP,mod_path,file_name,create_plugin_version_request.bind(package_name).bind(file_name).bind(version_name).bind(plugin))
			pass
	else:
		if AuthorAccount.has_account():
			var data={}
			data["author_id"]=AuthorAccount.account_data[0]
			data["password"]=AuthorAccount.account_data[1].md5_text()
			data["plugin_id"]=plugin.plugin_id
			data["version"]=version_name
			data["package_name"]=package_name
			var f=FileAccess.open(file_path,FileAccess.READ)
			if f!=null:
				data["file"]=f.get_buffer(f.get_length())
				AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.UPLOAD_VERSION,data,upload_version_callback)
			else:
				Toast.popup("出现错误！")

func update_plugin_mes_request(plugin:Plugin,new_plugin_name:String,new_plugin_introduction:String):
	
	
	pass


func upload_version_callback(is_success:bool,data:Dictionary):
	fresh()
	print(data)
	
	pass
	



#生成确认对话框
func generate_new_confirm(text:String,accept_call=null,refuse_call=null):
	var res=ConfirmationDialog.new()
	var accept_function=func(accept_call,node):
			if accept_call is Callable and accept_call.is_valid():
				accept_call.call()
			node.queue_free()
	var refuse_function=func(refuse_call,node):
			if refuse_call is Callable and refuse_call.is_valid():
				refuse_call.call()
			node.queue_free()
	res.confirmed.connect(accept_function.bind(res).bind(accept_call))
	res.canceled.connect(refuse_function.bind(res).bind(refuse_call))
	
	res.cancel_button_text="取消"
	res.ok_button_text="确定"
	
	res.dialog_text=text
	add_child(res)
	res.popup_centered()
	pass


#进行http请求以刷新列表
func fresh():
	if AuthorAccount.has_account():
		request_author_plugin(AuthorAccount.account_data[0])


func _on_fresh_menu_id_pressed(id: int) -> void:
	match id:
		0:
			fresh()
	pass # Replace with function body.
