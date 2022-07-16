extends Node2D

var dice_being_dropped = null
var dice_being_dropped_position = null
var grid_unit_width = 24
var grid_unit_height = 18
var grid_unit_width_spacing = (grid_unit_width - 16) / 2
var grid_unit_height_spacing = (grid_unit_height - 16) / 2
var grid_border_spacing_width = 4
var grid_border_spacing_height = 4

func _ready():
	# start with two coins
	call_deferred("_on_new_dice_purchased", {"dice_type": "D2"})
	call_deferred("_on_new_dice_purchased", {"dice_type": "D2"})

func _on_picked_up(dice):
	_on_dice_drop_target_body_entered(dice)

func _on_dice_drop_target_body_entered(body):
	if body.is_grabbing:
		print("drop target body entered")
		dice_being_dropped = body
		body.set_drop_target(self)
		_update_drop_position()
		update()

func _on_dice_drop_target_body_exited(body):
	body.clear_drop_target(self)
	dice_being_dropped = null
	dice_being_dropped_position = null
	update()

func handle_dice_drop(dice):
	var drop_position = Vector2((dice_being_dropped_position.x * grid_unit_width) + grid_unit_width_spacing + grid_border_spacing_width, (dice_being_dropped_position.y * grid_unit_height) + grid_unit_height_spacing + grid_border_spacing_height)
	dice.position = to_global(drop_position)
	dice_being_dropped = null
	dice_being_dropped_position = null
	update()

func handle_dice_pickup():
	pass

func _process(_delta):
	if (dice_being_dropped != null):
		_update_drop_position()

func _on_new_dice_purchased(purchased_dice):
	var dice = load("res://game/dice/dice.tscn").instance()
	dice.IsHeroDice = true
	dice.dice_type = purchased_dice.dice_type
	dice.current_slot = self
	get_parent().add_child(dice)
	var next_open_slot = _get_open_slot()
	dice.position = to_global(_get_local_coordinates_from_grid_position(next_open_slot.x, next_open_slot.y))
	dice_being_dropped = null
	dice_being_dropped_position = null

func _get_open_slot():
	var heroes_dice = get_tree().get_nodes_in_group("heroes_dice")
	for x in range(6):
		for y in range(3):
			var grid_position = _get_local_coordinates_from_grid_position(x,y)
			var is_occupied = false
			for dice in heroes_dice:
				if (dice.position == to_global(grid_position)):
					is_occupied = true

			if !is_occupied:
				return Vector2(x,y)

func _get_local_coordinates_from_grid_position(x, y):
	return Vector2(grid_border_spacing_width + (x * grid_unit_width) + grid_unit_width_spacing, grid_border_spacing_height + (y * grid_unit_height) + grid_unit_height_spacing)

func _update_drop_position():
	# force it to match the grid
	var mouse_local_position = to_local(get_global_mouse_position())

	# each tile is 18x18 pixels
	dice_being_dropped_position = Vector2(floor(mouse_local_position.x / grid_unit_width), floor(mouse_local_position.y / grid_unit_height))
	dice_being_dropped_position.x = max(0, min(dice_being_dropped_position.x, 6))
	dice_being_dropped_position.y = max(0, min(dice_being_dropped_position.y, 3))
	update()

func _draw():
	if (dice_being_dropped != null):
		var top_left = _get_local_coordinates_from_grid_position(dice_being_dropped_position.x, dice_being_dropped_position.y)
		draw_line(top_left, top_left + Vector2(0, 16), Color.mediumblue)
		draw_line(top_left + Vector2(0, 16), top_left + Vector2(16, 16), Color.mediumblue)
		draw_line(top_left + Vector2(16, 16), top_left + Vector2(16, 0), Color.mediumblue)
		draw_line(top_left + Vector2(16, 0), top_left + Vector2(0, 0), Color.mediumblue)
