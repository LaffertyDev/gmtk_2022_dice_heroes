extends Node2D

export var IsHeroDice = false

var is_mouse_over = false
var is_grabbing = false
var grabbed_offset = Vector2()
var cancel_position = Vector2()

var last_drag_position = Vector2()

var screen_width_pixels = ProjectSettings.get_setting("display/window/size/width")
var screen_height_pixels = ProjectSettings.get_setting("display/window/size/height")
var screen_boundary_drag_drop = 16

var next_drop_target = null
var current_slot = null

func _ready():
	self.input_pickable = IsHeroDice

func _on_dice_mouse_entered():
	is_mouse_over = true

func _on_dice_mouse_exited():
	is_mouse_over = false

func _on_dice_input_event(_viewport, event, _shape_idx):
	if !IsHeroDice || get_parent().is_adventure_started:
		return # cannot drag/drop dice if the adventure has started

	# this should only fire twice -- once on pick and once on release
	if event is InputEventMouseButton:
		if event.pressed && !is_grabbing:
			is_grabbing = event.pressed
			grabbed_offset = position - get_global_mouse_position()
			cancel_position = position
		elif is_grabbing:
			# verify that we are in bounds, otherwise reset
			if (next_drop_target != null):
				next_drop_target.handle_dice_drop(self)
				if current_slot != null:
					current_slot.handle_dice_pickup()
				current_slot = next_drop_target
				next_drop_target = null
				is_grabbing = false
			else:
				cancel_drag()

func _process(_delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && is_grabbing:
		var new_position = get_global_mouse_position() + grabbed_offset
		# keep the drag and drop within the screen so nothing gets lost
		last_drag_position = position
		position = Vector2(max(screen_boundary_drag_drop, min(new_position.x, screen_width_pixels - screen_boundary_drag_drop)), max(screen_boundary_drag_drop, min(new_position.y, screen_height_pixels - screen_boundary_drag_drop)))

		# if mouse goes off the screen, reset the dragging state
		if (new_position.x < 0 || new_position.x > screen_width_pixels || new_position.y < 0 || new_position.y > screen_height_pixels):
			cancel_drag()
	elif is_grabbing:
		# the code released without firing an event, probably because the mouse left the target
		cancel_drag()

func cancel_drag():
	is_grabbing = false
	position = cancel_position
	next_drop_target = null

func set_drop_target(target):
	next_drop_target = target

func clear_drop_target(_target_to_forget):
	next_drop_target = null

func roll_dice():
	return randi()%6 + 1