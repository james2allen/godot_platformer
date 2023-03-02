extends Node2D

@export_enum("Banana", "Apple", "Cherry", "Melon")  var fruit = 0
@onready var banana_sprite = $BananaSprite
@onready var apple_sprite = $AppleSprite
@onready var cherry_sprite = $CherrySprite
@onready var melon_sprite = $MelonSprite

var fruit_dictionary: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	fruit_dictionary = {0: banana_sprite, 1: apple_sprite, 2: cherry_sprite, 3: melon_sprite}
	for key in fruit_dictionary:
		if fruit == key:
			fruit_dictionary[fruit].visible = true


func _on_fruit_collected_zone_body_entered(_body):
	fruit_dictionary[fruit].animation = "collected"
	await get_tree().create_timer(0.3, false).timeout
	fruit_dictionary[fruit].visible = false
