#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------



extends HTTPRequest

class_name OllamaChatRequest
@export var model="llama2"
@export var API:String="http://localhost:11434/api/generate"
signal request_complete(responce:String)
signal request_failed

func _ready() -> void:
	request_completed.connect(_on_request_completed)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var res=body.get_string_from_utf8()
	#print(res)
	var dic=JSON.parse_string(res)
	if dic is Dictionary:
		if dic.has("done") and dic["done"] is bool and dic["done"] and dic.has("response") and dic["response"] is String:
			request_complete.emit(dic["response"])
		else:
			request_failed.emit()
	request_failed.emit()
			
	pass # Replace with function body.
func ollama_chat_request(str:String):
	var dic={
  	"model": model,
 	"prompt": "Why is the sky blue?",
  	"stream": false
	}
	dic["prompt"]=str
	request(API,PackedStringArray(),HTTPClient.METHOD_POST,JSON.stringify(dic))
