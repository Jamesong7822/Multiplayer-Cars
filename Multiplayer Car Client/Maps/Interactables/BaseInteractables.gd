extends Area

func _doInteraction(body: Node):
	# override this in the superclass
	pass

func _on_BaseInteractables_body_entered(body: Node) -> void:
	pass # Replace with function body.
	_doInteraction(body)

