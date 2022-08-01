extends PopupDialog

var dice_being_upgraded = null
signal upgraded_dice(diceObj, cost)

onready var global_audio = get_node("/root/global_audio")

func _ready():
	var _ig = connect("about_to_show", self, "_on_about_to_show")

func _on_close_button_pressed():
	global_audio.play_ui()
	hide()

func _on_about_to_show():
	_set_available_gold(get_available_gold())
	_get_dice_sprite().texture = dice_being_upgraded.get_dice_texture_resource()
	_get_dice_sprite().modulate = dice_being_upgraded.get_dice_modulation()
	_get_raise_minimum_button().text = "Increase Minimum (" + str(get_minimum_cost()) + " Gold) (Currently: " + str(dice_being_upgraded.minimum) + ")"
	_get_raise_maximum_button().text = "Increase Maximum (" + str(get_maximum_cost()) + " Gold) (Currently: " + str(dice_being_upgraded.maximum) + ")"
	_get_crit_empower_description().text = get_crit_description(dice_being_upgraded.crit_level)
	if dice_being_upgraded.crit_level != "all":
		var next_crit_level = get_next_crit_level(dice_being_upgraded.crit_level)
		_get_can_crit_button().text = get_crit_empower_text(next_crit_level)
		_get_can_crit_button().show()
		_get_crit_label().hide()
	else:
		_get_can_crit_button().hide()
		_get_crit_label().show()

func get_next_crit_level(current_crit_level):
	match(current_crit_level):
		"none":
			return "highest"
		"highest":
			return "ten"
		"ten":
			return "five"
		"five":
			return "even"
		"even":
			return "all"

func get_crit_empower_cost(crit_level):
	match(crit_level):
		"highest":
			return 30
		"ten":
			return 50
		"five":
			return 100
		"even":
			return 500
		"all":
			return 5000
		_:
			return 0

func get_minimum_cost():
	return 18 + (dice_being_upgraded.minimum * 2) # default to 20, raise by 1 for every upgrade

func get_maximum_cost():
	return 3 + dice_being_upgraded.maximum # default to 5, raise by 1 for every upgrade

func get_crit_description(crit_level):
	match(crit_level):
		"none":
			return "This dice can't crit yet. Empower its critical to when you roll its highest value."
		"highest":
			return "This dice crits when it rolls its highest value. Empower it again to crit when you roll a multiple of 10."
		"ten":
			return "This dice crits are on any multiple of 10. Next level is any multiple of 5. Twice as good?"
		"five":
			return "This dice crits are on any multiple of 5. Next one is on all even numbers. Woh."
		"even":
			return "This dice is amazing. It crits on every even number. Next one is every time."
		"all":
			return "100% of the time it crits every time. Amazing."
		_:
			return "Please report this bug to the developer"

func get_crit_empower_text(crit_level):
	var cost = get_crit_empower_cost(crit_level)
	return "Empower Critical (" + str(cost) + " Gold)"

func reveal_with_dice(dice):
	dice_being_upgraded = dice
	popup_centered_ratio(1.0)

func _on_button_raise_minimum_pressed():
	global_audio.play_ui()
	var cost = get_minimum_cost()
	if (get_available_gold() >= cost && dice_being_upgraded.minimum < dice_being_upgraded.maximum / 2):
		dice_being_upgraded.raise_minimum()
		emit_signal("upgraded_dice", dice_being_upgraded, cost)
		_on_about_to_show()

func _on_button_raise_maximum_pressed():
	global_audio.play_ui()
	var cost = get_maximum_cost()
	if (get_available_gold() >= cost):
		dice_being_upgraded.raise_maximum()
		emit_signal("upgraded_dice", dice_being_upgraded, cost)
		_on_about_to_show()

func _on_button_give_critical_pressed():
	global_audio.play_ui()
	var next_crit_level = get_next_crit_level(dice_being_upgraded.crit_level)
	var crit_cost = get_crit_empower_cost(next_crit_level)
	if (get_available_gold() >= crit_cost):
		dice_being_upgraded.give_critical()
		emit_signal("upgraded_dice", dice_being_upgraded, crit_cost)
		_on_about_to_show()

func get_available_gold():
	return get_parent().available_gold
	
func _set_available_gold(amount):
	_get_gold_label_node().text = "Gold: " + str(amount)

func _get_gold_label_node():
	return $MarginContainer/vbox_menu/button_row/gold_label

func _get_dice_sprite():
	return $MarginContainer/vbox_menu/dice_sprite

func _get_raise_minimum_button():
	return $MarginContainer/vbox_menu/button_raise_minimum

func _get_raise_maximum_button():
	return $MarginContainer/vbox_menu/button_raise_maximum

func _get_can_crit_button():
	return $MarginContainer/vbox_menu/button_give_critical

func _get_crit_label():
	return $MarginContainer/vbox_menu/crit_purchased_label

func _get_crit_empower_description():
	return $MarginContainer/vbox_menu/crit_empower_description
