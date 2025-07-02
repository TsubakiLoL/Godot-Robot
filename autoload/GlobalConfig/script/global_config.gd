#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends Node
var config_file:String=""
func _ready() -> void:
	config_file=OS.get_executable_path().get_base_dir()+"/config.cfg"
	if not FileAccess.file_exists(config_file):
		var f=FileAccess.open(config_file,FileAccess.WRITE)
		f.close()
func read_config_value(section_name:String,value_name:String,defaule_value):
	var config=ConfigFile.new()
	var err=config.load(config_file)
	if err!=OK:
		return null
	return config.get_value(section_name,value_name,defaule_value)
func write_config_value(section_name:String,value_name:String,value):
	if not FileAccess.file_exists(config_file):
		var f=FileAccess.open(config_file,FileAccess.WRITE)
		f.close()
	var config=ConfigFile.new()
	var err=config.load(config_file)
	if err!=OK:
		return
	config.set_value(section_name,value_name,value)

	
