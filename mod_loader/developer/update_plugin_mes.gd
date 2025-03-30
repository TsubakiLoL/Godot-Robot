extends Window

signal update_pluign_mes(plugin:Plugin,new_plugin_name:String,new_plugin_introduction:String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var plugin:Plugin

func set_plugin(plugin:Plugin):
	self.plugin=plugin
	%plugin_name.text=plugin.plugin_name
	%plugin_introduction.text=plugin.introduction


func _on_accept_pressed() -> void:
	var new_plugin_name=%plugin_name.text
	var new_plugin_introduction=%plugin_introduction.text
	if new_plugin_name=="":
		return
	update_pluign_mes.emit(plugin,new_plugin_name,new_plugin_introduction)
	queue_free()
	pass # Replace with function body.


func _on_refuse_pressed() -> void:
	
	
	queue_free()
	pass # Replace with function body.


func _on_close_requested() -> void:
	queue_free()
	pass # Replace with function body.
