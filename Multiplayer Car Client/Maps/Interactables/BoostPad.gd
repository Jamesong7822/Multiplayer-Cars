tool
extends "res://Maps/Interactables/BaseInteractables.gd"

export (float) var boostForce = 1000

func _doInteraction(body: Node):
	if body.is_in_group("Car"):
		# boost the car forward
		var boostDir = global_transform.basis.z
		body.get_parent()._boost(boostDir, boostForce)
