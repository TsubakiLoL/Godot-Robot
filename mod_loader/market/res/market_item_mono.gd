extends PanelContainer

var data:Dictionary={}

signal click(data:Dictionary)
func set_data(data:Dictionary):
	if data.has("plugin_name"):
		%plugin_name.text=data["plugin_name"]
	if data.has("plugin_author"):
		%author_name.text=data["plugin_author"]
	self.data=data
	
	pass
	


func _on_button_pressed() -> void:
	click.emit(data)
	pass # Replace with function body.
