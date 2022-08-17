extends KinematicBody2D

const EnemyDeathEffect = preload("res://assets/Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 6
export var MAX_SPEED = 80
export var FRICTION = 4
export var WANDER_TARGET_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}
var state = CHASE

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 8)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 1)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.set_wander_timer(rand_range(1, 3))
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(wanderController.target_position)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
				
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position)
			else:
				state = IDLE
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * 6
	velocity = move_and_slide(velocity)

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.set_wander_timer(rand_range(1, 3))

func accelerate_towards_point(point):
	var direction = (point - global_position).normalized()
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 200
	hurtbox.start_invencibilyty(0.5)
	hurtbox.create_hit_effect()
	hurtbox.start_invencibilyty(0.4)

func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	enemyDeathEffect.global_position = global_position
	get_parent().add_child(enemyDeathEffect)
	queue_free()



func _on_HurtBox_invencibilyty_started():
	animationPlayer.play("Start")

func _on_HurtBox_invencibilyty_ended():
	animationPlayer.play("Stop")
