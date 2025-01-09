extends Node
const MOD_EDITOR = preload("res://mod_loader/editor/mod_editor.tscn")
const BASE_WIN = preload("res://autoload/ModLoaderWinControl/baseWin.tscn")

func edit(root_path:String):
	var new_win=BASE_WIN.instantiate()
	var new_editor=MOD_EDITOR.instantiate()
	new_win.add_child(new_editor)
	new_win.title=root_path
	add_child(new_win)
	new_editor.load_from_root_path(root_path)
	
	pass
