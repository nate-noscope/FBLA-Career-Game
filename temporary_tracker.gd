extends ColorRect

const MAXTICKS := 40

var ticks := 0

func _ready() -> void:
	if get_parent().get_parent() is Stock:
		color = get_parent().get_parent().color
		global_position = get_parent().get_parent().global_position - Vector2(2, 0)


func _on_timer_timeout() -> void:
	global_position += Vector2(-2, 0)
	ticks += 1
	if ticks >= MAXTICKS:
		queue_free()
