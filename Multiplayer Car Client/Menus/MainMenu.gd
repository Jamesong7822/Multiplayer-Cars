extends Control

func _on_HostGameButton_pressed() -> void:
	yield(Scenes._doDelay(), "completed")
	Gamestate.host_game(Gamestate.player_name, Gamestate.IP)
	# change scene
	hide()
	get_tree().get_root().add_child(Scenes.LOBBY.instance())


func _on_JoinGameButton_pressed() -> void:
	yield(Scenes._doDelay(), "completed")
	hide()
	get_tree().get_root().add_child(Scenes.JOIN_GAME.instance())
