extends Node

var gamestate = "main_menu"
var loaded_environment = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _reset_gamestate():
	print("resetting")
	gamestate = "main_menu"
	pass
