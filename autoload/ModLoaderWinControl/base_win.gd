extends Window

class_name BaseWindow
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

const BASE_WIN_MES = preload("res://autoload/ModLoaderWinControl/base_win_mes.tscn")
func _on_close_requested() -> void:
	queue_free()
	pass # Replace with function body.


func popup_mes(mes:String):
	var new_mes=BASE_WIN_MES.instantiate()
	new_mes.show_text=mes
	%add_pos.add_child(new_mes)
	
	
	
	pass
