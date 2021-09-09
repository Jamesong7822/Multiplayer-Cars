extends Node

# server IP
const IP = "ws://103.6.169.201:9080"

# Default game port
const DEFAULT_PORT = 9080

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_name = "The Warrior"

# Names for remote players in id:name format
var players = {}

var RTT = 0

# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)
signal lobby_joined(lobby)

# Callback from SceneTree
func _player_connected(_id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if get_tree().is_network_server():
		if has_node("/root/world"): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	var playerDict = {}
	playerDict["name"] = player_name
	players[get_tree().get_network_unique_id()] = playerDict
	rpc("register_player", get_tree().get_network_unique_id(), playerDict)
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	print ("Server Disconnected!")
	emit_signal("game_error", "Server disconnected")
	end_game("Server Disconnected!")

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

func _on_Network_Server_Connected():
	var playerDict = {}
	playerDict["name"] = player_name
	players[get_tree().get_network_unique_id()] = playerDict
	emit_signal("player_list_changed")
	
remote func register_player(id, new_player_info: Dictionary):
	if get_tree().is_network_server():
		# server updates truth copy
		print (players)
		players[id] = new_player_info
		print (players)
		# server broadcasts info to everyone else!
		for p_id in get_tree().get_network_connected_peers():
			print (p_id)
			rpc_id(p_id, "_updateClientPlayersList", players)
		# If we are the server, let everyone know about the new player
#		rpc_id(id, "register_player", 1, new_player_info) # Send myself to new dude
#		for p_id in get_tree().get_network_connected_peers(): # Then, for each remote player
#			rpc_id(id, "register_player", p_id, players[p_id]) # Send player to new dude
#			rpc_id(p_id, "register_player", id, new_player_info) # Send new dude to player
	emit_signal("player_list_changed")
	
remote func _updateClientPlayersList(newPlayersList: Dictionary) -> void:
	if get_tree().get_rpc_sender_id() != 1:
		return
	players = newPlayersList
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points, catcher):
	# Change scene
	var world = load("World.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://Cars/BaseCar.tscn")

	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPos/" + str(spawn_points[p_id]))
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name
		player.translation=spawn_pos.translation
		player.rotation_degrees = spawn_pos.rotation_degrees
		player.set_network_master(p_id) #set unique id as master

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name
			player.set_player_name(player_name)
			# set camera to track this player
			world.get_node("Camera").target = player.get_node("CarMesh")
		else:
			# Otherwise set name from peer
			player.set_player_name(players[p_id]["name"])
			
		# set catcher status
		if  p_id == catcher:
			player.isCatcher = true
			player.set_player_name("Catcher: " + players[p_id]["name"])

		world.get_node("Players").add_child(player)

	# Set up score
#	world.get_node("score").add_player(get_tree().get_network_unique_id(), player_name)
#	for pn in players:
#		world.get_node("score").add_player(pn, players[pn])

	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name, ip):
	player_name = new_player_name
	Client.start(ip)

func join_game(ip, new_player_name, lobby):
	player_name = new_player_name
	Client.start(ip, lobby)

func _signaling_disconnected():
	if not Client.sealed: # Game has not started yet
		emit_signal("game_error", "Signaling server disconnected:\n%d: %s" % [Client.code, Client.reason])
		end_game("Signaling server disconnected")

func _signaling_inited(lobby):
	get_tree().set_network_peer(Client.rtc_mp)
	emit_signal("lobby_joined", lobby)
	emit_signal("player_list_changed")

func get_player_list():
	return players

func get_player_name():
	return player_name
	
func _chooseCatcher() -> int:
	if not get_tree().is_network_server():
		return -1
	if len(players) > 1:
		var playersList = players.keys()
		print (playersList)
		var catcher = playersList[randi() % len(playersList)]
		print ("Catcher: ", catcher)
		return catcher
	return -1
	
func begin_game():
	assert(get_tree().is_network_server())

	Client.seal_lobby()
	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points = {}
	var spawn_point_idx = 0
	var catcher = _chooseCatcher()
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
			
	# Call to pre-start game with the spawn points
	for p in get_tree().get_network_connected_peers():
		rpc_id(p, "pre_start_game", spawn_points, catcher)

	pre_start_game(spawn_points, catcher)


func end_game(reason : String = ""):
	if has_node("/root/World"): # Game is in progress
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking
	Client.stop()
	# clear lobby
	if has_node("/root/Lobby"):
		get_node("/root/Lobby").queue_free()
	# push client back to main menu
	Scenes._returnToMainMenu(reason)
	
func _getLatency():
	if get_tree().get_network_unique_id() == 1:
		return 0
	else:
		rpc_id(1, "_sendPing", OS.get_system_time_msecs())
		
remote func _sendPing(sendTime: int) -> void:
	var senderID = get_tree().get_rpc_sender_id()
	rpc_id(senderID, "_returnPing", sendTime)
	
remote func _returnPing(sendTime: int) -> void:
	if get_tree().get_rpc_sender_id() != 1:
		return
	RTT = (OS.get_system_time_msecs() - sendTime) / 2 # round trip time
		
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	Client.connect("lobby_joined", self, "_signaling_inited")
	Client.connect("disconnected", self, "_signaling_disconnected")
	Client.connect("network_server_connected", self, "_on_Network_Server_Connected")
