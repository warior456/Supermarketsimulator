extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func set_loc(pos):
	rpc_id(1, "set_location", pos)

func set_vel(pos):
	rpc_id(1, "set_velocity", pos)

@rpc("any_peer", "call_local")
func set_location(pos):
	position = pos
	

@rpc("any_peer", "call_local")
func set_velocity(vel):
	linear_velocity = vel
