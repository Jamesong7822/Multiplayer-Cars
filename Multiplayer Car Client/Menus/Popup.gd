extends Popup

func _ready() -> void:
	_clearPopupText()

func _setPopupText(newPopupText: String) -> void:
	_clearPopupText()
	$Label.text = newPopupText
	# auto call the popup
	popup()
	
func _clearPopupText() -> void:
	$Label.text = ""
