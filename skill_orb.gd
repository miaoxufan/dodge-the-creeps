extends Area2D
var collected = false
var glow_time = randf() * TAU

func _ready():
	add_to_group("skill_orbs")
	$Visual.hide()

func _process(delta):
	glow_time += delta * 3.0
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO,11,Color(0.32,0.65,0.92,0.16+sin(glow_time)*0.05))
	draw_circle(Vector2.ZERO,8,Color("2a536c"))
	draw_circle(Vector2.ZERO,6.5,Color("59b7e5"))
	draw_circle(Vector2(-2,-2),2.5,Color("d4f4fb"))


func try_collect() -> bool:
	if collected or is_queued_for_deletion():
		return false
	collected = true
	hide()
	queue_free()
	return true
