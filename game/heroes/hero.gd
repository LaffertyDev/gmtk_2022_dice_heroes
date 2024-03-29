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
		"thief":
			$Sprite.texture = load("res://game/assets/heroes/hero_thief.png")
		"bob":
			$Sprite.texture = load("res://game/assets/heroes/hero_bob.png")

func roll_dice():
	if is_entangled:
		return 0

	if $dice_hero_drop_target.has_dice:
		return $dice_hero_drop_target.slotted_dice.roll_dice(hero_ability)
	else:
		return 0 # no dice, no attack

func did_crit():
	if is_entangled:
		return false # dirty hack -- otherwise ranger can clear things

	if $dice_hero_drop_target.has_dice:
		return $dice_hero_drop_target.slotted_dice.did_crit()

	return false

func has_dice():
	return $dice_hero_drop_target.has_dice

func get_hero_dice():
	return $dice_hero_drop_target.slotted_dice

func clear_dice():
	if has_dice():
		get_tree().get_nodes_in_group("dice_tray")[0]._on_hero_despawned(self.get_hero_dice()) # move dice to tray
		$dice_hero_drop_target.handle_dice_pickup()

func is_hero_entangled():
	return is_entangled

func clear_entangle():
	is_entangled = false
	$entangled_sprite.hide()

func set_entangled():
	is_entangled = true
	$entangled_sprite.show()

func _on_entangle_clicker_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.pressed:
		if event.pressed:
			clear_entangle()
