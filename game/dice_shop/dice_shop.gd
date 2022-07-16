extends PopupDialog

var dice_being_upgraded = null
signal upgraded_dice(diceObj, cost)

func _ready():
	var _ig = connect("about_to_show", self, "_on_about_to_show")

func _on_close_button_pressed():
	hide()

func _on_about_to_show():
	_set_available_gold(get_available_gold())

func reveal_with_dice(dice):
	dice_being_upgraded = dice
	popup_centered_ratio(1.0)

func _on_button_raise_minimum_pressed():
	if (get_available_gold() > 10):
		dice_being_upgraded.raise_minimum()
		emit_signal("upgraded_dice", dice_being_upgraded, 10)
		_set_available_gold(get_available_gold())

func _on_button_raise_maximum_pressed():
	if (get_available_gold() > 40):
		dice_being_upgraded.raise_maximum()
		emit_signal("upgraded_dice", dice_being_upgraded, 40)
		_set_available_gold(get_available_gold())

func _on_button_give_critical_pressed():
	if (get_available_gold() > 100):
		dice_being_upgraded.give_critical()
		emit_signal("upgraded_dice", dice_being_upgraded, 100)
		_set_available_gold(get_available_gold())

func get_available_gold():
	return get_parent().available_gold
	
func _set_available_gold(amount):
	_get_gold_label_node().text = "Gold: " + str(amount)

func _get_gold_label_node():
	return $MarginContainer/vbox_menu/button_row/gold_label
