extends PanelContainer
var origin_data:Dictionary={}

func set_data(mod_origin_data:Dictionary):
	origin_data=mod_origin_data
	var n=mod_origin_data["name"]
	if mod_origin_data.has("name_view"):
		n+=("("+mod_origin_data["name_view"]+")")
	%name.text=n
	if mod_origin_data.has("i"):
		%introduction.text=mod_origin_data["i"]
	else:
		%introduction.text=""
	
	
	pass


func _on_edit_pressed() -> void:
	print(origin_data["mod_path"])
	ModLoaderWinControl.edit(origin_data["mod_path"])
	pass # Replace with function body.


func _on_delete_pressed() -> void:
	%confirm.popup()
	pass # Replace with function body.


func _on_confirm_confirmed() -> void:
	ModLoader.delete_mod(origin_data["name"])
	pass # Replace with function body.
