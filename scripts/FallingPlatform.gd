extends CharacterBody2D

@export var fall_delay: float = 2.0
var is_moving = false


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		await get_tree().create_timer(fall_delay, false).timeout
		set_collision_mask_value(1, false) 
		is_moving = true

func _physics_process(_delta):
	velocity.y = 500 if is_moving else 0
	move_and_slide()
