extends Spatial

export (float) var knockbackForce = 5000


func _disableCollider() -> void:
	$Area/CollisionShape.disabled = true

func _on_Area_body_entered(body: Node) -> void:
	pass # Replace with function body.
	var dir = body.global_transform.origin - global_transform.origin
	dir = dir.normalized()
	body.add_central_force(Vector3.UP * knockbackForce)
	$AnimationPlayer.play("explode")
	call_deferred("_disableCollider")
