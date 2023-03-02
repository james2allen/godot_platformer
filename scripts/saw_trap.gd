extends AnimatableBody2D

@export var end_position: Vector2
var time = 0
@export var speed: float = 60
@export var moveDuration: float = 2.0
@export var inverseMove: bool = false
@onready var path_follow: PathFollow2D = get_parent()


func _process(delta):
	time += delta
	var t = time / moveDuration if !inverseMove else 1- time / moveDuration
	if time >= moveDuration:
		time = 0
	path_follow.set_progress_ratio(lerp(0.0, 1.0, t))

func _on_kill_zone_body_entered(body):
	if body.is_in_group("player"):
		body._on_Player_death()
