extends Sprite3D

const RED_BAR = preload("res://Cars/Assets/red_bar.png")
const YELLOW_BAR = preload("res://Cars/Assets/yellow_bar.png")
const GREEN_BAR = preload("res://Cars/Assets/green_bar.png")

func _ready() -> void:
	texture = $Viewport.get_texture()
	
func _getBarPercent() -> float:
	return $Viewport/TextureProgress.value / $Viewport/TextureProgress.max_value
	
func _setProgressBarMaxValue(newMaxValue: float) -> void:
	$Viewport/TextureProgress.max_value = newMaxValue
	
func _setProgressBarValue(newValue: float) -> void:
	$Viewport/TextureProgress.value = newValue

func _process(delta: float) -> void:
	_updateBar()

func _updateBar() -> void:
	if _getBarPercent() < 0.2:
		$Viewport/TextureProgress.texture_progress = RED_BAR
	elif _getBarPercent() < 0.6:
		$Viewport/TextureProgress.texture_progress = YELLOW_BAR
	else:
		$Viewport/TextureProgress.texture_progress = GREEN_BAR
		
