extends Node

const LOBBY = preload("res://Menus/Lobby.tscn")
const JOIN_GAME = preload("res://Menus/JoinGame.tscn")

func _doDelay(delayTime: float = 0.2) -> void:
	# function to delay the changing of scenes
	yield(get_tree().create_timer(delayTime), "timeout")
	
func _returnToMainMenu(popUpText: String = "") -> void:
	# most common scene
	if get_tree().get_root().has_node("/root/MainMenu"):
		$"/root/MainMenu".show()
	# check for pop up messages
	if popUpText != "":
		$"/root/MainMenu".get_node("Popup")._setPopupText(popUpText)
