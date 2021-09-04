extends Control

onready var lobbyID = $"MarginContainer/VBoxContainer/HBoxContainer/LineEdit"

func _on_JoinButton_pressed() -> void:
	if len(lobbyID.text) == 0:
		#TODO DEBUG PRINT / POPUP
		return
	pass # Replace with function body.
	Gamestate.join_game(Gamestate.IP, Gamestate.player_name, lobbyID.text)
	# change scene
	get_tree().change_scene("res://Menus/Lobby.tscn")
