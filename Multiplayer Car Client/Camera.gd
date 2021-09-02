extends Camera

export (float) var lerpSpeed = 3.0
export (NodePath) var targetPath = null
export (Vector3) var offset = Vector3.ZERO

var target

func _ready() -> void:
	if targetPath: 
		target = get_node(targetPath).get_node("CarMesh")

func _physics_process(delta: float) -> void:
	if !target:
		return
		
	var targetPos = target.global_transform.translated(offset)
	global_transform = global_transform.interpolate_with(targetPos, lerpSpeed*delta)
	
	look_at(target.global_transform.origin, Vector3.UP)
