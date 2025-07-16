extends Node



var nodeset_download_path:String="user://"
@export var file_messege:String="user://file_mes.txt"
signal node_set_update
var data_cache:Array=[]
#持有实例的字典
var nodeset_instance_cache:Dictionary[String,NodeRoot]={}
func _ready() -> void:
	nodeset_download_path=OS.get_executable_path().get_base_dir()+"/nodeset"
	file_messege=OS.get_executable_path().get_base_dir()+"/file_mes.txt"
	reload()
#将数据保存到字典
func save():
	var js=JSON.stringify(data_cache)
	var f=FileAccess.open(file_messege,FileAccess.WRITE)
	if f !=null:
		f.store_string(js)
		f.close()
#添加nodeset记录
func add_nodeset(file_path:String):
	if not data_cache.has(file_path):
		data_cache.push_back(file_path)
		save()
		node_set_update.emit()
func delete_nodeset(file_path:String):
	if data_cache.has(file_path):
		data_cache.pop_at(data_cache.find(file_path))
		save()
		node_set_update.emit()
	if has_instance(file_path):
		stop_instance(file_path)

func has_nodeset(path:String)->bool:
	return data_cache.has(path)




#获取全部节点集合信息
func get_all_nodeset_mes()->Array:
	return data_cache

func has_instance(path:String)->bool:
	return nodeset_instance_cache.has(path)
func stop_instance(path:String):
	if has_instance(path):
		var instance:NodeRoot=nodeset_instance_cache[path]
		instance.delete()
		nodeset_instance_cache.erase(path)
		node_set_update.emit()
	
	pass
func open_instance(path:String):
	stop_instance(path)
	if has_nodeset(path):
		var f=FileAccess.open(path,FileAccess.READ)
		if f!=null:
			var str=f.get_as_text()
			var res=Serializater.parse_string(str)
			if res!=null:
				nodeset_instance_cache[path]=res
				res.start()
		node_set_update.emit()



func reload():
	#如果没有文件，则创建并写入空数组
	var f=FileAccess.open(file_messege,FileAccess.READ)
	if f==null:
		f=FileAccess.open(file_messege,FileAccess.WRITE)
		f.store_string("[]")
		f.close()
	else:
		var str=f.get_as_text()
		var js=JSON.parse_string(str)
		if js is Array:
			data_cache=js
		else:
			f.close()
			f=FileAccess.open(file_messege,FileAccess.WRITE)
			f.store_string("[]")
			f.close()
		f.close()
	node_set_update.emit()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	for i in nodeset_instance_cache.values():
		i.judge()
	pass # Replace with function body.



#在目录下生成新的用户名
func get_new_nodeset_download_path(origin_name:String,backend:String):
	if not FileAccess.file_exists(nodeset_download_path+"/"+origin_name+backend):
		
		return nodeset_download_path+"/"+origin_name+backend
	var index=0
	while FileAccess.file_exists(nodeset_download_path+"/"+origin_name+"_"+str(index)+backend):
		
		index+=1
	return nodeset_download_path+"/"+origin_name+"_"+str(index)+backend
