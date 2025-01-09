extends DrawerContainer
var show_text:String="default"
func _re_ready():
	
	$PanelContainer/MarginContainer/Label.text=show_text
	change_open()
	


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
