extends Node2D

func create_grass_effect():
	var GrassEffect = load("res://assets/Effects/GrassEffect.tscn")
	var grassEffect = GrassEffect.instance()
	var main = get_tree().current_scene
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_HurtBox_area_entered(area):
	create_grass_effect()
	queue_free()
