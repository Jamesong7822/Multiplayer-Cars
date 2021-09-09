extends Spatial

export (String) var powerUpName = "Base Power Up"
export (String) var powerUpDesc = "Base Power Up Description"
export (String) var powerUpFuncCall
export (Dictionary) var powerUpEffect

var used = false

signal collected

func _ready() -> void:
	randomize()
	$AnimationPlayer.play("init")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	call_deferred("_setup")
	
func _setup() -> void:
	# play spawn animation
	$AnimationPlayer.play("spawn")

func _removePowerUp() -> void:
	# TODO collection animation
	$Sprite3D.hide()
	$AnimationPlayer.play("collect")

func _on_Area_body_entered(body: Node) -> void:
	# TODO collection animation!
	if body.is_in_group("Car") and not used:
		print ("%s powerup!" %powerUpName)
		body.get_parent().powerUp = powerUpFuncCall
		body.get_parent().powerUpArgs = powerUpEffect
		_removePowerUp()
		if body.get_parent().name == str(get_tree().get_network_unique_id()):
			var HUD = get_tree().get_nodes_in_group("HUD")[0]
			HUD.get_node("PowerupHUD")._updatePowerupTexture($Sprite3D.texture)
		emit_signal("collected")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	pass # Replace with function body.
	if anim_name == "collect":
		call_deferred("queue_free")
