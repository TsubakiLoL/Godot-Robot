extends CanvasLayer

func start():
	$AnimationPlayer.play("start")
	$Control.show()
func stop():
	$AnimationPlayer.stop()
	$Control.hide()
