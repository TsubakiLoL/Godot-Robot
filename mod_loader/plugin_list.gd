extends Control
const PLUGIN_VIEW = preload("res://mod_loader/plugin_view.tscn")

const NEW_PLUGIN = preload("res://mod_loader/new_plugin.tscn")
func _ready() -> void:
	update()
	ModLoader.mod_changed.connect(update) 

func update():
	for i in %plugin_view_add_pos.get_children():
		i.queue_free()
	var all_plugin_data=ModLoader.get_all_mod_origin_data()
	for i in all_plugin_data.values():
		var new_plugin=PLUGIN_VIEW.instantiate()
		%plugin_view_add_pos.add_child(new_plugin)
		new_plugin.set_data(i)


func _on_reload_pressed() -> void:
	ModLoader.reload()
	pass # Replace with function body.



func _on_new_mod_pressed() -> void:
	var new_plugin=NEW_PLUGIN.instantiate()
	new_plugin.accept.connect(mod_create)
	add_child(new_plugin)
	pass # Replace with function body.

func mod_create(data:Dictionary):
	var package_name:String=data["name"]
	var use_model:bool=data["use_model"]
	var model_path:String=data["model_path"]
	var name_view:String=data["name_view"]
	if use_model:
		var path:String=get_useful_path(package_name)
		DirAccess.make_dir_absolute(path)
		Zip.start_mission("解压模板",Zip.Type.UNZIP,ModLoader.get_model_path(model_path),path,
		func():
			var f=FileAccess.open(path+"/config.json",FileAccess.READ)
			var write_dic:Dictionary={
				"name":package_name,
				"name_view":name_view,
			}
			if f!=null:
				var str=f.get_as_text()
				var json=JSON.parse_string(str)
				if json is Dictionary:
					json["name"]=package_name
					json["name_view"]=name_view
					write_dic=json
				f.close()
			f=FileAccess.open(path+"/config.json",FileAccess.WRITE)
			if f!=null:
				f.store_string(JSON.stringify(write_dic))
				f.close()
			ModLoader.reload()
			
			
			pass
		
		)
		pass
	else:
		var config_dic:Dictionary={
			"name":package_name,
			"name_view":name_view,
			
		}
		var path:String=get_useful_path(package_name)
		DirAccess.make_dir_absolute(path)
		var f=FileAccess.open(path+"/config.json",FileAccess.WRITE)
		if f!=null:
			f.store_string(JSON.stringify(config_dic))
			f.close()
		ModLoader.reload()
func get_useful_path(package_name:String):
	var index:int=0
	if not DirAccess.dir_exists_absolute(ModLoader.get_load_path()+package_name):
		return ModLoader.get_load_path()+package_name
	while (DirAccess.dir_exists_absolute(ModLoader.get_load_path()+package_name+str(index))):
		index+=1
	return ModLoader.get_load_path()+package_name+str(index)


func _on_open_file_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(ModLoader.load_mod_path))
	pass # Replace with function body.
