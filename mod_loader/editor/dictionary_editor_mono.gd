extends HBoxContainer

class_name DictionaryMono

#当前已经命名的键
var key_group:Array[String]=[]
#被改名之前缓存的键位
var before_key:String="default"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%key.text=before_key
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



signal key_changed(before_key:String,now_key:String)
signal value_changed(key:String,value:String)
signal delete(key:String)
func update_key():
	var key_value=%key.text
	if key_value==before_key:
		return
	if key_value in key_group:
		Toast.popup("重复键名！")
		%key.text=before_key
		return
	key_changed.emit(before_key,key_value)
	before_key=key_value
func update_value():
	var value_value=%value.text
	value_changed.emit(before_key,value_value)
	






func _on_key_text_submitted(new_text: String) -> void:
	update_key()
	pass # Replace with function body.


func _on_key_focus_exited() -> void:
	update_key()
	pass # Replace with function body.


func _on_value_text_submitted(new_text: String) -> void:
	update_value()
	pass # Replace with function body.


func _on_value_focus_exited() -> void:
	update_value()
	pass # Replace with function body.


func _on_delete_pressed() -> void:
	delete.emit(before_key)
	pass # Replace with function body.
func set_value(value:String):
	%value.text=value
