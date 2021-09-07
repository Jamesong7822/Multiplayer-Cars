extends Spatial

export (String) var powerUpName = "Base Power Up"
export (String) var powerUpDesc = "Base Power Up Description"
export (String) var powerUpFuncCall
export (Dictionary) var powerUpEffect

var used = false

func _deactivatePowerUp():
	$Sprite3D.hide()
	$Timer.start()
	used = true
	
func _activatePowerUp():
	$Sprite3D.show()
	used = false

func _on_Area_body_entered(body: Node) -> void:
	# TODO collection animation!
	if body.is_in_group("Car") and not used:
		print ("%s powerup!" %powerUpName)
		if body.get_parent().get_node("PowerUpHandler").has_method(powerUpFuncCall):
			body.get_parent().get_node("PowerUpHandler").call(powerUpFuncCall, powerUpEffect)
		# deactivate powerup
		_deactivatePowerUp()

func _on_Timer_timeout() -> void:
	pass # Replace with function body.
	_activatePowerUp()
