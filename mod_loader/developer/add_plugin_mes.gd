extends Window

signal create_plugin(plugin_name:String,plugin_introduction:String)


func _on_about_to_popup() -> void:
	
	pass # Replace with function body.


func _on_accept_pressed() -> void:
	if %plugin_name.text!="":
		create_plugin.emit(%plugin_name.text,%plugin_introduction.text)
		self.queue_free()
	pass # Replace with function body.


func _on_refuse_pressed() -> void:
	self.queue_free()
	pass # Replace with function body.


func _on_close_requested() -> void:
	self.queue_free()
	pass # Replace with function body.
