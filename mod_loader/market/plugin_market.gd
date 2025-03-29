extends Control
const MARKET_ITEM_MONO = preload("res://mod_loader/market/res/market_item_mono.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if download_addr_handle!="":
		%download_progress_box.show()
		if AuthorAccount.is_download_exists(download_addr_handle):
			var progress_arr=AuthorAccount.get_download_progress(download_addr_handle)
			%download_label.text=str(progress_arr[0])+"/"+str(progress_arr[1])
			%download_progress.max_value=progress_arr[1]
			%download_progress.value=progress_arr[0]
			pass
		else:
			download_addr_handle=""
	else:
		%download_progress_box.hide()
	pass


func _on_search_input_text_submitted(new_text: String) -> void:
	if new_text!="":
		
		AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.GET_PLUGIN
		,{
			"content":new_text
		},
		plugin_list_get
		)
		
		open_load()
		
		pass
	pass # Replace with function body.


func _on_search_pressed() -> void:
	var text=%search_input.text
	_on_search_input_text_submitted(text)
	pass # Replace with function body.

#获取到搜索结果队列时触发
func plugin_list_get(is_success:bool,data:Dictionary):
	if is_success:
		for i in %item.get_children():
			i.queue_free()
		var plugin_arr:Array=data["plugin"]
		for i in plugin_arr:
			var new_plugin=MARKET_ITEM_MONO.instantiate()
			%item.add_child(new_plugin)
			new_plugin.set_data(i)
			new_plugin.click.connect(item_click)
			
	close_load()
	pass
func item_click(data:Dictionary):
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.GET_PLUGIN_MES,{
		"plugin_id":data["plugin_id"]
	},get_plugin_mes)
	
	open_mes_load()
	pass
var plugin_mes_cache:Dictionary={}
#当获取到插件详细信息时触发
func get_plugin_mes(is_success:bool,data:Dictionary):
	if is_success:
		%plugin_v.clear()
		plugin_mes_cache=data
		var version_list:Dictionary=data["version"]
		%plugin_name.text=data["plugin_name"]
		%plugin_introduction.text=data["introduction"]
		for i in version_list.keys():
			%plugin_v.add_item(i)
		if version_list.size()==0:
			%plugin_v.hide()
			%download_plugin.hide()
		else:
			%download_plugin.show()
			%plugin_v.show()
			%plugin_v.select(0)
			pass
		close_mes_load()
		update_now_select_version()
	pass

func open_load():
	%load_animation.show()
	%animation.play("load")
	%item_add_pos.hide()
	for i in %item.get_children():
		i.queue_free()
func close_load():
	%load_animation.hide()
	%animation.stop()
	%item_add_pos.show()


func open_mes_load():
	%plugin_mes_panel.show()
	%mes_panel.hide()
	%load_animation_mes.show()
	%mes_load_animation.play("load")
	
	
	pass

func close_mes_load():
	%mes_panel.show()
	%load_animation_mes.hide()
	%mes_load_animation.stop()
	
	pass
func version_click(id:int):
	%plugin_version.text=%plugin_version.get_popup().get_item_text(id)

#当前持有的下载链接（用于进行帧进度更新）
var download_addr_handle:String=""
#更新持有的下载链接
func update_now_select_version():
	download_addr_handle=""
	if plugin_mes_cache.has("version"):
		var version_list:Dictionary=plugin_mes_cache["version"]
		if %plugin_v.selected==-1:
			return
		var version_name=%plugin_v.get_item_text(%plugin_v.selected)
		if not version_list.has(version_name):
			return
		var package_name=version_list[version_name]["package_name"]
		if ModLoader.has_mod(package_name):
			%download_plugin.text="已下载"
			%download_plugin.disabled=true
			pass
		else:
			%download_plugin.text="下载"
			%download_plugin.disabled=false
			
			pass
		download_addr_handle=version_list[version_name]["path"]
		
		pass
	else:
		%download_progress_box.hide()


func _on_download_plugin_pressed() -> void:
	if plugin_mes_cache.has("version"):
		var version_list:Dictionary=plugin_mes_cache["version"]
		if %plugin_v.selected==-1:
			return
		var version_name=%plugin_v.get_item_text(%plugin_v.selected)
		if not version_list.has(version_name):
			return
		var path=version_list[version_name]["path"]
		AuthorAccount.request_download_file(ModLoader.load_path,path,
		func(is_success:bool,download_path:String):
			if is_success:
				var dir=download_path.get_basename()
				if DirAccess.dir_exists_absolute(dir):
					return
				var err=DirAccess.make_dir_absolute(dir)
				if err!=OK:
					return
				Zip.start_mission("解压插件中",Zip.Type.UNZIP,download_path,download_path.get_basename(),ModLoader.reload)
			else:
				Toast.popup("下载失败")
			)
	
	
	update_now_select_version()
	pass # Replace with function body.


func _on_plugin_v_item_selected(index: int) -> void:
	update_now_select_version()
	pass # Replace with function body.
