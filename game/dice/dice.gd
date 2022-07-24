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

var can_crit = false

var is_in_play = false

onready var global_audio = get_node("/root/global_audio")

var minimum = 1
var maximum = 6
var rng = RandomNumberGenerator.new()
export var dice_type = "D6"

func _ready():
	rng.randomize()
	self.input_pickable = IsHeroDice
	if (IsHeroDice):
		add_to_group("heroes_dice")
	if (dice_type == "D2"):
		minimum = 1
		maximum = 2
	elif (dice_type == "D4"):
		minimum = 1
		maximum = 4
	elif (dice_type == "D6"):
		minimum = 1
		maximum = 6
	elif (dice_type == "D8"):
		minimum = 1
		maximum = 8
	elif (dice_type == "D12"):
		minimum = 1
		maximum = 12
	elif (dice_type == "D20"):
		minimum = 1
		maximum = 20
	$Sprite.texture = get_dice_texture_resource()
	_update_range_label()
	if !is_in_play:
		$range_label.show()
	if (!IsHeroDice):
		$range_label.hide()
		# for enemy dice, they need to be on the left
		if (minimum < 10 && maximum < 10):
			$range_label.rect_position.x = -19
		else:
			$range_label.rect_position.x = -32

	$Sprite.modulate = Color(randf(), randf(), randf())


func get_dice_texture_resource():
	if (dice_type == "D2"):
		return load("res://game/assets/dice/dice_d2.png")
	elif (dice_type == "D4"):
		return load("res://game/assets/dice/dice_d4.png")
	elif (dice_type == "D6"):
		return load("res://game/assets/dice/dice_d6.png")
	elif (dice_type == "D8"):
		return load("res://game/assets/dice/dice_d8.png")
	elif (dice_type == "D12"):
		return load("res://game/assets/dice/dice_d12.png")
	elif (dice_type == "D20"):
		return load("res://game/assets/dice/dice_d20.png")
	else:
		return load("res://game/assets/dice/dice_d2.png")

func get_friendly_dice_name_from_type():
	if (dice_type == "D2"):
		return "2-sided die"
	elif (dice_type == "D4"):
		return "4-sided die"
	elif (dice_type == "D6"):
		return "6-sided die"
	elif (dice_type == "D8"):
		return "8-sided die"
	elif (dice_type == "D12"):
		return "12-sided die"
	elif (dice_type == "D20"):
		return "20-sided die"
	else:
		return "???"
func _on_dice_mouse_entered():
	is_mouse_over = true
	$range_label.show()

func _on_dice_mouse_exited():
	is_mouse_over = false
	if is_in_play:
		# dice in inventory do not hide
		$range_label.hide()

func _on_dice_input_event(_viewport, event, _shape_idx):
	if !IsHeroDice || get_parent().is_adventure_started:
		return # cannot drag/drop dice if the adventure has started

	# this should only fire twice -- once on pick and once on release
	if event is InputEventMouseButton:
		if event.pressed && !is_grabbing:
			global_audio.play_dice_pickup()
			is_grabbing = event.pressed
			grabbed_offset = position - get_global_mouse_position()
			cancel_position = position
			if current_slot != null:
				current_slot._on_picked_up(self)
		elif is_grabbing:
			# verify that we are in bounds, otherwise reset
			if (next_drop_target != null && next_drop_target.can_drop(self)):
				global_audio.play_dice_place()
				self.is_in_play = false
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
		$dice_reset_delay_timer.start()

func _on_dice_reset_delay_timer_timeout():
	# on html builds, the event doesn't fire before we detect the input
	# so delay it
	if is_grabbing:
		cancel_drag()

func cancel_drag():
	is_grabbing = false
	position = cancel_position
	next_drop_target = null

func set_drop_target(target):
	next_drop_target = target

func clear_drop_target(_target_to_forget):
	next_drop_target = null

func roll_dice(ability_type):
	match(ability_type):
		"damage":
			$dice_roll_amount_label.modulate = Color(1.0,0.0,0.0,1.0)
		"heal":
			$dice_roll_amount_label.modulate = Color(0.0,1.0,0.0,1.0)
		_:
			$dice_roll_amount_label.modulate = Color(0.0,0.0,1.0,1.0)
	$dice_tween.remove_all()
	$dice_roll_amount_label.rect_position = Vector2(5,0)
	$dice_roll_amount_label.show()
	$dice_tween.interpolate_property($dice_roll_amount_label, "rect_position", $dice_roll_amount_label.rect_position, $dice_roll_amount_label.rect_position + Vector2(0, -10), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$dice_tween.interpolate_property($dice_roll_amount_label, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$dice_tween.interpolate_property($Sprite, "rotation_degrees", 0, 360, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$dice_tween.start()
	var number_rolled = rng.randi_range(minimum, maximum)
	if can_crit && number_rolled == maximum:
		$dice_roll_amount_label.text = str(number_rolled * 2)
		return number_rolled * 2 # crit
	$dice_roll_amount_label.text = str(number_rolled)
	return number_rolled

func raise_minimum():
	minimum += 1
	_update_range_label()

func raise_maximum():
	maximum += 1
	_update_range_label()

	var upgraded_dice_type = dice_type
	if maximum < 4:
		upgraded_dice_type = "D2"
	elif maximum < 6:
		upgraded_dice_type = "D4"
	elif maximum < 8:
		upgraded_dice_type = "D6"
	elif maximum < 12:
		upgraded_dice_type = "D8"
	elif maximum < 20:
		upgraded_dice_type = "D12"
	else:
		upgraded_dice_type = "D20"

	if upgraded_dice_type != dice_type:
		dice_type = upgraded_dice_type
		$Sprite.texture = get_dice_texture_resource()


func _update_range_label():
	if can_crit:
		$range_label.text = str(minimum) + "-" + str(maximum) + "*"
	else:
		$range_label.text = str(minimum) + "-" + str(maximum)

func give_critical():
	can_crit = true

func set_collision_disabled(is_disabled):
	$mouse_collision_shape.disabled = is_disabled

func get_dice_modulation():
	return $Sprite.modulate

func _on_dice_tween_tween_all_completed():
	$dice_roll_amount_label.hide()

