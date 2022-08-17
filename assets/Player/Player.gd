extends KinematicBody2D

const PlayerHurtSound = preload("res://assets/Player/PlayerHurtSound.tscn")

const ACCELERATION = 10
const MAX_SPEED = 150
const FRICTION = 8
const ROLL_SPEED = 1.5

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

enum {
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE

var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")
onready var swordHitBox = $HitBoxPivot/SwordHitBox
onready var hurtbox = $HurtBox

func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitBox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
			
		ROLL:
			roll_state(delta)
			
		ATTACK:
			attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_raw_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitBox.knockback_vector = roll_vector
		animationTree.set("parameters/idle/blend_position", input_vector)
		animationTree.set("parameters/run/blend_position", input_vector)
		animationTree.set("parameters/attack/blend_position", input_vector)
		animationTree.set("parameters/roll/blend_position", input_vector)
		animationState.travel("run")
		velocity += input_vector * ACCELERATION
		velocity = velocity.clamped(MAX_SPEED)
	else:
		animationState.travel("idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL

func roll_state(delta):
	velocity = roll_vector * MAX_SPEED * 1.5
	animationState.travel("roll")
	move()

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE
	
func attack_animation_finished():
	state = MOVE

func _on_HurtBox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invencibilyty(0.5)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)
