extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if AuthorAccount.has_account():
		AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.AUTHOR_LOGIN,
		{
			"id":AuthorAccount.account_data[0],
			"password":AuthorAccount.account_data[1].md5_text()
			},login_callback)
		%login_id.text=AuthorAccount.account_data[0]
		%login_password.text=AuthorAccount.account_data[1]
	$account_panel/TabContainer.current_tab=0
	
	pass # Replace with function body.

func login_callback(is_success:bool,data:Dictionary):
	if is_success and data.has("name"):
		$account_panel/TabContainer.current_tab=2
		$account_panel/TabContainer/mes/Label.text=data["name"]


func register_callback(is_success:bool,data:Dictionary):
	if is_success:
		if data.has("id") and data.has("name") and data.has("password"):
			
			
			$account_panel/TabContainer.current_tab=2
			$account_panel/TabContainer/mes/Label.text=data["name"]
			AuthorAccount.add_account([data["id"],data["password"]])
			pass
		
		
		
		pass
	
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_login_pressed() -> void:
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.AUTHOR_LOGIN,
		{
			"id":%login_id.text,
			"password":%login_password.text.md5_text()
			},login_callback)
	AuthorAccount.add_account([%login_id.text,%login_password.text])
	pass # Replace with function body.



func _on_register_pressed() -> void:
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.AUTHOR_SIGNUP,
	{
		"name":%register_name.text,
		"password":%register_password.text
		
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
