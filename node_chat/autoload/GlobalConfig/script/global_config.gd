#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends Node

##当废止改变时发出
signal config_chages(section,item,value)


var config_file_path:String:
	get():
		if OS.is_debug_build():
			return "res://config.cfg"
		else:
			return OS.get_executable_path().get_base_dir()+"/config.cfg"


var _config_cache:ConfigFile

var config_file:ConfigFile:
	
	get():
		if _config_cache!=null:
			return _config_cache
			
		else:
			if not FileAccess.file_exists(config_file_path):
				var config=ConfigFile.new()
				_config_cache=config
				var err=config.save(config_file_path)
				if err!=OK:
					push_error("创建配置文件失败")
				return config
			var config=ConfigFile.new()
			config.load(config_file_path)
			_config_cache=config
			return config


func get_item_value(section:String,item:String):
	if section_db.has(section):
		var section_instance:ConfigSection=section_db[section]
		if section_instance.has_item(item):
			var item_instance:ConfigItem=section_instance.get_item(item)
			var value=config_file.get_value(section,item,item_instance.item_type.default_value)
			return value
	push_error("不存在的配置条目")
	return null
func set_item_value(section:String,item:String,value):
	if section_db.has(section):
		var section_instance:ConfigSection=section_db[section]
		if section_instance.has_item(item):
			var item_instance:ConfigItem=section_instance.get_item(item)
			if item_instance.item_type.is_legal(value):
				config_file.set_value(section,item,value)
				config_file.save(config_file_path)
				pass
			return
			pass
	push_error("不存在的配置条目")
	return null



var section_db:Dictionary[String,ConfigSection]={}
func add_section(section:ConfigSection):
	section_db[section.section_name]=section
func get_section(section_name:String):
	if section_db.has(section_name):
		return section_db[section_name]
	return null	

##获取全部设置节
func get_all_section()->Array:
	return section_db.values()
	
	pass

class ConfigType:
	enum ConfigValueType{
		NUMBER,
		TEXT,
		SELECT,
		BOOL
	}
	var type:ConfigValueType=ConfigValueType.NUMBER
	var default_value
	#是否合法
	func is_legal(value)->bool:
		return false

class ConfigTypeNumber extends ConfigType:
	var min:int
	var max:int
	func _init(min:int,max:int,default_value:int) -> void:
		type=ConfigType.ConfigValueType.NUMBER
		self.max=max
		self.min=min
		self.default_value=default_value
	func is_legal(value)->bool:
		if not value is int:
			return false
		if value>=min and value<=max:
			return true
		return false
class ConfigTypeText extends ConfigType:
	var is_secret:bool
	func _init(default_value:String,is_secret:bool=false) -> void:
		self.default_value=default_value
		self.is_secret=is_secret
		type=ConfigType.ConfigValueType.TEXT
	func is_legal(value)->bool:
		
		
		return value is String
	
class ConfigTypeSelect extends ConfigType:
	
	func _init() -> void:
		type=ConfigType.ConfigValueType.SELECT
	var select_db:Dictionary[String,String]={}
	
	func add_select(select_value:String,select_name:String):
		select_db[select_value]=select_name
	func set_default(select_value:String):
		if  select_db.has(select_value):
			default_value=select_value
		else:
			push_error("设置的默认值不存在")
	func get_all_value()->Array[String]:
		
		return select_db.keys()
	
	func get_value_name(value:String)->String:
		
		return select_db[value]
		
		pass
	func is_legal(value)->bool:
		return value is String and select_db.has(value)
class ConfigTypeBool extends ConfigType:
	func _init(default_value:bool) -> void:
		type=ConfigType.ConfigValueType.BOOL
		self.default_value=default_value
	func is_legal(value)->bool:
		return value is bool

class ConfigSection:
	var section_view:String=""
	
	var section_name:String=""
	
	var item_db:Dictionary[String,ConfigItem]={}
	
	func _init(view:String,name:String) -> void:
		self.section_view=view
		self.section_name=name
		pass
	
	func add_item(item:ConfigItem):
		item_db[item.item_name]=item
	func has_item(item_name:String):
		
		return item_db.has(item_name)
	func get_item(item_name:String):
		if item_db.has(item_name):
			return item_db[item_name]
		return null
class ConfigItem:
	var item_view:String=""
	var item_name:String=""
	var item_type:ConfigType
	func _init(view:String,name:String,type:ConfigType) -> void:
		self.item_view=view
		self.item_name=name
		self.item_type=type
		pass
