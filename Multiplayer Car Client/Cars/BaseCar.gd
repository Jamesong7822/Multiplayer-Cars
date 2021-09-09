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

export (int) var maxCarHealth = 100
export (int) var carDamage = 15

var sphereOffset : Vector3 = Vector3(0,-1.0,0)
var speedInput = 0.0
var rotateInput = 0.0
var respawnInput = false
var jumpInput = false
var carMeshOriginalTransform

var powerUp = null # stores the picked up power up function name
var powerUpArgs = null # stores the picked up power up args

var currentHealth = maxCarHealth
var isCatcher = false
var playerName

func _ready() -> void:
	pass
	_setup()
		
func _setup() -> void:
	carMeshOriginalTransform = carMesh.global_transform
	if name != str(get_tree().get_network_unique_id()):
		# disable the physics for car that is not urs
		$Ball.mode = RigidBody.MODE_KINEMATIC
		
	# start the health bar
	$CarMesh/HealthBar._setProgressBarMaxValue(maxCarHealth)
	$CarMesh/HealthBar._setProgressBarValue(currentHealth)

func _physics_process(delta: float) -> void:
	ball.add_central_force(-carMesh.global_transform.basis.z * speedInput)
	# update car mesh position
	var newCarMeshPos = ball.global_transform.origin +sphereOffset
	newCarMeshPos.y = lerp(carMesh.global_transform.origin.y, newCarMeshPos.y, 0.5)
	carMesh.global_transform.origin = newCarMeshPos
	# respawn if necessary
	if ball.global_transform.origin.y < - 50:
		_respawn()

func _process(delta: float) -> void:
	_renderSmokeParticles()
	$CarMesh/HealthBar._setProgressBarValue(currentHealth)
	# check if network master
	if is_network_master():
		# check for respawn input
		respawnInput = false
		if Input.is_action_just_pressed("respawn"):
			respawnInput = true
		if respawnInput:
			_respawn()
		# check for left click input
		if Input.is_action_just_pressed("left_click"):
			if powerUp:
				rpc("_usePowerUp")
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
		# change rotateinput to -ve for reversing
		if speedInput < 0:
			rotateInput = -rotateInput
		
		
		# check for jump input
		jumpInput = false
		if Input.is_action_just_pressed("space"):
			jumpInput = true
			
		

	
	if jumpInput:
		_jump()
	
	# rotate wheels for effect
	rightWheel.rotation.y = rotateInput
	leftWheel.rotation.y = rotateInput
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
	
func set_player_name(newPlayerName: String) -> void:
	pass
	$"CarMesh/3DLabel"._setLabelText(newPlayerName)
	playerName = newPlayerName
	
func _renderSmokeParticles() -> void:
	# add smoke effect
	var emit = false
	if rotateInput != 0 and speedInput != 0 and groundRaycast.is_colliding():
		emit = true
	$CarMesh/Particles._setEmit(emit)
	$CarMesh/Particles2._setEmit(emit)
	
func _respawn() -> void:
	ball.linear_velocity = Vector3.ZERO
	ball.global_transform.origin = global_transform.origin
	carMesh.global_transform = carMeshOriginalTransform
	
func _jump() -> void:
	ball.add_central_force(Vector3.UP * 2000)
	ball.linear_velocity = ball.linear_velocity * 0.5
	$Ball/JumpAudio.play()
	
func _boost(boostDir: Vector3, boostAmount: float) -> void:
	ball.add_central_force(boostDir * boostAmount)
	
remotesync func _usePowerUp():
	# use power up
	$PowerUpHandler.call(powerUp,powerUpArgs)
	# remove the power up from variable
	powerUp = null
	powerUpArgs = null
	# remove from the HUD
	var HUD = get_tree().get_nodes_in_group("HUD")[0]
	HUD.get_node("PowerupHUD")._clearPowerupTexture()
	
remote func sendTransformToClients(ballGlobalTransform: Transform, carMeshGlobalTransform: Transform) -> void:
	# update the corresponding transform on client side
	ball.global_transform = ball.global_transform.interpolate_with(ballGlobalTransform, 0.5)
	carMesh.global_transform = carMesh.global_transform.interpolate_with(carMeshGlobalTransform, 0.5)

func _on_NetworkTimer_timeout() -> void:
	# broadcast your own transform to other connected peers
	if is_network_master():
		for playerID in get_tree().get_network_connected_peers():
			rpc_id(playerID, "sendTransformToClients", ball.global_transform, carMesh.global_transform)

remotesync func _gotCaught(damage: int) -> void:
	currentHealth -= damage

func _on_Ball_body_entered(body: Node) -> void:
	pass # Replace with function body.
	if body.is_in_group("Car"):
		if body.get_parent().isCatcher:
			rpc("_gotCaught", body.get_parent().carDamage)
