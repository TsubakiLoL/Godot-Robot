extends Resource
class_name Version

var version_name:String

var version_path:String

var plugin_id:String

var package_name:String
func _init(version_name:String,version_path:String,plugin_id:String,package_name:String) -> void:
	self.version_name=version_name
	self.plugin_id=plugin_id
	self.version_path=version_path
	self.package_name=package_name
	pass
