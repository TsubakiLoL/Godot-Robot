extends MarginContainer

signal value_changed(value)

##选择形态时的缓存
var select_value_cache:Array=[]
var select_name_cache:Array=[]

var section_cache:GlobalConfig.ConfigSection
var item_cache:GlobalConfig.ConfigItem


func build_item(section:GlobalConfig.ConfigSection,item:GlobalConfig.ConfigItem):
	section_cache=section
	item_cache=item
	%name_view.text=item_cache.item_view
	var now_value=GlobalConfig.get_item_value(section_cache.section_name,item_cache.item_name)
	var item_type=item.item_type
	
	
	
	if item_type is GlobalConfig.ConfigTypeText:
		%Text.show()
		%Select.hide()
		%Number.hide()
		%Bool.hide()
		%Text.secret=item_type.is_secret
		if now_value is String:
			%Text.text=now_value
	elif item_type is GlobalConfig.ConfigTypeBool:
		%Text.hide()
		%Select.hide()
		%Number.hide()
		%Bool.show()
		if now_value is bool:
			%Bool.set_pressed_no_signal(now_value)
	elif item_type is GlobalConfig.ConfigTypeSelect:
		%Text.hide()
		%Select.show()
		%Number.hide()
		%Bool.hide()
		select_value_cache=item_type.get_all_value()
		select_name_cache=[]
		%Select.clear()
		
		for i in select_value_cache:
			select_name_cache.append(item_type.get_value_name(i))
		for i in select_name_cache.size():
			%Select.add_item(select_name_cache[i],i)
		if now_value is String and select_value_cache.has(now_value):
			var index:int=select_value_cache.find(now_value)
			%Select.select(index)
		else:
			%Select.select(-1)
		
	elif item_type is GlobalConfig.ConfigTypeNumber:
		%Text.hide()
		%Select.hide()
		%Number.show()
		%Bool.hide()
		%Number.min_value=item_type.min
		%Number.max_value=item_type.max
		if now_value is int or now_value is float and item_type.is_legal(now_value):
			%Number.value=now_value


func _on_text_text_changed(new_text: String) -> void:
	if not item_cache.item_type.is_legal(new_text):
		return
	var now_value=GlobalConfig.get_item_value(section_cache.section_name,item_cache.item_name)
	if now_value!=new_text:
		GlobalConfig.set_item_value(section_cache.section_name,item_cache.item_name,new_text)
	pass # Replace with function body.


func _on_select_item_selected(index: int) -> void:
	if index>=select_value_cache.size():
		return 
	var new_value=select_value_cache[index]
	
	var now_value=GlobalConfig.get_item_value(section_cache.section_name,item_cache.item_name)
	if now_value!=new_value:
		GlobalConfig.set_item_value(section_cache.section_name,item_cache.item_name,new_value)
	pass # Replace with function body.


func _on_number_value_changed(value: float) -> void:
	if not item_cache.item_type.is_legal(value):
		return
	var now_value=GlobalConfig.get_item_value(section_cache.section_name,item_cache.item_name)
	if now_value!=value:
		GlobalConfig.set_item_value(section_cache.section_name,item_cache.item_name,value)
	pass # Replace with function body.


func _on_bool_toggled(toggled_on: bool) -> void:
	if not item_cache.item_type.is_legal(toggled_on):
		return
	var now_value=GlobalConfig.get_item_value(section_cache.section_name,item_cache.item_name)
	if now_value!=toggled_on:
		GlobalConfig.set_item_value(section_cache.section_name,item_cache.item_name,toggled_on)
	pass # Replace with function body.
