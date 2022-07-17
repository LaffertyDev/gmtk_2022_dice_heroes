extends PopupDialog

signal purchased_hero(characterObj)
signal purchased_dice(diceObj)

func _ready():
	var _ig = connect("about_to_show", self, "_on_about_to_show")

func _on_about_to_show():
	var character_container = _get_character_ui_container()
	for child in character_container.get_children():
		character_container.remove_child(child)
		child.queue_free()

	var upgrade_dice_container = _get_upgrade_dice_ui_container()
	for child in upgrade_dice_container.get_children():
		upgrade_dice_container.remove_child(child)
		child.queue_free()

	var purchase_dice_container = _get_purchase_dice_ui_container()
	for child in purchase_dice_container.get_children():
		purchase_dice_container.remove_child(child)
		child.queue_free()

	_set_available_gold(get_available_gold())

	var charactersEligibleForPurchase = get_eligible_characters()
	for character in charactersEligibleForPurchase:
		var sprite_res = load("res://game/assets/heroes/" + character.sprite_name)

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

		character_container.add_child(vbox_container)

	var dice_eligible_to_upgrade = get_dice_to_upgrade()
	for dice_eligible_for_upgrade in dice_eligible_to_upgrade:
		var dice_sprite_res = load("res://game/assets/dice/dice_d6.png")

		var vbox_container = VBoxContainer.new()
		var dice_label = Label.new()
		dice_label.text = dice_eligible_for_upgrade.dice_type + " m: " + str(dice_eligible_for_upgrade.minimum) + " m: " + str(dice_eligible_for_upgrade.maximum) + " c: " + str(dice_eligible_for_upgrade.can_crit)
		var sprite_center_container = CenterContainer.new()
		var dice_sprite = TextureRect.new()
		dice_sprite.texture = dice_eligible_for_upgrade.get_dice_texture_resource()

		sprite_center_container.add_child(dice_sprite)
		vbox_container.add_child(dice_label)
		vbox_container.add_child(sprite_center_container)
		var dice_upgrade_button = Button.new()
		dice_upgrade_button.connect("pressed", self, "_on_upgrade_dice_button_pressed", [dice_eligible_for_upgrade])
		dice_upgrade_button.text = "Upgrade Dice"
		vbox_container.add_child(dice_upgrade_button)

		upgrade_dice_container.add_child(vbox_container)

	var dice_eligible_to_purchase = get_dice_to_purchase()
	for dice_to_purchase in dice_eligible_to_purchase:
		var dice_sprite_res = load("res://game/assets/dice/" + dice_to_purchase.sprite)

		var vbox_container = VBoxContainer.new()
		var dice_label = Label.new()
		dice_label.text = dice_to_purchase.dice_type
		var sprite_center_container = CenterContainer.new()
		var dice_sprite = TextureRect.new()
		dice_sprite.texture = dice_sprite_res

		sprite_center_container.add_child(dice_sprite)
		vbox_container.add_child(dice_label)
		vbox_container.add_child(sprite_center_container)
		var dice_upgrade_button = Button.new()
		dice_upgrade_button.connect("pressed", self, "_on_purchase_dice_button_pressed", [dice_to_purchase, vbox_container])
		dice_upgrade_button.text = "Purchase Dice - " + str(dice_to_purchase.cost) + " Gold"
		vbox_container.add_child(dice_upgrade_button)

		purchase_dice_container.add_child(vbox_container)


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

func _on_upgrade_dice_button_pressed(dice):
	get_parent().show_dice_shop(dice)

func _on_purchase_dice_button_pressed(dice, dice_container):
	if (get_available_gold() > dice.cost):
		_set_available_gold(get_available_gold() - dice.cost)
		emit_signal("purchased_dice", dice)
		dice_container.get_parent().remove_child(dice_container)
		dice_container.queue_free()

func _build_purchased_label():
	var purchased_label = Label.new()
	purchased_label.text = "X"
	return purchased_label

func get_eligible_characters():
	return get_parent().available_characters

func get_dice_to_upgrade():
	return get_tree().get_nodes_in_group("heroes_dice")

func get_dice_to_purchase():
	var dice_eligible_for_purchase = []
	dice_eligible_for_purchase.append({"dice_type": "D2", "sprite": "dice_d2.png", "cost": 3})
	dice_eligible_for_purchase.append({"dice_type": "D4", "sprite": "dice_d4.png", "cost": 5})
	dice_eligible_for_purchase.append({"dice_type": "D6", "sprite": "dice_d6.png", "cost": 7})
	dice_eligible_for_purchase.append({"dice_type": "D8", "sprite": "dice_d8.png", "cost": 9})
	dice_eligible_for_purchase.append({"dice_type": "D12", "sprite": "dice_d12.png", "cost": 13})
	dice_eligible_for_purchase.append({"dice_type": "D20", "sprite": "dice_d20.png", "cost": 21})
	return dice_eligible_for_purchase

func get_available_gold():
	return get_parent().available_gold

func _get_character_ui_container():
	return $MarginContainer/vbox_menu/hbox_char_container

func _get_upgrade_dice_ui_container():
	return $MarginContainer/vbox_menu/hbox_upgrade_dice_container

func _get_purchase_dice_ui_container():
	return $MarginContainer/vbox_menu/hbox_buy_dice_container

func _set_available_gold(amount):
	_get_gold_label_node().text = "Gold: " + str(amount)

func _get_gold_label_node():
	return $MarginContainer/vbox_menu/HBoxContainer/gold_label
