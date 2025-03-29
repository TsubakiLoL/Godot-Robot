extends Node
class_name FileUnzip
##提示信息
var tips:String=""

enum State{
	##空闲状态
	STATE_FREE=0,
	##正在读取写入压缩文件
	STATE_READ_AND_WRITE_FILE=2,
}
##现在的状态
var state:State=State.STATE_FREE


var zip_thread

var request_thread_stop:bool=false
##压缩结束后发出的信号，res为是否成功
signal finish(res:bool)
func start_unzip(from_file:String,to_file:String):
	var path=to_file
	if not path.ends_with("/"):
		path+="/"
	if zip_thread!=null or state!=State.STATE_FREE:
		print("当前正在使用中！")
		return 
	request_thread_stop=false
	zip_thread=Thread.new()
	zip_thread.start(read_zip_file.bindv([from_file,path]))
	
	
	pass


#该类实现了一个可以提取 zip 存档中各个文件内容的读取器。

func read_zip_file(path:String,to_file:String)->bool:
	
	var file_root=to_file
	file_root=file_root.replace(":\\","://")
	file_root=file_root.replace("\\","/")
	
	var dir=DirAccess.open(file_root)
	if dir==null:
		print("文件夹不存在")
		print(file_root)
		return false
	var reader := ZIPReader.new()
	var err := reader.open(path)
	if err != OK:
		return false
	var files=reader.get_files()
	print(files)
	call_thread_safe("set","max_file_size",files.size())
	var now_file_size:int=0
	for i in files:
		now_file_size+=1
		var dir_path:String=""
		if i.ends_with("/"):
			dir_path=(file_root+i)
		else:
			dir_path=(file_root+i).get_base_dir()
		call_thread_safe("set","tips",i)
		print(dir_path)
		err=DirAccess.make_dir_recursive_absolute(dir_path)
		if err!=OK:
			print("创建文件夹失败",dir_path)
			print(err)
			return false
		if not i.ends_with("/"):
			print("尝试创建文件:"+file_root+i)
			var f=FileAccess.open((file_root+i),FileAccess.WRITE)
			if f==null:
				print("创建文件失败",file_root+i)
				print(FileAccess.get_open_error())
				return false
			var data=reader.read_file(i)
			f.store_buffer(data)
		call_thread_safe("set","now_file_size",now_file_size)
		pass
	reader.close()
	
	
	return true
var max_file_size:int=0
var now_file_size:int=0
func _process(delta: float) -> void:
	if zip_thread!=null:
		if not zip_thread.is_alive():
			var res=zip_thread.wait_to_finish()
			zip_thread=null
			state=State.STATE_FREE
			finish.emit(res)
			max_file_size=0
			now_file_size=0
	pass

func get_progress():
	return float(now_file_size)/float(max_file_size)
