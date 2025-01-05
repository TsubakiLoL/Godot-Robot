extends VBoxContainer

@export var dic_name:String="字典名":
	set(value):
		dic_name=value
		%name.text=value

var dictionary:Dictionary={}:
	set(value):
		dictionary=value
	

func _ready() -> void:
	#初始化
	dic_name=dic_name
	dictionary=dictionary
func _on_panel_control_pressed() -> void:
	%panel.visible=not %panel.visible
	pass # Replace with function body.


func _on_add_btn_pressed() -> void:
	pass # Replace with function body.
