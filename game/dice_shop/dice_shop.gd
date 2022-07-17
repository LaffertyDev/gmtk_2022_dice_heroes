extends PopupDialog

var dice_being_upgraded = null
signal upgraded_dice(diceObj, cost)

var raise_minimum_cost = 20
var raise_maximum_cost = 10
var empower_critical_cost = 50

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
	_get_raise_minimum_button().text = "Increase Minimum (" + str(raise_minimum_cost) + " Gold) (Currently: " + str(dice_being_upgraded.minimum) + ")"
	_get_raise_maximum_button().text = "Increase Maximum (" + str(raise_maximum_cost) + " Gold) (Currently: " + str(dice_being_upgraded.maximum) + ")"
	_get_can_crit_button().text = "Empower Critical (" + str(empower_critical_cost) + "Gold) (Currently: " + str(dice_being_upgraded.can_crit) + ")"


func reveal_with_dice(dice):
	dice_being_upgraded = dice
	popup_centered_ratio(1.0)

func _on_button_raise_minimum_pressed():
	global_audio.play_ui()
	if (get_available_gold() >= raise_minimum_cost && dice_being_upgraded.minimum < dice_being_upgraded.maximum):
		dice_being_upgraded.raise_minimum()
		emit_signal("upgraded_dice", dice_being_upgraded, raise_minimum_cost)
		_on_about_to_show()

func _on_button_raise_maximum_pressed():
	global_audio.play_ui()
	if (get_available_gold() >= raise_maximum_cost):
		dice_being_upgraded.raise_maximum()
		emit_signal("upgraded_dice", dice_being_upgraded, raise_maximum_cost)
		_on_about_to_show()

func _on_button_give_critical_pressed():
	global_audio.play_ui()
	if (get_available_gold() >= empower_critical_cost && !dice_being_upgraded.can_crit):
		dice_being_upgraded.give_critical()
		emit_signal("upgraded_dice", dice_being_upgraded, empower_critical_cost)
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
