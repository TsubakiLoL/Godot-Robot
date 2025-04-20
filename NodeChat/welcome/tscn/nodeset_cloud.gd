extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	queue_free()
	pass # Replace with function body.

var is_run:bool=false:
	set(value):
		if value:
			%flag.modulate=Color.GREEN
			%flag_label.text="运行中"
			pass
		else:
			%flag.modulate=Color.RED
			%flag_label.text="未在运行"
			pass
		is_run=value

func _on_timer_timeout() -> void:
	if not AuthorAccount.has_account():
		return
	AuthorAccount.request_from_data(
		AuthorAccount.REQUEST_TYPE.INTERPRETER_RUNNING,
		{
			"author_name":AuthorAccount.account_data[0],
			"password":AuthorAccount.account_data[1].md5_text()
		},
		
		func(is_success:bool,data:Dictionary):
			if is_success and data.has("running"):
				if data["running"]:
					is_run=true
				else:
					is_run=false
			pass
	)
	if %need_data.button_pressed:
		
		request_blog()




func start_animation():
	%load_animation.show()
	%animation.play("load")
func stop_animation():
	%load_animation.hide()
	%animation.stop()

const SELECT_NODESET = preload("res://NodeChat/welcome/tscn/select_nodeset.tscn")
func _on_upload_pressed() -> void:
	var new_window=SELECT_NODESET.instantiate()
	new_window.selected.connect(request_nodeset_upload)
	add_child(new_window)
	new_window.popup()
	pass # Replace with function body.

func request_nodeset_upload(selected_nodeset:Array[String]):
	start_animation()
	AuthorAccount.empty_cache()
	AuthorAccount.create_mod_and_nodeset_path()
	Zip.start_mission("拷贝",Zip.Type.COPY,ModLoader.load_path,AuthorAccount.cache_dir+"/Mod",
		func():
			for i in selected_nodeset:
				DirAccess.copy_absolute(i,AuthorAccount.cache_dir+"/Nodeset/"+i.get_file())
			AuthorAccount.pack_cache(
				func(zip_path:String):
					
					print(zip_path)
					if not AuthorAccount.has_account():
						Toast.popup("没有账户！")
						return
					var f=FileAccess.open(zip_path,FileAccess.READ)
					if f==null:
						return
					var data=f.get_buffer(f.get_length())
					AuthorAccount.request_from_data(
						AuthorAccount.REQUEST_TYPE.INTERPRETER_UPLOAD,
						{
							"author_name":AuthorAccount.account_data[0],
							"password":AuthorAccount.account_data[1].md5_text(),
							"file":data,
						},
						func(is_success:bool,data:Dictionary):
							stop_animation()
							pass
					)
					pass
			)
	)

	pass


func _on_run_pressed() -> void:
	if not AuthorAccount.has_account():
		return
	if is_run:
		AuthorAccount.request_from_data(
			AuthorAccount.REQUEST_TYPE.INTERPRETER_STOP,
			{
				"author_name":AuthorAccount.account_data[0],
				"password":AuthorAccount.account_data[1].md5_text(),
			},
			func(is_success:bool,data:Dictionary):
				if is_success:
					Toast.popup("成功停止")
				else:
					Toast.popup("失败")
				pass
		)
	else:
		AuthorAccount.request_from_data(
			AuthorAccount.REQUEST_TYPE.INTERPRETER_START,
			{
				"author_name":AuthorAccount.account_data[0],
				"password":AuthorAccount.account_data[1].md5_text(),
			},
			func(is_success:bool,data:Dictionary):
				if is_success:
					Toast.popup("成功启动")
				else:
					Toast.popup("启动失败")
				pass
		)
	pass # Replace with function body.


func _on_cmd_input_text_submitted(new_text: String) -> void:
	if new_text=="":
		return
	if not AuthorAccount.has_account():
		return
	start_animation()
	AuthorAccount.request_from_data(
		AuthorAccount.REQUEST_TYPE.INTERPRETER_INPUT,
		{
			"author_name":AuthorAccount.account_data[0],
			"password":AuthorAccount.account_data[1].md5_text(),
			"input":new_text,
		},
		func(is_success:bool,data:Dictionary):
			stop_animation()
			if is_success:
				%cmd_input.clear()
				
				_on_timer_timeout()
			else:
				Toast.popup("失败")
			
			pass
	)
	pass # Replace with function body.


func _on_about_to_popup() -> void:
	_on_timer_timeout()
	pass # Replace with function body.

func request_blog():
	AuthorAccount.request_from_data(
		AuthorAccount.REQUEST_TYPE.INTERPRETER_BLOG,
		{
			"author_name":AuthorAccount.account_data[0],
			"password":AuthorAccount.account_data[1].md5_text()
		},
		
		func(is_success:bool,data:Dictionary):
			if is_success and data.has("data"):
				var blog_data:Array=data["data"]
				%blog.clear()
				for i in blog_data:
					%blog.text+=("\n"+i)
				%blog.get_v_scroll_bar().value=%blog.get_v_scroll_bar().max_value
			pass
	)

	
	pass
func _on_fresh_pressed() -> void:
	request_blog()
	pass # Replace with function body.


func _on_download_data_pressed() -> void:
	var window=preload("res://NodeChat/welcome/tscn/download_from_server.tscn").instantiate()
	window.request.connect(request_download_interpreter)
	add_child(window)
	window.popup()
	pass # Replace with function body.

func request_download_interpreter(download_mod:bool,download_nodeset:bool,download_other:bool):
	start_animation()
	if not AuthorAccount.has_account():
		return
	AuthorAccount.request_download_file(AuthorAccount.get_cache_zip_path().get_base_dir(),AuthorAccount.get_interpreter_download_path(),
		func(is_success:bool,path:String):
			if is_success:
				AuthorAccount.empty_cache()
				Zip.start_mission("解压",Zip.Type.UNZIP,path,AuthorAccount.cache_dir,
					func():
						
						Toast.popup("解压成功")
						
						
						AuthorAccount.copy_interpreter_data(download_mod,download_nodeset,download_other)
						stop_animation()
				
				)
				
				pass
			else:
				stop_animation()
	,
	".zip",
	{
		"author_name":AuthorAccount.account_data[0],
		"password":AuthorAccount.account_data[1].md5_text()
	}
)
