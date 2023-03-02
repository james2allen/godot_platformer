extends CharacterBody2D

enum Direction {Up, Left, Right, Down}

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -350.0
const WALL_BOUNCE_VELOCITY: float = 200.0
const BOUNCE_VELOCITY: float = -800
const WALL_SLIDE_MAX_SPEED: float = 300
const JUMP_GRAVITY: int = 980
const FALL_GRAVITY: int = 2000

var gravity: int = JUMP_GRAVITY
var double_jump: bool = true
var last_wall_normal: int = 0
var recent_wall_jump: bool = false
var player_death: bool = false
var coyote_timer_ready: bool = true
var coyote_time: bool = false
var spawn_point: Vector2
var is_on_wall: bool = false
var first_jump: bool = true
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var run_particles: CPUParticles2D = $RunParticles
@onready var left_wall_particles: CPUParticles2D = $LeftWallParticles
@onready var right_wall_particles: CPUParticles2D = $RightWallParticles

func _ready():
	spawn_point = position

func _jump(speed: float):
	velocity.y = speed
	gravity = JUMP_GRAVITY
	
func _bounce(direction: Direction):
	if(direction == Direction.Up):
		_jump(BOUNCE_VELOCITY)
		first_jump = false
	if(direction == Direction.Right):
		velocity.x = BOUNCE_VELOCITY * -1
	if(direction == Direction.Left):
		velocity.x = BOUNCE_VELOCITY
	if(direction == Direction.Down):
		velocity.y = BOUNCE_VELOCITY * -1
	
	
func _on_Player_death():
	player_death = true
	velocity = Vector2.ZERO
	gravity = 0
	await get_tree().create_timer(0.35, false).timeout
	get_tree().reload_current_scene()
	position = spawn_point
	gravity = FALL_GRAVITY
	player_death = false
	
func handleAirMovement(delta):
	if is_on_wall:
		if velocity.y > WALL_SLIDE_MAX_SPEED:
			velocity.y = WALL_SLIDE_MAX_SPEED
		var wall_normal = get_wall_normal()
		if wall_normal.x == 1:
			left_wall_particles.set_emitting(true)
			right_wall_particles.set_emitting(false)
		else:
			right_wall_particles.set_emitting(true)
			left_wall_particles.set_emitting(false)
	run_particles.set_emitting(false)
	# Coyote time winfow
	if coyote_timer_ready:
		coyote_timer_ready = false
		coyote_time = true
		await get_tree().create_timer(0.15, false).timeout
		coyote_time = false
	if not Input.is_action_pressed("ui_accept"):
		gravity = FALL_GRAVITY
	velocity.y += gravity * delta

func _set_animations():
	if player_death:
		animated_sprite.animation = "death"
		return
	
	if not is_on_floor():
		if is_on_wall:
			animated_sprite.animation = "wall_jump"
		else:
			if velocity.y < 0:
				if !double_jump || !first_jump:
					animated_sprite.animation = "double_jump"
				else:
					animated_sprite.animation = "jump"
			else:
				animated_sprite.animation = "fall"
	else:
		animated_sprite.animation = "idle" if velocity.x == 0 else "run"

func _physics_process(delta):
	if(velocity.y > 0):
		gravity = FALL_GRAVITY
	
	# Add the gravity.
	if not is_on_floor():
		handleAirMovement(delta)
	else:
		double_jump = true
		last_wall_normal = 0
		gravity = JUMP_GRAVITY
		coyote_timer_ready = true
		first_jump = true
		left_wall_particles.set_emitting(false)
		right_wall_particles.set_emitting(false)
	
	if not is_on_wall:
		left_wall_particles.set_emitting(false)
		right_wall_particles.set_emitting(false)
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction:
		if not recent_wall_jump:
			velocity.x = move_toward(velocity.x, direction* SPEED, 100)
		if is_on_floor() && !player_death:
			run_particles.set_emitting(true)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, 100)
			run_particles.set_emitting(false)


	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() || coyote_time:
			_jump(JUMP_VELOCITY)
			coyote_time = false
		else:
			if is_on_wall and last_wall_normal != get_wall_normal().x:
				first_jump = false
				var normal: Vector2 = get_wall_normal()
				velocity.x = WALL_BOUNCE_VELOCITY * normal.x
				_jump(JUMP_VELOCITY)
				recent_wall_jump = true
				await get_tree().create_timer(0.2, false).timeout
				recent_wall_jump = false
				last_wall_normal = normal.x
			else:
				if double_jump:
					velocity.y = JUMP_VELOCITY
					gravity = JUMP_GRAVITY
					first_jump = false
					double_jump = false
					
	# flip sprite depending on direction
	if(velocity.x <0):
		animated_sprite.flip_h = true
	else:
		if(velocity.x > 0):
			animated_sprite.flip_h = false
	
	if player_death:
		velocity = Vector2.ZERO

	_set_animations()
	move_and_slide()

#below code to deal with flickering during wall collisions
func _on_is_on_wall_body_entered(body):
	if body.is_in_group("terrain"):
		is_on_wall = true

func _on_is_on_wall_body_exited(body):
	if body.is_in_group("terrain"):
		is_on_wall = false
