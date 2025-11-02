extends Node
class_name ChatSingleton

var singleton_name:String="未命名"

const GREEN=Color.GREEN
const RED=Color.RED



##打印调试信息
func l(message:String,color:Color=Color.WHITE):
	print_label_content(singleton_name,message,Color.GREEN,color)
##标签打印
func print_label_content(label:String,content:String,label_color:Color=Color.GREEN,content_color:Color=Color.WHITE):
	if OS.get_name()!="Web":
		print_rich("[color=#%s][%s]:[/color][color=#%s]%s[/color]"%[label_color.to_html(false),label,content_color.to_html(false),content])
	else:
		print_rich("[%s]:%s"%[label,content])
##使用表格的方式打印字典数组
func print_table(arr:Array[Dictionary],title:String=""):
	if title!="":
		print(title)
	if arr.is_empty():
		return
	var all_keys_cache:Array
	all_keys_cache=arr[0].keys()
	for i in arr:
		if  i is Dictionary:
			var j:int=0
			while j<all_keys_cache.size():
				if not i.has(all_keys_cache[j]):
					all_keys_cache.pop_at(j)
					j-=1
				j+=1
	var rich_text:String="[table=%d]"%[all_keys_cache.size()]
	for i in all_keys_cache:
		rich_text+="\n[cell border=#fff3 bg=#000]"+i+"[/cell]"
	for i in arr:
		if i is Dictionary:
			for j in all_keys_cache:
				rich_text+=("\n[td]"+str(i[j])+"[/td]")
				rich_text+="\n[cell border=#fff3 bg=#000]"+str(i[j])+"[/cell]"
	rich_text+="\n[/table]"
	print_rich(rich_text)
