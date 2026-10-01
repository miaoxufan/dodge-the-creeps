extends Area2D

var owner_player: Node2D
var rotation_speed = 5.5
var orbit_radius = 0.0
var skill_orb_scene = preload("res://skill_orb.tscn")

func setup(player, angle_offset = 0.0, speed = 5.5, radius = 0.0):
	owner_player = player
	rotation = angle_offset
	rotation_speed = speed
	orbit_radius = radius
	global_position = player.global_position

func _process(delta):
	if is_instance_valid(owner_player):
		global_position = owner_player.global_position + Vector2.RIGHT.rotated(rotation) * orbit_radius
	rotation += rotation_speed * delta

func _on_body_entered(body):
	if not body.is_in_group("mobs"):
		return

	var skill_orb = skill_orb_scene.instantiate()
	skill_orb.position = body.position
	get_parent().add_child(skill_orb)
	body.defeated.emit()
	body.queue_free()
