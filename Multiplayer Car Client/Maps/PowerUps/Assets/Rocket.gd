extends KinematicBody

export (float) var acceleration
var targetDir 
var timer
var target
var targetPos

func _updateTarget(newTarget: Node) -> void:
	target = newTarget
	
func _updateTargetPos(newTargetPos: Vector3) -> void:
	targetPos = newTargetPos
	
func _flyToTargetPos(delta: float):
	if targetPos:
		var dir = -(targetPos - global_transform.origin).normalized()
		look_at(targetPos, Vector3.UP)
		return move_and_collide(dir*acceleration*delta)
		
func _explode() -> void:
	targetPos = null
	$AnimationPlayer.play("explode")
	$Body.hide()
	
func _physics_process(delta: float) -> void:
	var collision = _flyToTargetPos(delta)
	if collision:
		_explode()
	
func _on_Area_body_entered(body: Node) -> void:
	pass # Replace with function body.
	var knockbackDir = (body.global_transform.origin - global_transform.origin).normalized()
	if body.is_in_group("Car"):
		body.add_central_force(knockbackDir * 5000)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	pass # Replace with function body.
	if anim_name == "explode":
		queue_free()


func _on_Timer_timeout() -> void:
	pass # Replace with function body.
	queue_free()
