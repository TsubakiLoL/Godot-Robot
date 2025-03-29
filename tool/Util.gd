class_name Util


#返回可执行文件同级目录
static func get_exe_path():
	
	return OS.get_executable_path().get_base_dir()
