#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------




extends Control
@onready var tab_container: TabContainer = $Control2/TabContainer

var graph_map_tscn=preload("res://NodeChat/graphe/tscn/graphe_map.tscn")
var account_file:String="user://account.txt"



func multi_mes(str:String):
	$loginmes/ScrollContainer/login_mes_label.append_text(str+"\n")
func _on_welcome_pressed() -> void:
	tab_container.set_current_tab(0)
	pass # Replace with function body.


func _on_file_pressed() -> void:
	tab_container.set_current_tab(1)
	pass # Replace with function body.


func _on_control_edit_file(path: String) -> void:
	var new_gra=graph_map_tscn.instantiate() as GrapheMap
	add_child(new_gra)
	new_gra.open_state_root(path)
	pass # Replace with function body.


func _on_flag_pressed() -> void:
	$loginmes.popup()
	pass # Replace with function body.



func load_account():
	var f=FileAccess.open(account_file,FileAccess.READ)
	if f!=null:
		var txt=f.get_as_text()
		var res=JSON.parse_string(txt)
		if res is Array and res.size()==3 and res[0] is String and res[1] is String and res[2] is String:
			$Control2/TabContainer/iirose/MarginContainer/Control/name.text=res[0]
			$Control2/TabContainer/iirose/MarginContainer/Control/password.text=res[1]
			$Control2/TabContainer/iirose/MarginContainer/Control/room.text=res[2]
	pass
func save_account(n:String,p:String,r:String):
	var f=FileAccess.open(account_file,FileAccess.WRITE)
	if f!=null:
		var res=[n,p,r]
		var str=JSON.stringify(res)
		f.store_string(str)
		f.close()
	pass
func _on_iirose_pressed() -> void:
	$Control2/TabContainer.set_current_tab(3)
	pass # Replace with function body.


func _on_gpt_pressed() -> void:
	$Control2/TabContainer.set_current_tab(4)
	var res=ChatGPT.get_key_and_url()
	if res is Array and res.size()==2 and res[0] is String and res[1] is String:
		$Control2/TabContainer/gpt/MarginContainer/Control/key.text=res[0]
		$Control2/TabContainer/gpt/MarginContainer/Control/url.text=res[1]
	pass # Replace with function body.


func _on_gpt_save_pressed() -> void:
	var key=$Control2/TabContainer/gpt/MarginContainer/Control/key.text 
	var url=$Control2/TabContainer/gpt/MarginContainer/Control/url.text
	ChatGPT.set_key_and_url(key,url)
	_on_gpt_pressed()
	pass # Replace with function body.


func _on_move_pressed() -> void:
	#IIROSE.move_to_room($Control2/TabContainer/iirose/MarginContainer/Control/roommove.text)
	pass # Replace with function body.


func _on_doc_pressed() -> void:
	$docwin.show()
	pass # Replace with function body.


func _on_nodeset_market_pressed() -> void:
	tab_container.set_current_tab(2)
	%Webfile.refresh()
	pass # Replace with function body.


func _on_online_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%plugin.show()
		%Webfile.is_connect_to_server=true
		%online_num.show()
	else:
		if %TabContainer.current_tab==2:
			%TabContainer.current_tab=0
		%plugin.hide()
		%online_num.hide()
		%Webfile.is_connect_to_server=false
	pass # Replace with function body.


func _on_editor_pressed() -> void:
	OS.shell_open("https://qm.qq.com/q/YYQsyr0zao")
	pass # Replace with function body.



func _on_webfile_linked_num_update(num_int: int) -> void:
	%online_num.text="当前在线用户:"+str(num_int)
	pass # Replace with function body.


func _on_login_mes_clear_pressed() -> void:
	%login_mes_label.text=""
	pass # Replace with function body.


func _on_iirose_chat_pressed() -> void:
	%IiroseChat.popup()
	pass # Replace with function body.

##根据modloader加载的面板加载部分插件
func load_panel():
	var all_panel=ModLoader.get_all_panel()
	for i in all_panel:
		var n=i[0]
		var t=i[1]
		var s=i[2]
		if not t is PackedScene:
			continue
		var button=Button.new()
		button.text=i[0]
		%mod_panel_btn_add_pos.add_child(button)
		var new_panel=t.instantiate()
		if s is GDScript:
			new_panel.script=s
		%mod_panel_add_pos.add_child(new_panel)
		button.pressed.connect(show_mod_panel.bind(new_panel))
		pass
	
	
	pass

func show_mod_panel(panel):
	for i in %mod_panel_add_pos.get_children():
		i.hide()
	panel.show()
	%TabContainer.current_tab=4

func _ready() -> void:
	load_panel()


func _on_plugin_pressed() -> void:
	tab_container.set_current_tab(3)
	pass # Replace with function body.
