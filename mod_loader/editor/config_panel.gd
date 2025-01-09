extends VBoxContainer



func load_config(dictionary:Dictionary):
	if dictionary.has("name"):
		%package_name.text=dictionary["name"]
	else:
		return
	%name_view.text=""
	if dictionary.has("name_view"):
		%name_view.text=dictionary["name_view"]
	if dictionary.has("autoload"):
		%autoload.dictionary=dictionary["autoload"]
	else:
		%autoload.dictionary={}
	if dictionary.has("node"):
		
		%node.dictionary=dictionary["node"]
	else:
		%node.dictionary={}
	if dictionary.has("triger"):
		%triger.dictionary=dictionary["triger"]
	else:
		%triger.dictionary={}
	if dictionary.has("panel"):
		%panel.dictionary=dictionary["panel"]
	else:
		%panel.dictionary={}
	if dictionary.has("i"):
		%introduction.text=dictionary["i"]

func get_config():
	var dic:Dictionary={}
	dic["name"]=%package_name.text
	if %name_view.text!="":
		dic["name_view"]=%name_view.text
	dic["autoload"]=%autoload.dictionary
	dic["node"]=%node.dictionary
	dic["triger"]=%triger.dictionary
	dic["panel"]=%panel.dictionary
	dic["i"]=%introduction.text
	return dic
