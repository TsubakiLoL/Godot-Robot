extends Node

#任务队列
var mission_array:Array[Dictionary]=[]
	
enum Type{
	ZIP=0,
	UNZIP=1
}


var example:Dictionary={
	"title":"xxx",
	"type":Type.ZIP,
	"from":"文件夹路径",
	"to":"压缩文件位置",
	"callback":func():pass,
}

enum State{
	FREE=0,
	ZIP=1,
	UNZIP=2,
}
var state:State=State.FREE:
	set(value):
		if value!=state:
			match value:
				State.FREE:
					set_process(false)
					%canvas.hide()
					pass
				State.ZIP:
					set_process(true)
					%canvas.show()
					pass
				State.UNZIP:
					set_process(true)
					%canvas.show()
					pass
		state=value
		
		pass
func mission_finished(res:bool):
	var callback=mission_array.front()["callback"]
	if callback is Callable and callback.is_valid() and res:
		callback.call()
	mission_array.pop_front()
	if mission_array.size()==0:
		print("任务完成")
		state=State.FREE
	else:
		exe_mission(mission_array.front())
	
	
	pass

#开始一个新任务
func start_mission(title:String,type:Type,from:String,to:String,callback=null):
	
	var data={
		"title":title,
		"type":type,
		"from":from,
		"to":to,
		"callback":callback,
	}
	if state==State.FREE:
		exe_mission(data)
	mission_array.append(data)
	
	pass


func exe_mission(data:Dictionary):
	var type=data["type"]
	var title=data["title"]
	var from=data["from"]
	var to=data["to"]
	%zip_title.text=title
	match type:
		Type.ZIP:
			state=State.ZIP
			%FileZip.start_zip(from,to)
			pass
		Type.UNZIP:
			state=State.UNZIP
			%FileUnzip.start_unzip(from,to)
			pass
	
	pass


func _process(delta: float) -> void:
	match state:
		State.FREE:
			
			set_process(false)
		State.ZIP:
			
			%zip_progress.value=100*%FileZip.get_progress()
			%zip_tip.text=%FileZip.tips
		State.UNZIP:
			%zip_progress.value=100*%FileUnzip.get_progress()
			%zip_tip.text=%FileUnzip.tips
	pass
