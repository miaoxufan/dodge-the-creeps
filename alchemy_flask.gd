extends Node2D

var target = Vector2.ZERO
var origin = Vector2.ZERO
var blast_radius = 105.0
var flight_time = 0.6
var elapsed = 0.0
var exploded = false

func _ready():
	add_to_group("projectiles")
	origin = position
	z_index = 3

func _process(delta):
	elapsed += delta
	if not exploded:
		var t = minf(elapsed / flight_time, 1.0)
		position = origin.lerp(target, t) + Vector2(0, -sin(t * PI) * 85.0)
		if t >= 1.0:
			exploded = true
			elapsed = 0.0
			position = target
			# Snapshot targets first; deferred reward delivery cannot replace an open choice.
			for mob in get_tree().get_nodes_in_group("mobs"):
				if is_instance_valid(mob) and mob.global_position.distance_to(global_position) <= blast_radius:
					mob.defeat()
	elif elapsed > 0.42:
		queue_free()
	queue_redraw()

func _draw():
	if not exploded:
		draw_circle(Vector2.ZERO, 13, Color("302d28"))
		draw_circle(Vector2.ZERO, 10, Color("79aa67"))
		draw_circle(Vector2(-3,-3), 4, Color("d8efaf"))
		draw_rect(Rect2(-4,-17,8,9), Color("e4ba75"))
		draw_arc(Vector2.ZERO, 15, 0.3, 2.2, 16, Color("dfedb0"), 2.0, true)
	else:
		var t = clampf(elapsed / 0.42, 0, 1)
		var r = blast_radius * (0.65 + 0.35*t)
		draw_circle(Vector2.ZERO, r, Color(0.5,0.68,0.3,(1-t)*0.3))
		draw_arc(Vector2.ZERO,r,0,TAU,64,Color(0.9,0.96,0.62,1-t),4,true)
		for i in range(12):
			var p = Vector2.RIGHT.rotated(i*TAU/12) * r * 0.85
			draw_circle(p, (1-t)*9+2, Color(0.7,0.87,0.43,1-t))
