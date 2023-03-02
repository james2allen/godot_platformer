extends CharacterBody2D

enum Direction {Up, Left, Right, Down}
@export var directions_array: Array[Direction]
@export var speed: float = 700
@export var delay_time: float = 0.2
@onready var animated_sprite = $AnimatedSprite2D
var direction_index: int = 0
var current_direction: Direction
var collided = false;

func _ready():
	if(directions_array.size() > 0): 
		current_direction = directions_array[direction_index]
	else:
		current_direction = Direction.Right

	
func get_direction_vector(direction: Direction) -> Vector2:
	if direction == Direction.Up:
		return Vector2(0, -1)
	if direction == Direction.Down:
		return Vector2(0, 1)
	if direction == Direction.Left:
		return Vector2(-1, 0)
	if direction == Direction.Right:
		return Vector2(1, 0)
	return Vector2.ZERO

func _physics_process(delta):
	velocity = velocity.move_toward(get_direction_vector(current_direction) * speed, delta * speed)
	move_and_slide()

func _handle_collision():
	velocity = Vector2.ZERO
	animated_sprite.animation = "x_hit" if current_direction == Direction.Left || current_direction == Direction.Right else "y_hit"
	await get_tree().create_timer(0.2, false).timeout
	animated_sprite.animation = "default"
	await get_tree().create_timer(delay_time, false).timeout
	direction_index = (direction_index + 1) % (directions_array.size())
	current_direction = directions_array[direction_index]
	velocity = Vector2.ZERO
	

func _on_right_collision_body_entered(body):
	if(body.is_in_group("terrain") && current_direction == Direction.Right):
		_handle_collision()
	if body.is_in_group("player"):
		body._on_Player_death()


func _on_left_collision_body_entered(body):
	if(body.is_in_group("terrain") && current_direction == Direction.Left):
		_handle_collision()
	if body.is_in_group("player"):
		body._on_Player_death()


func _on_down_collision_body_entered(body):
	if(body.is_in_group("terrain") && current_direction == Direction.Down):
		_handle_collision()
	if body.is_in_group("player"):
		body._on_Player_death()


func _on_up_collision_body_entered(body):
	if(body.is_in_group("terrain") && current_direction == Direction.Up):
		_handle_collision()
	if body.is_in_group("player"):
		body._on_Player_death()
