extends Node2D
var kind = "multishot"
var accent = Color("ba7743")

func _draw():
	draw_circle(Vector2.ZERO,44,Color("e4d2af"))
	draw_arc(Vector2.ZERO,44,0,TAU,48,Color("baa07a"),1.5,true)
	var ink = Color("534233")
	if "life" in kind:
		draw_circle(Vector2(-11,-9),14,Color("b65745"))
		draw_circle(Vector2(11,-9),14,Color("b65745"))
		draw_colored_polygon(PackedVector2Array([Vector2(-25,-5),Vector2(25,-5),Vector2(0,25)]),Color("b65745"))
		draw_arc(Vector2(-11,-9),8,PI,PI*1.55,12,Color("e7a181"),3,true)
	elif "speed" in kind or "dash" in kind:
		draw_colored_polygon(PackedVector2Array([Vector2(-8,-26),Vector2(12,-26),Vector2(8,7),Vector2(29,13),Vector2(29,25),Vector2(-16,25)]),accent)
		for i in range(3):
			draw_line(Vector2(-33,-15+i*12),Vector2(-17,-15+i*12),ink,3,true)
	elif "small" in kind:
		draw_circle(Vector2.ZERO,12,accent)
		for i in range(4):
			var direction = Vector2.RIGHT.rotated(PI*0.5*i)
			draw_line(direction*33,direction*18,ink,3,true)
			draw_line(direction*18,direction*24+direction.orthogonal()*5,ink,3,true)
	elif "flask" in kind:
		draw_circle(Vector2(0,6),22,accent)
		draw_rect(Rect2(-8,-26,16,25),accent)
		draw_rect(Rect2(-10,-29,20,6),ink)
		draw_circle(Vector2(-7,2),6,Color("f5ecd1"))
	elif "knife" in kind:
		draw_colored_polygon(PackedVector2Array([Vector2(-22,24),Vector2(26,-30),Vector2(23,-2),Vector2(-8,22)]),Color("f9f0d8"))
		draw_line(Vector2(-16,11),Vector2(0,27),accent,5,true)
		draw_line(Vector2(-23,30),Vector2(-10,17),ink,6,true)
	else:
		for i in range(3):
			var p = Vector2(-22+i*22,0)
			draw_rect(Rect2(p-Vector2(6,13),Vector2(12,30)),accent)
			draw_circle(p-Vector2(0,13),6,accent)
			draw_line(p+Vector2(-6,10),p+Vector2(6,10),ink,2,true)
	if kind.begins_with("skill"):
		draw_circle(Vector2(32,-30),12,Color("527e92"))
		draw_line(Vector2(26,-30),Vector2(38,-30),Color("fff1d8"),2,true)
		draw_line(Vector2(32,-36),Vector2(32,-24),Color("fff1d8"),2,true)
