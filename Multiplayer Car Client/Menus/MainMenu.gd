extends Control

func _doDelay(delayTime: float = 0.3) -> void:
	# function to delay the changing of scenes
	return yield(get_tree().create_timer(delayTime), "timeout")

func _on_HostGameButton_pressed() -> void:
	yield(_doDelay(), "completed")
	Gamestate.host_game(Gamestate.player_name, Gamestate.IP)
	# change scene
	get_tree().change_scene("res://Menus/Lobby.tscn")


func _on_JoinGameButton_pressed() -> void:
	_doDelay()
	get_tree().change_scene("res://Menus/JoinGame.tscn")
