extends RayCast3D

var object = null
var last = Vector3.ZERO
@onready var point = $"../hold_position"

func _process(delta):
	if (!is_multiplayer_authority()): return
	if Input.is_action_pressed("grab"):
		if object == null:
			var collider = get_collider()
			if collider != null:
				if collider.is_in_group("grabable"):
					object = collider
		
		if object != null:
			last = object.global_position
			object.position = point.global_position
			object.set_loc(point.global_position)
			
			if object.is_class("RigidBody3D"):
				object.linear_velocity = Vector3.ZERO
				object.set_vel(point.global_position)
	else:
		if object != null:
			if object.is_class("RigidBody3D"):
				print("rigid")
				var velocity = object.position - last
				object.linear_velocity = velocity * 2000 * delta
				object.set_vel(object.linear_velocity)
		object = null
		
