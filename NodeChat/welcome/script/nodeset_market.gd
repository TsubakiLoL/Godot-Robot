extends Control

const MARKET_ITEM_MONO = preload("res://NodeChat/welcome/tscn/market_item_mono.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if addr_cache!="":
		if AuthorAccount.is_download_exists(addr_cache):
			%download_progress_box.show()
			var progress=AuthorAccount.get_download_progress(addr_cache)
			set_progress(progress[0],progress[1])
			%download_plugin.disabled=true
			%download_plugin.text="下载中"
		else:
			
			%download_progress_box.hide()
			%download_plugin.disabled=false
			%download_plugin.text="下载"
			pass
	else:
		%download_progress_box.hide()
		%download_plugin.disabled=false
		%download_plugin.text="下载"

func  request_search(content:String):
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.SEARCH_NODESET,
	{
		"content":content
	}
	,
	search_result_get
	)
	open_load()
	
func search_result_get(is_success:bool,data:Dictionary):
	if not data.has("nodeset"):
		return
		
	if not is_success:
		return
	
	var arr:Array=data["nodeset"]
	create_item_list(arr)
	close_load()

func create_item_list(data:Array):
	for i in %item.get_children():
		i.queue_free()
	for i in data:
		var new_nodeset:NodeSet=NodeSet.new(i["nodeset_id"],i["introduction"],i["author_name"],i["nodeset_name"])
		var new_mono=MARKET_ITEM_MONO.instantiate()
		%item.add_child(new_mono)
		new_mono.set_nodeset(new_nodeset)
		new_mono.request_nodeset_mes.connect(request_nodeset_mes)
	
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


func _on_search_input_text_submitted(new_text: String) -> void:
	if new_text!="":
		request_search(new_text)
	pass # Replace with function body.


func _on_search_pressed() -> void:
	var content=%search_input.text
	_on_search_input_text_submitted(content)
	pass # Replace with function body.

func request_nodeset_mes(nodeset:NodeSet):
	%plugin_mes_panel.show()
	open_mes_load()
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.GET_NODESET,
	{
		"nodeset_id":nodeset.nodeset_id
	},
	nodeset_mes_get
	)
	
	
	pass
var nodeset_cache
var addr_cache:String=""
func nodeset_mes_get(is_success:bool,data:Dictionary):
	
	close_mes_load()
	if is_success and data.has("nodeset_id") and data.has("nodeset_name") and data.has("author_id") and data.has("introduction") and data.has("path"):
		var new_nodeset:NodeSet=NodeSet.new(data["nodeset_id"],data["introduction"],data["author_id"],data["nodeset_name"])
		nodeset_cache=new_nodeset
		nodeset_cache=new_nodeset
		%nodeset_name.text=new_nodeset.nodeset_name
		%nodeset_introduction.text=new_nodeset.introduction
		var addr=data["path"]
		addr_cache=addr

func set_progress(now,max):
	
	%download_progress.value=now
	%download_progress.max_value=max
	%download_label.text=str(now)+"/"+str(max)
	
	pass


func _on_download_plugin_pressed() -> void:
	AuthorAccount.request_download_file(NodeSetGlobal.nodeset_download_path,addr_cache,
	func(is_success:bool,path:String):
		if is_success:
			Toast.popup(path+"下载成功")
			NodeSetGlobal.add_nodeset(path)
		else:
			Toast.popup(path+"下载失败")
		pass
	,
	".nodeset"
	)
	pass # Replace with function body.
