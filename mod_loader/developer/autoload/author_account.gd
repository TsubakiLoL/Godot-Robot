extends Node

var load_path:String="user://"
var account_data:Array=[]



var cache_dir:String="user://cache/"

var backend_path:String="http://8.219.243.185:9997"

func _ready() -> void:
	load_path=OS.get_executable_path().get_base_dir()
	cache_dir=OS.get_executable_path().get_base_dir()+"/cache/"
	account_data=load_account()
	judge_cache_dir()
	empty_cache()
	

func judge_cache_dir():
	if not DirAccess.dir_exists_absolute(cache_dir):
		DirAccess.make_dir_recursive_absolute(cache_dir)

func empty_cache():
	delete_dir(cache_dir)

func delete_dir(dir_path:String):
	var dir=DirAccess.open(dir_path)
	if dir!=null:
		dir.list_dir_begin()
		var file=dir.get_next()
		while(file!=""):
			if dir.current_is_dir():
				delete_dir(dir_path+"/"+file)
				print("删除文件夹："+file)
				dir.remove(file)
			else:
				print("删除文件:"+file)
				dir.remove(file)
			file=dir.get_next()
		dir.list_dir_end()
	else:
		print("清空失败")
	
	pass
func create_mod_and_nodeset_path():
	DirAccess.make_dir_recursive_absolute(cache_dir+"/Mod")
	DirAccess.make_dir_recursive_absolute(cache_dir+"/Nodeset")
	
	
	pass



#打包缓存
func pack_cache(callback):
	var path_cache=get_cache_zip_path()
	Zip.start_mission("打包缓存",Zip.Type.ZIP,cache_dir,path_cache,callback.bind(path_cache))

func get_cache_zip_path():
	var path_cache:String=cache_dir
	if path_cache.ends_with("/"):
		path_cache=path_cache.left(path_cache.length()-1)
	path_cache=path_cache.get_base_dir()+"/cache.zip"
	return path_cache
	
	

#当前是否有账户
func has_account()->bool:
	return account_data.size()==2

func load_account():
	var file_path=load_path+"/"+"developer_account"
	var f=FileAccess.open(file_path,FileAccess.READ)
	if f!=null:
		var str=f.get_as_text()
		var arr=JSON.parse_string(str)
		if arr is Array and arr.size()==2:
			return arr
		else:
			return []
	else:
		return []


func add_account(_account_data:Array):
	if not _account_data.size()==2:
		return
	var file_path=load_path+"/"+"developer_account"
	account_data=_account_data
	var f=FileAccess.open(file_path,FileAccess.WRITE)
	f.store_string(JSON.stringify(account_data))
	f.close()



#操作的类型
enum REQUEST_TYPE{
	AUTHOR_LOGIN=0,
	AUTHOR_SIGNUP=1,
	AUTHOR_UPDATE=2,
	GET_AUTHOR_PLUGIN=3,
	GET_PLUGIN=4,
	GET_PLUGIN_MES=5,
	CREATE_PLUGIN=6,
	UPLOAD_VERSION=7,
	DELETE_VERSION=8,
	UPDATE_PLUGIN=9,
	DELETE_PLUGIN=10,
	GET_AUTHOR_PLUGIN_AND_NODESET=11,
	CREATE_NODESET=12,
	DELETE_NODESET=13,
	SEARCH_NODESET=14,
	GET_NODESET=15,
	IMAGE_UPLOAD=16,
	INTERPRETER_UPLOAD=17,
	INTERPRETER_START=18,
	INTERPRETER_STOP=19,
	INTERPRETER_RUNNING=20,
	INTERPRETER_BLOG=21,
	INTERPRETER_INPUT=22,
	INTERPRETER_DOWNLOAD=23,
}
const REQUEST_ADDR:Dictionary[REQUEST_TYPE,String]={
	REQUEST_TYPE.AUTHOR_LOGIN:"/author/login",
	REQUEST_TYPE.AUTHOR_SIGNUP:"/author/signup",
	REQUEST_TYPE.AUTHOR_UPDATE:"/author/update",
	REQUEST_TYPE.GET_AUTHOR_PLUGIN:"/plugin/getAuthorPlugin",
	REQUEST_TYPE.GET_PLUGIN:"/plugin/getPlugin",
	REQUEST_TYPE.GET_PLUGIN_MES:"/plugin/getPluginMes",
	REQUEST_TYPE.CREATE_PLUGIN:"/plugin/createPlugin",
	REQUEST_TYPE.UPLOAD_VERSION:"/plugin/uploadVersion",
	REQUEST_TYPE.DELETE_VERSION:"/plugin/deleteVersion",
	REQUEST_TYPE.UPDATE_PLUGIN:"/plugin/updatePlugin",
	REQUEST_TYPE.DELETE_PLUGIN:"/plugin/deletePlugin",
	REQUEST_TYPE.GET_AUTHOR_PLUGIN_AND_NODESET:"/plugin/getAuthorPluginAndNodeset",
	REQUEST_TYPE.CREATE_NODESET:"/nodeset/create",
	REQUEST_TYPE.DELETE_NODESET:"/nodeset/delete",
	REQUEST_TYPE.SEARCH_NODESET:"/nodeset/search",
	REQUEST_TYPE.GET_NODESET:"/nodeset/get",
	REQUEST_TYPE.IMAGE_UPLOAD:"/image/upload",
	REQUEST_TYPE.INTERPRETER_UPLOAD:"/interpreter/upload",
	REQUEST_TYPE.INTERPRETER_START:"/interpreter/start",
	REQUEST_TYPE.INTERPRETER_STOP:"/interpreter/stop",
	REQUEST_TYPE.INTERPRETER_RUNNING:"/interpreter/running",
	REQUEST_TYPE.INTERPRETER_BLOG:"/interpreter/blog",
	REQUEST_TYPE.INTERPRETER_INPUT:"/interpreter/input",
	REQUEST_TYPE.INTERPRETER_DOWNLOAD:"/interpreter/download"
}


func request_from_data(type:REQUEST_TYPE,data:Dictionary,callback:Callable):
	var new_http_node:HTTPRequest=HTTPRequest.new()
	add_child(new_http_node)
	new_http_node.request_completed.connect(request_completed.bind(new_http_node).bind(callback))
	new_http_node.timeout=20
	var request_addr:String
	#确定API地址
	request_addr=backend_path+REQUEST_ADDR[type]
	post(new_http_node,request_addr,data)



func request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray,call_back:Callable,node:HTTPRequest) -> void:
	if result!=HTTPRequest.RESULT_SUCCESS:
		node.queue_free()
		if call_back!=null and call_back.is_valid():
			call_back.call(false,{})
		return
		
	var str=body.get_string_from_utf8()
	#操作错误
	if str=="Fail" ||str==null:
		node.queue_free()
		if call_back!=null and call_back.is_valid():
			call_back.call(false,{})
		push_error("Request Failed")
		return
	var json=JSON.parse_string(str)
	print(json)
	if json is Dictionary and not json.has("error"):
		node.queue_free()
		if call_back!=null and call_back.is_valid():
			call_back.call(true,json)
		pass
	else:
		node.queue_free()
		if call_back!=null and call_back.is_valid():
			call_back.call(false,{})
		push_error("Request Failed")
	
	pass # Replace with function body.
#post
func post(http_request:HTTPRequest,addr:String,data:Dictionary) -> void:
	# Create some random bytes to generate our boundary value
	var crypto = Crypto.new()
	var random_bytes = crypto.generate_random_bytes(16)
	var boundary = '--GODOT%s' % random_bytes.hex_encode()

	# Setup the header Content-Type with our bundary
	var headers = [
		'Content-Type: multipart/form-data;boundary=%s' % boundary
	]
	
	var body:PackedByteArray=PackedByteArray()
	append_dic(body,data,boundary)
	http_request.request_raw(addr, headers, HTTPClient.METHOD_POST, body)

func request_get(http_request:HTTPRequest,addr:String,data:Dictionary):
	# Create some random bytes to generate our boundary value
	var crypto = Crypto.new()
	var random_bytes = crypto.generate_random_bytes(16)
	var boundary = '--GODOT%s' % random_bytes.hex_encode()

	# Setup the header Content-Type with our bundary
	var headers = [
		'Content-Type: multipart/form-data;boundary=%s' % boundary
	]
	
	var body:PackedByteArray=PackedByteArray()
	append_dic(body,data,boundary)
	http_request.request_raw(addr, headers, HTTPClient.METHOD_GET, body)


func append_line(buffer:PackedByteArray, line:String) -> void:
	buffer.append_array(line.to_utf8_buffer())
	buffer.append_array('\r\n'.to_utf8_buffer())


func append_bytes(buffer:PackedByteArray, bytes:PackedByteArray) -> void:
	buffer.append_array(bytes)
	buffer.append_array('\r\n'.to_utf8_buffer())
	
	
	
	
func append_dic(body:PackedByteArray,dictionary:Dictionary,boundary:String):
	for i in dictionary.keys():
		var  value=dictionary[i]
		if value is String:
			append_line(body, "--{{boundary}}".format({"boundary": boundary}, "{{_}}"))
			append_line(body, 'Content-Disposition: form-data; name="%s"'%i)
			append_line(body, '')
			append_line(body, value) # The API key you have
		elif value is PackedByteArray:
			append_line(body, "--{{boundary}}".format({"boundary": boundary}, "{{_}}"))
			append_line(body, 'Content-Disposition: form-data; name="%s"; filename="%s"'%[i,"data.zip"])
			append_line(body, 'Content-Type: application/zip')
			append_line(body, 'Content-Transfer-Encoding: binary')
			append_line(body, '')
			append_bytes(body, value)
		
	append_line(body, "--{{boundary}}--".format({"boundary": boundary}, "{{_}}"))


var download_dictionary:Dictionary={}

#请求下载文件
func request_download_file(dir_path:String,http_addr:String,callback:Callable,backend:String=".zip",data={}):
	var diraccess:DirAccess=DirAccess.open(dir_path)
	if diraccess==null:
		return
	if download_dictionary.has(http_addr):
		return
	var path=str(randf()).md5_text()
	while(diraccess.file_exists("/"+path+backend)):
		path=str(randf()).md5_text()
	var new_http_node:HTTPRequest=HTTPRequest.new()
	add_child(new_http_node)
	new_http_node.request_completed.connect(request_download_file_complete.bind(dir_path+"/"+path+backend).bind(http_addr).bind(callback))
	new_http_node.download_file=dir_path+"/"+path+backend
	download_dictionary[http_addr]=new_http_node
	request_get(new_http_node,http_addr,data)
#下载完毕的回调
func request_download_file_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray,call_back:Callable,request_path:String,download_path:String) -> void:
	if result!=HTTPRequest.RESULT_SUCCESS:
		if call_back!=null and call_back.is_valid():
			call_back.call(false,"")
	else:
		if not FileAccess.file_exists(download_path):
			call_back.call(false,"")
		else:
			call_back.call(true,download_path)
			pass
	#清除记录
	if download_dictionary.has(request_path):
		var node=download_dictionary[request_path]
		node.queue_free()
		download_dictionary.erase(request_path)
#停止并删除下载任务
func delete_download_request(request_path:String):
	if download_dictionary.has(request_path):
		var node=download_dictionary[request_path]
		node.queue_free()
		download_dictionary.erase(request_path)
#当前是否存在下载任务
func is_download_exists(request_path:String)->bool:
	return download_dictionary.has(request_path)
#获取下载进度
func get_download_progress(request_path:String)->Array:
	if download_dictionary.has(request_path):
		var node:HTTPRequest=download_dictionary[request_path]
		var content_length=node.get_body_size()
		var downloaded_lenght=node.get_downloaded_bytes()
		return [downloaded_lenght,content_length]
		pass
	else:
		return [0,0]

#获取interpreter下载地址
func get_interpreter_download_path():
	return backend_path+REQUEST_ADDR[REQUEST_TYPE.INTERPRETER_DOWNLOAD]


var mod_end:Array[String]=["gd","tscn","json","tre","res"]
func copy_interpreter_data(res1:bool,res2:bool,res3:bool):
	var cache_dir_path:String=cache_dir
	if not cache_dir_path.ends_with("/"):
		cache_dir_path+="/"
	var mod_from:String=cache_dir+"Mod"
	var nodeset_from:String=cache_dir+"Nodeset"
	var mod_to:String=ModLoader.load_path
	var nodeset_to:String=NodeSetGlobal.nodeset_download_path
	if DirAccess.dir_exists_absolute(mod_from) and DirAccess.dir_exists_absolute(mod_to):
		var res=find_all_files(mod_from)
		var dirs=res[1]
		var files=res[0]
		var base_dir_length=mod_from.length()
		for i:String in files:
			var remove_base_dir:String=i.right(i.length()-base_dir_length)
			var to_file=mod_to+"/"+remove_base_dir
			var base_dir=to_file.get_base_dir()
			DirAccess.make_dir_recursive_absolute(base_dir)
			var extension=i.get_extension()
			if extension in mod_end and res1:
				DirAccess.copy_absolute(i,to_file)
			elif (not extension in mod_end) and res3:
				DirAccess.copy_absolute(i,to_file)
	if res2 and DirAccess.dir_exists_absolute(nodeset_from) and DirAccess.dir_exists_absolute(nodeset_to):
		var dir=DirAccess.open(nodeset_from)
		if dir!=null:
			dir.list_dir_begin()
			var file=dir.get_next()
			while file!="":
				if not dir.current_is_dir():
					var p:String
					if nodeset_to.ends_with("/"):
						p=nodeset_to+file
					else:
						p=nodeset_to+"/"+file
					DirAccess.copy_absolute(nodeset_from+"/"+file,p)
					NodeSetGlobal.add_nodeset(p,"")
	
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


func request_texture_from_url(url:String,callback):
	
	var new_http_node:HTTPRequest=HTTPRequest.new()
	add_child(new_http_node)
	new_http_node.request_completed.connect(request_texture_complete.bind(url).bind(callback))
	new_http_node.timeout=100
	new_http_node.request(url)




func request_texture_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray,call_back:Callable,url:String,):
	if result!=HTTPRequest.RESULT_SUCCESS:
		push_error("图像请求失败")
		if call_back!=null and call_back.is_valid():
			call_back.call(false,Texture2D.new())
	var extension=url.get_extension()
	match extension:
		"jpg":
			var image:Image=Image.new()
			var err=image.load_jpg_from_buffer(body)
			if err!=OK:
				if call_back!=null and call_back.is_valid():
					call_back.call(false,Texture2D.new())
				push_error("无法解析的JPG图片")
			else:
				var texture:ImageTexture=ImageTexture.create_from_image(image)
				if call_back!=null and call_back.is_valid():
					call_back.call(true,texture)
		"png":
			var image:Image=Image.new()
			var err=image.load_png_from_buffer(body)
			if err!=OK:
				if call_back!=null and call_back.is_valid():
					call_back.call(false,Texture2D.new())
				push_error("无法解析的JPG图片")
			else:
				var texture:ImageTexture=ImageTexture.create_from_image(image)
				if call_back!=null and call_back.is_valid():
					call_back.call(true,texture)
			pass
		_:
			call_back.call(false,Texture2D.new())
			push_error("无法解析的图片格式")
