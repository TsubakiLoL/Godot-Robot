extends Resource
class_name NodeSet

var nodeset_id:String

var introduction:String

var author_name:String

var nodeset_name:String


func _init(nodeset_id:String,introduction:String,author_name:String,nodeset_name:String) -> void:
	
	self.nodeset_id=nodeset_id
	self.author_name=author_name
	self.nodeset_name=nodeset_name
	self.nodeset_id=nodeset_id
	self.introduction=introduction
	pass
