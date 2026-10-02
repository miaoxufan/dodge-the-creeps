extends Area2D

@export var speed = 700.0
var direction = Vector2.RIGHT
var skill_orb_scene = preload("res://skill_orb.tscn")

func _ready():
	add_to_group("projectiles")
	z_index = 3
	$Visual.color = Color("e9ba58")

func _draw():
	draw_circle(Vector2.ZERO, 9, Color("68482e"))
	draw_circle(Vector2.ZERO, 7, Color("ffdf7b"))
	draw_line(-direction*15, -direction*7, Color(0.96,0.73,0.34,0.6),3,true)


func _process(delta):
	position += direction * speed * delta

	var screen_size = get_viewport().get_visible_rect().size
	if position.x < -50 or position.x > screen_size.x + 50:
		queue_free()
	if position.y < -50 or position.y > screen_size.y + 50:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("mobs"):
		body.defeat()
		queue_free()
