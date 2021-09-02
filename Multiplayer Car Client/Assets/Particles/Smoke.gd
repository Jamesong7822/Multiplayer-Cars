extends Particles

func _setEmit(emitState:bool):
	if emitState:
		emitting = true
	else:
		emitting = false
