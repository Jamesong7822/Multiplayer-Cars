extends Control

func _ready() -> void:
	_clearPowerupTexture()

func _updatePowerupTexture(newTexture: Texture) -> void:
	$TextureRect.texture = newTexture
	
func _clearPowerupTexture() -> void:
	$TextureRect.texture = null
