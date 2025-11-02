#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------


extends Node
var data:Dictionary={}
var data_list_cache:Array[String]=[]
var data_list_type_cache:Array[String]=[]
func add_data(key:String,type:String,value):
	data[key]=value
	data_list_cache.append(key)
	data_list_type_cache.append(type)
func set_data(key:String,value):
	if has_data(key):
		data[key]=value
func has_data(key:String)->bool:
	if key in data_list_cache:
		return true
	else:
		return false
func get_data_type(key)->String:
	if has_data(key):
		return data_list_type_cache[data_list_cache.find(key)]
	else:
		return ""
	
	pass
func delete_data(key:String)->bool:
	if key in data_list_cache:
		var index=data_list_cache.find(key)
		data_list_cache.remove_at(index)
		data_list_type_cache.remove_at(index)
		data.erase(key)
		return true
	else:
		return false
func get_data_list()->Array:
	return data_list_cache
