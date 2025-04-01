extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func  request_search(content:String):
	AuthorAccount.request_from_data(AuthorAccount.REQUEST_TYPE.SEARCH_NODESET,
	{
		"content":content
	}
	,
	search_result_get
	)
	
func search_result_get(is_success:bool,data:Dictionary):
	if not data.has("nodeset"):
		return
		




func open_load():
	%load_animation.show()
	%animation.play("load")
	%item_add_pos.hide()
	for i in %item.get_children():
		i.queue_free()
func close_load():
	%load_animation.hide()
	%animation.stop()
	%item_add_pos.show()


func open_mes_load():
	%plugin_mes_panel.show()
	%mes_panel.hide()
	%load_animation_mes.show()
	%mes_load_animation.play("load")
	
	
	pass

func close_mes_load():
	%mes_panel.show()
	%load_animation_mes.hide()
	%mes_load_animation.stop()
	
	pass
