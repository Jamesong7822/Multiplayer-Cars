extends Sprite3D

func _ready() -> void:
	texture = $Viewport.get_texture()

func _setLabelText(newLabelText: String) -> void:
	$Viewport/Label.text = newLabelText
