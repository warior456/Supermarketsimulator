extends Node3D
@onready var environment = preload("res://src/levels/supermarket.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _load_environment():
	Global.loaded_environment = environment.instantiate()
	add_child(Global.loaded_environment)


func _unload_environment() -> void:
	if(Global.loaded_environment != null):
		Global.loaded_environment.queue_free()
