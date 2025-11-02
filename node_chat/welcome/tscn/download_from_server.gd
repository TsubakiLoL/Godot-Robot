extends Window

signal request(res1:bool,res2:bool,res3:bool)

func _on_accept_pressed() -> void:
	request.emit(%res1.button_pressed,%res2.button_pressed,%res3.button_pressed)
	queue_free()
	pass # Replace with function body.


func _on_refuse_pressed() -> void:
	queue_free()
	pass # Replace with function body.


func _on_close_requested() -> void:
	queue_free()
	pass # Replace with function body.
