extends Control

onready var lobbyID = $"MarginContainer/VBoxContainer/HBoxContainer/LineEdit"

func _doDelay(delayTime: float = 0.2) -> void:
	# function to delay the changing of scenes
	yield(get_tree().create_timer(delayTime), "timeout")

func _on_JoinGameButton_pressed() -> void:
	if len(lobbyID.text) == 0:
		#TODO DEBUG PRINT / POPUP
		$Popup._setPopupText("Key in a lobby ID! (Hint: Get from friends!)")
		return
	yield(_doDelay(), "completed")
	Gamestate.join_game(Gamestate.IP, Gamestate.player_name, lobbyID.text)
	# change scene
	queue_free()
	get_tree().get_root().add_child(Scenes.LOBBY.instance())

func _on_BackButton_pressed() -> void:
	pass # Replace with function body.
	yield(_doDelay(), "completed")
	queue_free()
	Scenes._returnToMainMenu()
