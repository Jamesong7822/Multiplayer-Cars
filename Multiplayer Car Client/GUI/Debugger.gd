extends Control

export (float) var updateRate = 0.1

var FPS = 0
var drawCalls = 0

var updateTimer 

func _ready() -> void:
	updateTimer = Timer.new()
	add_child(updateTimer)
	updateTimer.wait_time = updateRate
	updateTimer.connect("timeout", self, "_on_UpdateTimer_Timeout")
	updateTimer.start()
	getDebugInfo()
	writeDebugInfo()
	
func _on_UpdateTimer_Timeout() -> void:
	getDebugInfo()
	writeDebugInfo()

func writeDebugInfo() -> void:
	pass
	var info = ""
	info += "FPS: %s \n" %FPS
	info += "Draw Calls: %s \n" %drawCalls
	info += "Ping: %s" %Gamestate.RTT
	
	$Label.text = info

func getDebugInfo() -> void:
	# gets debug info
	FPS = Performance.get_monitor(Performance.TIME_FPS)
	drawCalls = Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME)
	Gamestate._getLatency()
