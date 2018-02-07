tool
extends Spatial

func hide_roof():
	if Engine.editor_hint:
		hide()
	else:
		show()
