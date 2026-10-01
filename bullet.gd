extends Area2D

@export var speed = 700.0
var direction = Vector2.RIGHT
var skill_orb_scene = preload("res://skill_orb.tscn")


func _process(delta):
	position += direction * speed * delta

	var screen_size = get_viewport().get_visible_rect().size
	if position.x < -50 or position.x > screen_size.x + 50:
		queue_free()
	if position.y < -50 or position.y > screen_size.y + 50:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("mobs"):
		var skill_orb = skill_orb_scene.instantiate()
		skill_orb.position = body.position
		get_parent().add_child(skill_orb)
		body.defeated.emit()
		body.queue_free()
		queue_free()
