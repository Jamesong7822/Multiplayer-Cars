extends Control

const DEFAULT_ICON = preload("res://icon.png")
onready var lobbyID = $MarginContainer/VBoxContainer/HBoxContainer/LineEdit
onready var playersList = $MarginContainer/VBoxContainer/PlayersList

func _setLobbyID(newLobbyID: String) -> void:
	lobbyID.text = newLobbyID
	
func _doDelay(delayTime: float = 0.2) -> void:
	# function to delay the changing of scenes
	yield(get_tree().create_timer(delayTime), "timeout")
	
func _ready() -> void:
	Gamestate.connect("lobby_joined", self, "_setLobbyID")
	Gamestate.connect("player_list_changed", self, "_refreshLobby")
	# clear players list
	playersList.clear()
	
func _refreshLobby() -> void:
	pass
	# get the network connected players
	var players = Gamestate.get_player_list()
	playersList.clear()
	# add other players
	for playerKey in players.keys():
		var playerDict = players[playerKey]
		if playerKey == get_tree().get_network_unique_id():
			playersList.add_item(playerDict["name"] + " (YOU) ", DEFAULT_ICON)
		else:
			playersList.add_item(playerDict["name"], DEFAULT_ICON)
	# disable button
	if get_tree().get_network_unique_id() != 1:
		$MarginContainer/StartButton.disabled = true

func _on_StartButton_pressed() -> void:
	Gamestate.begin_game()


func _on_BackButton_pressed() -> void:
	yield(_doDelay(), "completed")
	Client.stop()
	queue_free()
	Scenes._returnToMainMenu()
