extends OptionButton

signal item_select(item:String)

var list:Array[String]=[]


func _ready() -> void:
	clear()
	for i in list:
		add_item(i)
	pass


func _on_item_selected(index: int) -> void:
	var item=get_item_text(index)
	item_select.emit(item)
	pass # Replace with function body.
