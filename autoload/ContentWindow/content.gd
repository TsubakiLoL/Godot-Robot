extends Node

const CONTENT_WINDOW = preload("res://autoload/ContentWindow/content_window.tscn")
func popup(data:Dictionary,call_back):
	var new_window=CONTENT_WINDOW.instantiate()
	add_child(new_window)
	new_window.request_pop(data,call_back)
