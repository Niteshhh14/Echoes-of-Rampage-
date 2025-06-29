extends ParallaxBackground


var scrolling_speed=100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_offset.x-=scrolling_speed*delta
