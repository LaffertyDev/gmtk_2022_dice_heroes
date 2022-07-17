extends Node2D

var hero_type = "nameless_hero"
var hero_ability = "damage"
var is_entangled = false

func _ready():
	add_to_group("heroes")
	match hero_type:
		"nameless_hero":
			$Sprite.texture = load("res://game/assets/heroes/main_hero.png")
		"lilly":
			$Sprite.texture = load("res://game/assets/heroes/hero_lilly.png")
		"jackson":
			$Sprite.texture = load("res://game/assets/heroes/hero_jackson.png")
		"leah":
			$Sprite.texture = load("res://game/assets/heroes/hero_leah.png")

func roll_dice():
	if is_entangled:
		return 0

	if $dice_hero_drop_target.has_dice:
		return $dice_hero_drop_target.slotted_dice.roll_dice()
	else:
		return 0 # no dice, no attack

func has_dice():
	return $dice_hero_drop_target.has_dice

func set_entangled():
	is_entangled = true
	$entangled_sprite.show()

func _on_entangle_clicker_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.pressed:
		if event.pressed:
			is_entangled = false
			$entangled_sprite.hide()
