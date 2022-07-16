extends PopupDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal purchased_hero(characterObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("about_to_show", self, "_on_about_to_show")

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
		var char_buy_button = Button.new()
		char_buy_button.connect("pressed", self, "_on_buy_button_pressed", [character])
		char_buy_button.text = str(character.cost) + " Gold"
		var sprite_center_container = CenterContainer.new()
		var char_sprite = TextureRect.new()
		char_sprite.texture = sprite_res

		sprite_center_container.add_child(char_sprite)
		vbox_container.add_child(char_label)
		vbox_container.add_child(sprite_center_container)
		vbox_container.add_child(char_buy_button)

		container.add_child(vbox_container)

func _on_button_close_shop_pressed():
	hide()

func _on_buy_button_pressed(character):
	if (get_available_gold() > character.cost):
		_set_available_gold(get_available_gold() - character.cost)
		emit_signal("purchased_hero", character)

func get_eligible_characters():
	var characters_to_buy = []
	characters_to_buy.append({"name": "Jane Doe", "sprite_name": "hero_oldlady.png", "cost": 20, "is_purchased": false})
	characters_to_buy.append({"name": "Jane Doe", "sprite_name": "hero_oldlady.png", "cost": 25, "is_purchased": false})
	return characters_to_buy

func get_available_gold():
	return get_parent().available_gold

func _get_character_ui_container():
	return $MarginContainer/vbox_menu/hbox_char_container

func _set_available_gold(amount):
	_get_gold_label_node().text = "Gold: " + str(amount)

func _get_gold_label_node():
	return $MarginContainer/vbox_menu/HBoxContainer/gold_label
