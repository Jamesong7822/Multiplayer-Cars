extends Control

onready var lobbyID = $MarginContainer/VBoxContainer/HBoxContainer/LineEdit
onready var playersList = $MarginContainer/VBoxContainer/PlayersList

func _setLobbyID(newLobbyID: String) -> void:
	lobbyID.text = newLobbyID
	
func _ready() -> void:
	Gamestate.connect("lobby_joined", self, "_setLobbyID")
	Gamestate.connect("player_list_changed", self, "_refreshLobby")
	
func _refreshLobby() -> void:
	pass
	# get the network connected players
	var players = Gamestate.get_player_list()
	players.sort()
	playersList.clear()
	# add yourself
	playersList.add_item(Gamestate.get_player_name() + " (YOU) ")
	# add other players
	for player in players:
		playersList.add_item(player)
	# disable button
	if get_tree().get_network_unique_id() != 1:
		$MarginContainer/StartButton.disabled = true


func _on_StartButton_pressed() -> void:
	pass # Replace with function body.
	Gamestate.begin_game()
