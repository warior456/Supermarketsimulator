extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func set_loc(pos):
	rpc_id(1, "_set_location", pos)

func set_lin_vel(pos):
	rpc_id(1, "_set_lin_velocity", pos)

func set_rot(rot):
	rpc_id(1, "_set_rotation", rot)

@rpc("any_peer", "call_local")
func _set_location(pos):
	position = pos
	

@rpc("any_peer", "call_local")
func _set_lin_velocity(vel):
	linear_velocity = vel
	
@rpc("any_peer", "call_local")
func _set_rotation(rot):
	rotation.y = rot.y
