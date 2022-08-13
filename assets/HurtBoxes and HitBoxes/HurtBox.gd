extends Area2D

export(bool) var show_effect = true

const HitEffect = preload("res://assets/Effects/HitEffect.tscn")

var invencible = false setget set_invencible

signal invencibilyty_started
signal invencibilyty_ended

onready var timer = $Timer

func set_invencible(value):
	invencible = value
	if invencible == true:
		emit_signal("invencibilyty_started")
	else:
		emit_signal("invencibilyty_ended")

func start_invencibilyty(duration):
	self.invencible = true
	timer.start(duration)

func _on_Timer_timeout():
	self.invencible = false
	
func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	effect.global_position = global_position - Vector2(0, 8)
	main.add_child(effect)
	


func _on_HurtBox_invencibilyty_started():
	set_deferred("monitoring", false)

func _on_HurtBox_invencibilyty_ended():
	monitoring = true
	
