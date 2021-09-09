extends RigidBody

func _ready() -> void:
	yield(get_tree().create_timer(15.0), "timeout")
	queue_free()
