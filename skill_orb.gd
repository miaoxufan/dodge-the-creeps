extends Area2D

func _ready():
	add_to_group("skill_orbs")


func _on_area_entered(area):
	if area.is_in_group("player"):
		get_tree().current_scene._on_skill_orb_collected()
		queue_free()
