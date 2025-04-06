extends Control

var author_cache:Author
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	request_login()
	$account_panel/TabContainer.current_tab=0
	
	pass # Replace with function body.
func request_login():
	if AuthorAccount.has_account():
		AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.AUTHOR_LOGIN,
		{
			"author_name":AuthorAccount.account_data[0],
			"password":AuthorAccount.account_data[1].md5_text()
			},login_callback)
		%login_id.text=AuthorAccount.account_data[0]
		%login_password.text=AuthorAccount.account_data[1]

func login_callback(is_success:bool,data:Dictionary):
	if data.has("id") and data.has("name")  and data.has("head"):
		$account_panel/TabContainer.current_tab=2
		$account_panel/TabContainer/mes/Label.text=data["name"]
		author_cache=Author.new(data["id"],data["name"],data["head"])
		AuthorAccount.request_texture_from_url(data["head"],
		func(is_success:bool,texture:Texture2D):
			print("头像回调")
			if is_success:
				%head.texture=texture
			else:
				%head.texture=preload("res://RobotIcon.png")
				
				)
		


func register_callback(is_success:bool,data:Dictionary):
	if is_success:
		if data.has("id") and data.has("name") and data.has("password") and data.has("head"):
			
			
			$account_panel/TabContainer.current_tab=2
			$account_panel/TabContainer/mes/Label.text=data["name"]
			author_cache=Author.new(data["id"],data["name"],data["head"])
			AuthorAccount.add_account([data["name"],data["password"]])
			AuthorAccount.request_texture_from_url(data["head"],
			func(is_success:bool,texture:Texture2D):
				print("头像回调")
				if is_success:
					%head.texture=texture
				else:
					%head.texture=preload("res://RobotIcon.png")
				
				)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_login_pressed() -> void:
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.AUTHOR_LOGIN,
		{
			"author_name":%login_id.text,
			"password":%login_password.text.md5_text()
			},login_callback)
	AuthorAccount.add_account([%login_id.text,%login_password.text])
	pass # Replace with function body.



func _on_register_pressed() -> void:
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.AUTHOR_SIGNUP,
	{
		"name":%register_name.text,
		"password":%register_password.text,
		"head":%register_head.text
		
	},register_callback
	)
	pass # Replace with function body.


func _on_goto_register_pressed() -> void:
	$account_panel/TabContainer.current_tab=1
	pass # Replace with function body.


func _on_goto_login_pressed() -> void:
	$account_panel/TabContainer.current_tab=0
	pass # Replace with function body.


func _on_quit_login_pressed() -> void:
	$account_panel/TabContainer.current_tab=0
	pass # Replace with function body.


func _on_refuse_update_pressed() -> void:
	$account_panel/TabContainer.current_tab=2
	pass # Replace with function body.


func _on_accept_update_pressed() -> void:
	var change_name:String=%change_name.text
	var change_password:String=%change_password.text
	var change_head:String=%change_head.text
	if change_name!="" and change_password!="" and change_head!="":
		AuthorAccount.request_from_data(
			AuthorAccount.REQUEST_TYPE.AUTHOR_UPDATE,
			{
				"author_name":AuthorAccount.account_data[0],
				"password":AuthorAccount.account_data[1].md5_text(),
				"name":change_name,
				"new_password":change_password,
				"head":change_head,
			},
			func(is_success:bool,data:Dictionary):
				if is_success:
					AuthorAccount.add_account([change_name,change_password])
					request_login()
					
					Toast.popup("修改成功")
				else:
					Toast.popup("修改失败")
				pass
		)
		
		pass
	pass # Replace with function body.


func _on_select_file_pressed() -> void:
	DisplayServer.file_dialog_show("选择文件","","",false,DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,PackedStringArray(["*.jpg","*.png"]),register_file_selected)
	pass # Replace with function body.

func register_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		var file_path=selected_paths[0]
		#获取扩展名
		var extension=file_path.get_extension()
		if not (extension=="jpg" or extension=="png"):
			Toast.popup("不支持的图片类型")
			return
		
		var f=FileAccess.open(file_path,FileAccess.READ)
		if f!=null:
			var data=f.get_buffer(f.get_length())
			LoadAnimation.start()
			AuthorAccount.request_from_data(
				AuthorAccount.REQUEST_TYPE.IMAGE_UPLOAD,
				{
					"backend":extension,
					"file":data
				},
				func(is_success:bool,data:Dictionary):
					LoadAnimation.stop()
					if is_success and data.has("path"):
						%register_head.text=data["path"]
						Toast.popup("上传成功")
						
					pass
			)
			
			pass
		else:
			Toast.popup("文件读取错误！")
		pass
	
	pass


func _on_update_user_pressed() -> void:
	if author_cache is Author:
		var str:String="账户信息：
				名字："+author_cache.name+"
				头像："+author_cache.head
		%mes.text=str
		%change_name.text=AuthorAccount.account_data[0]
		%change_password.text=AuthorAccount.account_data[1]
		%change_head.text=author_cache.head
		$account_panel/TabContainer.current_tab=3
	
	pass # Replace with function body.


func _on_update_select_file_pressed() -> void:
	DisplayServer.file_dialog_show("选择文件","","",false,DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,PackedStringArray(["*.jpg","*.png"]),update_file_selected)
	pass # Replace with function body.


func update_file_selected(status:bool,selected_paths:PackedStringArray,selected_filter_index:int):
	if status:
		var file_path=selected_paths[0]
		#获取扩展名
		var extension=file_path.get_extension()
		if not (extension=="jpg" or extension=="png"):
			Toast.popup("不支持的图片类型")
			return
		
		var f=FileAccess.open(file_path,FileAccess.READ)
		if f!=null:
			var data=f.get_buffer(f.get_length())
			LoadAnimation.start()
			AuthorAccount.request_from_data(
				AuthorAccount.REQUEST_TYPE.IMAGE_UPLOAD,
				{
					"backend":extension,
					"file":data
				},
				func(is_success:bool,data:Dictionary):
					LoadAnimation.stop()
					if is_success and data.has("path"):
						%change_head.text=data["path"]
						Toast.popup("上传成功")
						
					pass
			)
			
			pass
		else:
			Toast.popup("文件读取错误！")
