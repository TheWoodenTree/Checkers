extends Node2D
class_name Pawn

@onready var sprite = $sprite
@onready var shader = $sprite.material

var start_time: float = 0.0
var selected: bool = false
var elapsed_time: float
var color: String
var tile


func _process(_delta):
	if selected:
		elapsed_time = (Time.get_ticks_msec() - start_time) / 1000.0
		shader.set_shader_parameter("elapsedTime", elapsed_time)


func set_selected(s):
	selected = s
	start_time = Time.get_ticks_msec()
	shader.set_shader_parameter("selected", selected)
	if selected:
		sprite.modulate = Color.LIGHT_BLUE
	else:
		sprite.modulate = Color.WHITE
