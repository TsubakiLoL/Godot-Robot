extends VBoxContainer

const CONFIG_ITEM = preload("uid://bfclapt4atw65")


var section_cache:GlobalConfig.ConfigSection
func build_section(section:GlobalConfig.ConfigSection):
	%SectionName.text=section.section_view
	for i in %add_pos.get_children():
		i.queue_free()
	section_cache=section
	for i in section_cache.item_db.values():
		var new_config_item=CONFIG_ITEM.instantiate()
		%add_pos.add_child(new_config_item)
		new_config_item.build_item(section_cache,i)
