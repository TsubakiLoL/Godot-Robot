
#----------------------
#版权所有：
#	李志鹏
#	新疆大学 计算机科学与技术学院 
#	计算机科学与技术 21-3班
#	毕业设计
#	学号：20211401239
#----------------------


extends Control
@export var word_set:SingleWord
@onready var tree: Tree = $Tree
@onready var word_name: Label = $ScrollContainer/VBoxContainer/name
@onready var word_intro: RichTextLabel = $ScrollContainer/VBoxContainer/intro
var tree_item_with_word:Dictionary={}
func _ready() -> void:
	inst(word_set,tree.create_item())
func inst(word:SingleWord,par:TreeItem):
	if word!=null:
		tree_item_with_word[par]=word
		par.set_text(0,word.name)
		for i in word.next_word_array:
			var new_tree_item=par.create_child()
			inst(i,new_tree_item)
		
func clear():
	tree_item_with_word.clear()
	tree.clear()
	tree.create_item()






func _on_tree_item_selected() -> void:
	var real_single=tree_item_with_word[tree.get_selected()] as SingleWord
	word_name.text=real_single.name
	word_intro.text=real_single.doc
	pass # Replace with function body.
