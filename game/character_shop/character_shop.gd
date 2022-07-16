extends PopupDialog

signal purchased_hero(characterObj)

func _ready():
	var _ig = connect("about_to_show", self, "_on_about_to_show")

func _on_about_to_show():
	var container = _get_character_ui_container()
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	_set_available_gold(get_available_gold())

	var charactersEligibleForPurchase = get_eligible_characters()
	for character in charactersEligibleForPurchase:
		var sprite_res = load("res://game/assets/" + character.sprite_name)

		var vbox_container = VBoxContainer.new()
		var char_label = Label.new()
		char_label.text = character.name
		var sprite_center_container = CenterContainer.new()
		var char_sprite = TextureRect.new()
		char_sprite.texture = sprite_res

		sprite_center_container.add_child(char_sprite)
		vbox_container.add_child(char_label)
		vbox_container.add_child(sprite_center_container)
		if character.is_purchased:
			vbox_container.add_child(_build_purchased_label())
		else:
			var char_buy_button = Button.new()
			char_buy_button.connect("pressed", self, "_on_buy_button_pressed", [character, char_buy_button])
			char_buy_button.text = str(character.cost) + " Gold"
			vbox_container.add_child(char_buy_button)

		container.add_child(vbox_container)

func _on_button_close_shop_pressed():
	hide()

func _on_buy_button_pressed(character, char_buy_button):
	if (get_available_gold() > character.cost):
		_set_available_gold(get_available_gold() - character.cost)
		character.is_purchased = true
		emit_signal("purchased_hero", character)
		char_buy_button.get_parent().add_child(_build_purchased_label())
		char_buy_button.get_parent().remove_child(char_buy_button)
		char_buy_button.queue_free()

func _build_purchased_label():
	var purchased_label = Label.new()
	purchased_label.text = "X"
	return purchased_label

func get_eligible_characters():
	return get_parent().available_characters

func get_available_gold():
	return get_parent().available_gold

func _get_character_ui_container():
	return $MarginContainer/vbox_menu/hbox_char_container

func _set_available_gold(amount):
	_get_gold_label_node().text = "Gold: " + str(amount)

func _get_gold_label_node():
	return $MarginContainer/vbox_menu/HBoxContainer/gold_label
