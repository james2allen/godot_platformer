extends Node2D

@onready var flag_sprite = $FlagSprite
var has_finished = false


func _on_finish_zone_body_entered(body):
	
	if !has_finished && body.is_in_group("player"):
		has_finished = true
		flag_sprite.animation = "finish"
		await get_tree().create_timer(1.25, false).timeout
		flag_sprite.animation = "finish_idle"
