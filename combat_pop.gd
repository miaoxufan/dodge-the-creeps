extends Node2D
var elapsed = 0.0

func _ready():
	add_to_group("projectiles")
	z_index = 4

func _process(delta):
	elapsed += delta
	if elapsed > 0.35:
		queue_free()
	queue_redraw()

func _draw():
	var t = elapsed / 0.35
	for i in range(7):
		var direction = Vector2.RIGHT.rotated(i*TAU/7)
		draw_line(direction*(10+t*25),direction*(18+t*30),Color(1,0.88,0.6,1-t),3,true)
