extends Window

const WARN = preload("res://mod_loader/editor/res/warn.svg")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	queue_free()
	pass # Replace with function body.



signal refuse

signal accept(data:Dictionary)

func _on_accept_pressed() -> void:
	if not could_use_package_name(%package.text):
		return
	accept.emit({
		"name":%package.text,
		"use_model":%use_model.button_pressed,
		"name_view":%name_view.text
	})
	queue_free()
	pass # Replace with function body.


func _on_refuse_pressed() -> void:
	queue_free()
	pass # Replace with function body.


func _on_package_text_changed(new_text: String) -> void:
	%package_warn.visible=not could_use_package_name(new_text)

	
	pass # Replace with function body.




func could_use_package_name(mod_name:String):
	if mod_name=="":
		return false
	if not mod_name.is_valid_identifier():
		return false
	if ModLoader.has_mod(mod_name):
		return false
	
	
	return true
