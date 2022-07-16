extends TileMap

signal new_zone_entered(enemies_to_figh)
var heroes_won_last_match = false

func _ready():
	self.connect("new_zone_entered", get_parent(), "_on_board_new_zone_entered")

func _on_battle_finished(did_heroes_win):
	print("battle finished")
	if did_heroes_win:
		heroes_won_last_match = true
		$hero_battle_tweener.interpolate_property($hero_on_the_board, "position", $hero_on_the_board.position, _get_next_board_position_after_heroes_win(), 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		$hero_battle_tweener.start()
	else:
		heroes_won_last_match = false
		$hero_battle_tweener.interpolate_property($hero_on_the_board, "position", $hero_on_the_board.position, Vector2(16,16), 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		$hero_battle_tweener.start()

func _on_heroes_health_changed(health):
	$hero_on_the_board/hero_board_life.text = str(health)

func _get_next_board_position_after_heroes_win():
	return $hero_on_the_board.position + Vector2(48, 0)

func _on_hero_battle_tweener_tween_all_completed():
	if heroes_won_last_match:
		var enemies = []
		enemies.append({})
		emit_signal("new_zone_entered", enemies)