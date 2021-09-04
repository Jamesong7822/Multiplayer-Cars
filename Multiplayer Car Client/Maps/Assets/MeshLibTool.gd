tool
extends Spatial

export (bool) var run = false setget makeCollision

func _ready() -> void:
	pass

func makeCollision(state) -> void:
	if state:
		for child in get_node(".").get_children():
			var mesh: MeshInstance = child
			for meshChild in mesh.get_children():
				meshChild.name = "del"
				meshChild.queue_free()
			
			mesh.create_trimesh_collision()
