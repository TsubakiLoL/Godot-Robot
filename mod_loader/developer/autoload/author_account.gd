extends Node

var load_path:String="user://"
var account_data:Array=[]


var backend_path:String="http://localhost:8080"


func _ready() -> void:
	
	account_data=load_account()
	
	
	pass
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
func request_download_file(dir_path:String,http_addr:String,callback:Callable,backend:String=".zip"):
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
	new_http_node.request(http_addr)
	
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
