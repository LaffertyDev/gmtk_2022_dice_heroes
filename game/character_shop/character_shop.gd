extends PopupDialog

signal purchased_hero(characterObj)
signal purchased_dice(diceObj)
signal sent_hero(characterObj)
signal retracted_hero(characterObj)
signal purchased_health(cost, amount)

onready var global_audio = get_node("/root/global_audio")

func _ready():
	var _ig = connect("about_to_show", self, "_on_about_to_show")

func _on_about_to_show():
	var current_heroes = get_tree().get_nodes_in_group("heroes")
	var character_container = _get_character_ui_container()
	for child in character_container.get_children():
		character_container.remove_child(child)
		child.queue_free()

	var upgrade_dice_container = _get_upgrade_dice_ui_container()
	for child in upgrade_dice_container.get_children():
		upgrade_dice_container.remove_child(child)
		child.queue_free()

	_set_available_gold(get_available_gold())

	var charactersEligibleForPurchase = get_eligible_characters()
	for character in charactersEligibleForPurchase:
		var sprite_res = load("res://game/assets/heroes/" + character.sprite_name)

		var vbox_container = VBoxContainer.new()
		var char_label = Label.new()
		char_label.text = character.name + " (" + str(character.cost) + " Gold)"
		var sprite_center_container = CenterContainer.new()
		var char_sprite = TextureRect.new()
		char_sprite.texture = sprite_res
		var ability_label = Label.new()
		ability_label.text = _get_ability_description_from_type(character.hero_ability)
		ability_label.autowrap = true
		ability_label.rect_min_size.x = 100

		sprite_center_container.add_child(char_sprite)
		vbox_container.add_child(char_label)
		vbox_container.add_child(sprite_center_container)
		vbox_container.add_child(ability_label)
		if character.is_purchased:
			vbox_container.add_child(_build_purchased_label())
			if character.is_in_play:
				#show button to bring out of play
				var char_bring_out_button = Button.new()
				char_bring_out_button.connect("pressed", self, "on_unsend_button_pressed", [character])
				char_bring_out_button.text = "Bring Back"
				vbox_container.add_child(char_bring_out_button)
			elif current_heroes.size() < 4:
				# show button to put in play
				var char_play_button = Button.new()
				char_play_button.connect("pressed", self, "_on_send_button_pressed", [character])
				char_play_button.text = "Send"
				vbox_container.add_child(char_play_button)
		elif current_heroes.size() >= 4:
			# can't hire new heroes
			var no_room_label = Label.new()
			no_room_label.text = "Party is Full!"
			vbox_container.add_child(no_room_label)
		else:
			var char_buy_button = Button.new()
			char_buy_button.connect("pressed", self, "_on_buy_button_pressed", [character])
			char_buy_button.text = "Hire"
			vbox_container.add_child(char_buy_button)

		character_container.add_child(vbox_container)

	var dice_eligible_to_upgrade = get_dice_to_upgrade()
	for dice_eligible_for_upgrade in dice_eligible_to_upgrade:
		var vbox_container = VBoxContainer.new()
		vbox_container.alignment = 1
		var dice_label = Label.new()
		dice_label.text = dice_eligible_for_upgrade.get_friendly_dice_name_from_type()
		dice_label.align = 1
		var sprite_center_container = CenterContainer.new()
		var dice_sprite = TextureRect.new()
		dice_sprite.texture = dice_eligible_for_upgrade.get_dice_texture_resource()
		dice_sprite.modulate = dice_eligible_for_upgrade.get_dice_modulation()
		var dice_description_label = Label.new()
		dice_description_label.text = str(dice_eligible_for_upgrade.minimum) + " to " + str(dice_eligible_for_upgrade.maximum)
		dice_description_label.align = 1

		sprite_center_container.add_child(dice_sprite)
		vbox_container.add_child(dice_label)
		vbox_container.add_child(sprite_center_container)
		vbox_container.add_child(dice_description_label)
		var dice_upgrade_button = Button.new()
		dice_upgrade_button.connect("pressed", self, "_on_upgrade_dice_button_pressed", [dice_eligible_for_upgrade])
		dice_upgrade_button.text = "Upgrade"
		vbox_container.add_child(dice_upgrade_button)

		upgrade_dice_container.add_child(vbox_container)

func on_unsend_button_pressed(character):
	global_audio.play_ui()
	emit_signal("retracted_hero", character)
	_on_about_to_show() # reload UI

func _on_send_button_pressed(character):
	global_audio.play_ui()
	emit_signal("sent_hero", character)
	_on_about_to_show() # reload UI

func _on_button_close_shop_pressed():
	global_audio.play_ui()
	hide()

func _on_buy_button_pressed(character):
	global_audio.play_ui()
	var current_heroes = get_tree().get_nodes_in_group("heroes")
	if (get_available_gold() >= character.cost && current_heroes.size() < 4):
		character.is_purchased = true
		emit_signal("purchased_hero", character)
		_on_about_to_show() # reload UI

func _on_upgrade_dice_button_pressed(dice):
	get_parent().show_dice_shop(dice)

func _on_buy_new_dice_pressed():
	global_audio.play_ui()
	var purchasable_dice = {"dice_type": "D2", "sprite": "dice_d2.png", "cost": 10}
	var all_heroes_dice = get_tree().get_nodes_in_group("heroes_dice")
	if (get_available_gold() >= purchasable_dice.cost && all_heroes_dice.size() < 4):
		emit_signal("purchased_dice", purchasable_dice)
		_set_available_gold(get_available_gold())
		_on_about_to_show()

func _on_buy_health_button_pressed():
	global_audio.play_ui()
	if (get_available_gold() >= 5):
		emit_signal("purchased_health", 5, 1)
		_set_available_gold(get_available_gold())

func _on_buy_health_5x_button_pressed():
	global_audio.play_ui()
	if (get_available_gold() >= 25):
		emit_signal("purchased_health", 25, 5)
		_set_available_gold(get_available_gold())


func _build_purchased_label():
	var purchased_label = Label.new()
	purchased_label.text = "Hired!"
	return purchased_label

func _on_dice_shop_upgraded_dice(_dice, _cost):
	_on_about_to_show()

func get_eligible_characters():
	return get_parent().available_characters

func get_dice_to_upgrade():
	return get_tree().get_nodes_in_group("heroes_dice")

func get_available_gold():
	return get_parent().available_gold

func _get_character_ui_container():
	return $MarginContainer/vscroll/vbox_menu/scroll_buy_character/hbox_char_container

func _get_upgrade_dice_ui_container():
	return $MarginContainer/vscroll/vbox_menu/scroll_dice_upgrade/hbox_upgrade_dice_container

func _get_purchase_dice_ui_container():
	return $MarginContainer/vscroll/vbox_menu/scroll_dice_buy/hbox_buy_dice_container

func _set_available_gold(amount):
	_get_gold_label_node().text = "Gold: " + str(amount)

func _get_gold_label_node():
	return $MarginContainer/vscroll/vbox_menu/HBoxContainer/gold_label

func _get_ability_description_from_type(ability_type):
	match(ability_type):
		"damage":
			return "Crits are extra strong"
		"bleed":
			return "Crits add a stacking bleed that does your Dice's Range every roll"
		"clear":
			return "Crits clear an Entangle"
		"heal":
			return "Heals you instead of dealing damage"
		"steal":
			return "Crits steal the value from the enemy in Gold"
		"grapple":
			return "Crits will grapple an enemy for two rolls"
		_:
			return "Mysterious!"
