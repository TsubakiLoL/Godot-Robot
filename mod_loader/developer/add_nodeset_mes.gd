extends Window

signal add_nodeset_request(nodeset_name:String,introduction:String,file_path:String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	queue_free()
	pass # Replace with function body.


func _on_refuse_pressed() -> void:
	queue_free()
	pass # Replace with function body.


func _on_accept_pressed() -> void:
	
	pass # Replace with function body.
