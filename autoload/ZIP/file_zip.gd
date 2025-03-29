extends Node
##用来将一个文件夹中所有内容压缩到指定压缩文件目录的节点
class_name FileZip
##用来执行压缩的线程
var zip_thread:Thread
##需要压缩的文件数目
var max_zip_index:int=0
##当前已经写入的文件压缩数目
var now_zip_index:int=0
##扫描出的需要压缩的所有文件大小（字节）
var max_file_size:int=0
##当前已经压缩的文件大小（字节）
var now_file_size:int=0
##提示信息
var tips:String=""
enum State{
	##空闲状态
	STATE_FREE=0,
	##正在扫描文件和文件夹
	STATE_SCANNING=1,
	##正在读取写入压缩文件
	STATE_READ_AND_WRITE_FILE=2,
}
##现在的状态
var state:State=State.STATE_FREE
##压缩结束后发出的信号，res为是否成功
signal finish(res:bool)

##要求线程销毁的通信变量
var request_thread_stop:bool=false
##开始压缩，dir_origin为源文件夹，file_zip为压缩后的文件路径
func start_zip(dir_origin:String,file_zip:String):
	if zip_thread!=null or state!=State.STATE_FREE:
		print("当前正在使用中！")
		return 
	request_thread_stop=false
	zip_thread=Thread.new()
	zip_thread.start(zip_dir_thread.bindv([dir_origin,file_zip]))
##要求停止压缩，扫描过程中无法停止，压缩过程中会在要求停止后完成一个文件的写入后停止并销毁压缩文件
func stop_zip():
	request_thread_stop=true
##扫描和压缩线程函数
func zip_dir_thread(dir_origin:String,file_zip:String)->bool:
	call_thread_safe("set","now_zip_index",0)
	var finish_files:int=0
	#打开源目录
	var dir=DirAccess.open(dir_origin)
	if dir==null:
		push_error("要求压缩的文件夹路径不合法")
		return false
	var zip_packer=ZIPPacker.new()
	var err=zip_packer.open(file_zip)
	if err!=OK:
		push_error("要求生成的压缩文件的路径不合法")
		return false
	call_thread_safe("set","state",State.STATE_SCANNING)
	var res:Array=find_all_files(dir_origin)
	var dirs=res[1]
	var files=res[0]
	var size:int=res[2]
	var zipped_size:int=0
	print("扫描完成,文件："+str(files.size())+" 文件夹："+str(dirs.size())+" 文件总大小："+str(size/int(1048576))+"mb")
	call_thread_safe("set","state",State.STATE_READ_AND_WRITE_FILE)
	call_thread_safe("set","max_zip_index",files.size())
	call_thread_safe("set","max_file_size",size)
	var base_dir_length=dir_origin.length()
	for i in files:
		if request_thread_stop:
			call_thread_safe("set","request_thread_stop",false)
			zip_packer.close()
			DirAccess.remove_absolute(file_zip)
			return false
		var remove_base_dir:String=i.right(i.length()-base_dir_length)
		zip_packer.start_file(remove_base_dir)
		var f=FileAccess.open(i,FileAccess.READ)
		if f==null:
			print("打开文件失败："+i)
			zip_packer.close_file()
			zip_packer.close()
			DirAccess.remove_absolute(file_zip)
			return false
		var length=f.get_length()
		var buffer:PackedByteArray=f.get_buffer(length)
		f.close()
		zip_packer.write_file(buffer)
		zip_packer.close_file()
		finish_files+=1
		zipped_size+=length
		call_thread_safe("set","now_zip_index",finish_files)
		call_thread_safe("set","now_file_size",zipped_size)
		call_thread_safe("set","tips",i)
	zip_packer.close()
	return true
	pass

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

##获取当前根据文件数目计算的进度，0-1
func get_progress_index()->float:
	if max_zip_index==0:
		return 0
	else:
		return float(now_zip_index)/float(max_zip_index)
##获取当前根据文件大小计算的进度，0-1
func get_progress_size()->float:
	if max_file_size==0:
		return 0
	else:
		return float(now_file_size)/float(max_file_size)
	
	
	pass
func get_progress()->float:
	if max_file_size==0:
		return 0
	else:
		return float(now_file_size)/float(max_file_size)
	
	
	pass
func _process(delta: float) -> void:
	if zip_thread!=null:
		if not zip_thread.is_alive():
			var res=zip_thread.wait_to_finish()
			zip_thread=null
			state=State.STATE_FREE
			finish.emit(res)
			max_zip_index=0
			now_zip_index=0
			max_file_size=0
			now_file_size=0

	pass
