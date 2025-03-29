extends Window

signal create_plugin_version(plugin:Plugin,version_name:String,file_path:String,package_name:String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mod_list=ModLoader.get_all_mod_origin_data().keys()
	%mod_list.clear()
	for i in mod_list:
		%mod_list.add_item(i)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
var plugin:Plugin
func set_plugin(plugin:Plugin):
	%plugin_name.text=plugin.plugin_name
	%plugin_introduction.text=plugin.introduction
	self.plugin=plugin

func _on_mod_list_item_selected(index: int) -> void:
	var item:String=%mod_list.get_item_text(index)
	%file_path.text="mod:"+item
	pass # Replace with function body.


func _on_close_requested() -> void:
	self.queue_free()
	pass # Replace with function body.


func _on_accept_pressed() -> void:
	var version_name:String=%plugin_version.text
	var package_name:String=%plugin_package_name.text
	var file_path:String=%file_path.text
	if version_name!="" and file_path!=""  and package_name!="":
		create_plugin_version.emit(plugin,version_name,file_path,package_name)
		self.queue_free()
	pass # Replace with function body.


func _on_refuse_pressed() -> void:
	self.queue_free()
	pass # Replace with function body.
