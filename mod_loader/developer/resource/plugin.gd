extends Resource
class_name Plugin
var plugin_id:String

var plugin_name:String

var author_id:String

var introduction:String

func _init(plugin_id:String,plugin_name:String,author_id:String,introduction:String) -> void:
	self.plugin_id=plugin_id
	self.plugin_name=plugin_name
	self.author_id=author_id
	self.introduction=introduction
