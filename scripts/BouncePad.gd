extends StaticBody2D


@export_enum("Up", "Left", "Right", "Down")  var bounce_direction = 0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	animated_sprite.animation = "default"

func _on_bounce_zone_body_entered(body):
	if body.is_in_group("player"):
		body._bounce(bounce_direction)
		animated_sprite.animation = "bounce"
		await get_tree().create_timer(0.35, false).timeout
		animated_sprite.animation = "default"
