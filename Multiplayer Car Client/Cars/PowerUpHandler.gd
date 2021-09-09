extends Node

onready var ball = get_parent().get_node("Ball")
onready var carMesh = get_parent().get_node("CarMesh")

func _ready() -> void:
	pass 

func _grow(powerUpEffect: Dictionary) -> void:
	var carMeshOldScale = carMesh.get_node("Car").scale
	var growBy = powerUpEffect["growBy"]
	var timeout = powerUpEffect["timeout"]
#	get_parent().scale = Vector3(growBy, growBy, growBy)
	print ("Grow By: ", growBy)
	carMesh.get_node("Car").scale = Vector3(growBy, growBy, growBy)
	carMesh.global_transform.orthonormalized()
	ball.global_transform.orthonormalized()
	yield(get_tree().create_timer(timeout), "timeout")
	print ("grow power up over!")
	carMesh.get_node("Car").scale = carMeshOldScale
	
func _spawnBalls(powerUpEffect: Dictionary) -> void:
	var map = get_tree().get_nodes_in_group("World")[0]
	var number = powerUpEffect["number"]
	var ballScene = load("res://Maps/PowerUps/Assets/Balls.tscn")
	for i in range(number):
		var a = ballScene.instance()
		map.add_child(a)
		a.global_transform.origin = carMesh.get_node("SpawnPos").global_transform.origin

func _spawnMine(powerUpEffect: Dictionary) -> void:
	var map = get_tree().get_nodes_in_group("World")[0]
	var a = load("res://Maps/PowerUps/Assets/Mine.tscn").instance()
	map.add_child(a)
	a.global_transform.origin = carMesh.get_node("SpawnPos").global_transform.origin

func _spawnRocket(powerUpEffect: Dictionary) -> void:
	var map = get_tree().get_nodes_in_group("World")[0]
	var a = load("res://Maps/PowerUps/Assets/Rocket.tscn").instance()
	map.add_child(a)
	a._updateTargetPos(carMesh.global_transform.origin + carMesh.global_transform.basis.z.normalized() * 50)
	a.global_transform.origin = carMesh.get_node("SpawnPos").global_transform.origin

func _boost(powerUpEffect: Dictionary) -> void:
	var boostDir = -carMesh.global_transform.basis.z.normalized()
	var boostAmount = powerUpEffect["boostAmount"]
	ball.add_central_force(boostDir * boostAmount)
