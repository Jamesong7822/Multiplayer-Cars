extends Spatial

const POWERUP_SPAWNER = preload("res://Maps/PowerUps/PowerupSpawner.tscn")

export (int) var numberPowerUpSpawners = 30

var map
var trackPieces = []

signal round_over

func _ready() -> void:
	pass
	_calcPowerUpSpawners()
	
func _physics_process(delta: float) -> void:
	_checkForFinishCondition()
	
func _calcPowerUpSpawners() -> void:
	var currentOffset = 0
	for i in range(numberPowerUpSpawners):
		var a = POWERUP_SPAWNER.instance()
		a.name = str(i)
		$PowerUpSpawners.add_child(a)
		$Path/PathFollow.unit_offset = currentOffset
		var pos = $Path/PathFollow.global_transform.origin
		a.global_transform.origin = pos
		currentOffset += 1.0/numberPowerUpSpawners

func _checkForFinishCondition() -> void:
	if get_tree().is_network_server():
		for car in get_tree().get_nodes_in_group("Car"):
			if car.get_parent().currentHealth < 0:
				# get new catcher
				var newCatcher = Gamestate._chooseCatcher()
				rpc("end_round", newCatcher)

remotesync func end_round(newCatcher) -> void:
	for car in get_tree().get_nodes_in_group("Car"):
		# TODO a reset function!
		car.get_parent()._respawn()
		car.get_parent().currentHealth = car.get_parent().maxCarHealth
		car.get_parent().powerUp = null
		car.get_parent().powerUpArgs = null
		# remove from the HUD
		var playerID = get_tree().get_network_unique_id()
		var playerName = Gamestate.players[playerID]["name"]
		var HUD = get_tree().get_nodes_in_group("HUD")[0]
		HUD.get_node("PowerupHUD")._clearPowerupTexture()
		car.get_parent().isCatcher = false
		car.get_parent().set_player_name(playerName)
		if  car.get_parent().name == str(newCatcher):
			car.get_parent().isCatcher = true
			car.get_parent().set_player_name("Catcher: " + playerName)
