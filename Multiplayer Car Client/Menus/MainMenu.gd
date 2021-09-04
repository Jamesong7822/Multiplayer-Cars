extends Control



func _on_Button_pressed() -> void:
	pass # Replace with function body.
	Client.start(IP)


func _on_Host_Game_pressed() -> void:
	pass # Replace with function body.
	Gamestate.host_game(Gamestate.player_name, Gamestate.IP)
	# change scene
	get_tree().change_scene("res://Menus/Lobby.tscn")

func _on_Join_Game_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene("res://Menus/JoinGame.tscn")
