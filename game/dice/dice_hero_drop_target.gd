extends Node2D

var is_dice_hovering = false
var has_dice = false
var slotted_dice = null

func _ready():
	add_to_group("dice_hero_drop_target")


func _on_picked_up(dice):
	pass

func _on_dice_drop_target_body_entered(body):
	if has_dice:
		return

	body.set_drop_target(self)
	is_dice_hovering = true
	body.set_drop_target(self)
	update()

func _on_dice_drop_target_body_exited(body):
	if has_dice:
		return

	body.clear_drop_target(body)
	is_dice_hovering = false
	update()

func handle_dice_drop(dice):
	slotted_dice = dice
	var drop_position = self.get_global_position();
	drop_position.x = drop_position.x + 24
	dice.position = drop_position
	is_dice_hovering = false
	has_dice = true
	update()

func handle_dice_pickup():
	slotted_dice = null
	has_dice = false
	is_dice_hovering = false
	update()

func _draw():
	if is_dice_hovering:
		draw_line(Vector2(0, 0), Vector2(0, 16), Color.mediumblue)
		draw_line(Vector2(0, 16), Vector2(16, 16), Color.mediumblue)
		draw_line(Vector2(16, 16), Vector2(16, 0), Color.mediumblue)
		draw_line(Vector2(16, 0), Vector2(0, 0), Color.mediumblue)
