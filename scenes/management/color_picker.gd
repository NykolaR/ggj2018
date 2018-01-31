extends Control

func _ready():
	randomize()
	randomize()
	randomize()
	
	$slider.value = rand_range(0,1)
	#slider_changed(rand_range(0,1))

func slider_changed( value ):
	$color.modulate.h = value