extends Spatial

export (float) var spawnTimer = 3.0

var availablePowerups
var spawnAtPos

func _getPowerUpsInArea() -> Array:
	return $Area.get_overlapping_areas()
	
func _getAvailablePowerups() -> void:
	var files = []
	var dir = Directory.new()
	var folder = "res://Maps/PowerUps/"
	dir.open(folder)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".tscn"):
			if not "Base" in file and not "Spawner" in file:
				files.append(folder+file)
	
	dir.list_dir_end()
	availablePowerups = files
	
func _setup() -> void:
	_getAvailablePowerups()
	$SpawnTimer.wait_time = spawnTimer
	$SpawnTimer.one_shot = true

func _ready() -> void:
	_setup()
	yield(get_tree(), "idle_frame")
	# spawn the first powerup
	if $RayCast.is_colliding():
		spawnAtPos = $RayCast.get_collision_point() + Vector3(0, 1, 0)
	if get_tree().is_network_server():
		var powerUpScene = _getRandomPowerUpScene()
		rpc("_spawnPowerup", powerUpScene, spawnAtPos)
	
func _on_SpawnArea_area_exited(area: Area) -> void:
	pass # Replace with function body.
	print ("Powerup collected!")
	if get_tree().is_network_server():
		print ("Starting spawn power up timer")
		$SpawnTimer.start()

func _onPowerUpCollected() -> void:
	print ("Powerup collected!")
	if get_tree().is_network_server():
		print ("Starting spawn power up timer")
		$SpawnTimer.start()

func _on_SpawnTimer_timeout() -> void:
	pass # Replace with function body.
	var powerUpScene = _getRandomPowerUpScene()
	rpc("_spawnPowerup", powerUpScene, spawnAtPos)
	
func _getRandomPowerUpScene() -> String:
	if get_tree().get_network_unique_id() == 1:
		return availablePowerups[randi() % len(availablePowerups)]
	return ""
	
remotesync func _spawnPowerup(powerUpScene: String, spawnPos: Vector3) -> void:
	print ("spawn power up: %s"%powerUpScene)
	# get random powerup
	var a = load(powerUpScene).instance()
	add_child(a)
	a.connect("collected", self, "_onPowerUpCollected")
	a.global_transform.origin = spawnPos
