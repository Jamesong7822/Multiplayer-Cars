extends Spatial

onready var ball = $Ball
onready var carMesh = $CarMesh
onready var groundRaycast = $CarMesh/RayCast
onready var carBodyMesh = $CarMesh/Car/tmpParent.get_child(0).get_node("body")
onready var rightWheel = $CarMesh/Car/tmpParent.get_child(0).get_node("wheel_frontRight")
onready var leftWheel = $CarMesh/Car/tmpParent.get_child(0).get_node("wheel_frontLeft")


export (float) var acceleration = 50.0
export (float) var steering = 20.0
export (float) var turnSpeed = 5.0
export (float) var turnStopLimit = 0.75
export (float) var bodyTilt = 35 # smaller the number the more extreme the tilt

var sphereOffset : Vector3 = Vector3(0,-1.0,0)
var speedInput = 0.0
var rotateInput = 0.0
var respawnInput = false
var carMeshOriginalTransform

var isHost = false

func _ready() -> void:
	pass
	carMeshOriginalTransform = carMesh.global_transform
	if get_tree().get_network_unique_id() == 1:
		isHost = true
	if not isHost:
		# disable the physics for clients
		$Ball.mode = RigidBody.MODE_KINEMATIC
		

func _physics_process(delta: float) -> void:
	ball.add_central_force(-carMesh.global_transform.basis.z * speedInput)
	# update car mesh position
	carMesh.global_transform.origin = ball.global_transform.origin + sphereOffset
	if isHost:
		# respawn if necessary
		if ball.global_transform.origin.y < - 50:
			_respawn()
		for playerID in get_tree().get_network_connected_peers():
			rpc_id(playerID, "sendTransformToClients", ball.global_transform, carMesh.global_transform)
	
	
func _process(delta: float) -> void:
	
	
	# check if network master
	if is_network_master():
		# cannot steer / drive when in air
		if not groundRaycast.is_colliding():
			return
		# get acceleration / brake input
		speedInput = 0
		speedInput += Input.get_action_strength("accelerate")
		speedInput -= Input.get_action_strength("brake")
		speedInput *= acceleration
		# get steering input
		rotateInput = 0
		rotateInput += Input.get_action_strength("steer_left")
		rotateInput -= Input.get_action_strength("steer_right")
		rotateInput *= deg2rad(steering)
		# check for respawn input
		respawnInput = false
		if Input.is_action_just_pressed("respawn"):
			respawnInput = true
		# inform host
		if not isHost:
			rpc_id(1, "sendInputToHost", speedInput, rotateInput, respawnInput)
	# check respawnInput
	if respawnInput:
		_respawn()
	
	# add smoke effect
	if rotateInput != 0:
		$CarMesh/Particles._setEmit(true)
		$CarMesh/Particles2._setEmit(true)
	else:
		$CarMesh/Particles._setEmit(false)
		$CarMesh/Particles2._setEmit(false)
	# rotate wheels for effect
	rightWheel.rotation.y = rotateInput
	leftWheel.rotation.y = rotateInput
	if isHost:
		# rotate car mesh
		if ball.linear_velocity.length() > turnStopLimit:
			var newBasis = carMesh.global_transform.basis.rotated(carMesh.global_transform.basis.y, rotateInput)
			carMesh.global_transform.basis = carMesh.global_transform.basis.slerp(newBasis, turnSpeed*delta)
			carMesh.global_transform = carMesh.global_transform.orthonormalized()
			# body tilt
			var t = -rotateInput * ball.linear_velocity.length() / bodyTilt
			carBodyMesh.rotation.z = lerp(carBodyMesh.rotation.z, t, 10 * delta)
		# align to slope
		var n = groundRaycast.get_collision_normal()
		var xform = alignWithY(carMesh.global_transform, n.normalized())
		carMesh.global_transform = carMesh.global_transform.interpolate_with(xform, 10*delta)
	
func alignWithY(xform:Transform, newY:Vector3):
	xform.basis.y = newY
	xform.basis.x = -xform.basis.z.cross(newY)
	xform.basis = xform.basis.orthonormalized()
	return xform
	
func set_player_name(playerName: String) -> void:
	pass
	
func _respawn() -> void:
	ball.global_transform.origin = global_transform.origin
	carMesh.global_transform = carMeshOriginalTransform
		
remote func sendInputToHost(clientSpeedInput: float, clientRotateInput: float, clientRespawnInput: bool) -> void:
	pass
	# update the corresponding variables on host side
	speedInput = clientSpeedInput
	rotateInput = clientRotateInput
	respawnInput = clientRespawnInput

remote func sendTransformToClients(ballGlobalTransform: Transform, carMeshGlobalTransform: Transform) -> void:
	if get_tree().get_rpc_sender_id() != 1:
		return
	# update the corresponding transform on client side
	ball.global_transform = ballGlobalTransform
	carMesh.global_transform = carMesh.global_transform.interpolate_with(carMeshGlobalTransform, 0.1)


