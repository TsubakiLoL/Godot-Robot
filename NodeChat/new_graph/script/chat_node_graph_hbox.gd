extends HBoxContainer



func init(control=null):
	if control is Node:
		%add_pos.add_child(control)

func set_left_right_name(left_name:String,right_name:String):
	%port_left.text=left_name
	%port_right.text=right_name
