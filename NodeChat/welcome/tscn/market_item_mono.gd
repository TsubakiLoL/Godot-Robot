extends PanelContainer

var nodeset:NodeSet


signal request_nodeset_mes(nodeset:NodeSet)
func _on_button_pressed() -> void:
	request_nodeset_mes.emit(nodeset)
	pass # Replace with function body.

func set_nodeset(nodeset:NodeSet):
	self.nodeset=nodeset
	%set_name.text=nodeset.nodeset_name
	%author_name.text=nodeset.author_name
