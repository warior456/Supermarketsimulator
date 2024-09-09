extends RayCast3D

var object = null
var outline_object = null
var last = Vector3.ZERO
@onready var point = $"../hold_position"

func _process(delta):
	if (!is_multiplayer_authority()): return
	
	var outline_old = null
	##grabable outline
	var outline_collider = get_collider()
	if outline_collider != null:
		if outline_collider.is_in_group("has_outline"):
			if(outline_object != null): outline_object.outline.hide()
			outline_object = outline_collider
			outline_object.outline.show()
	elif(outline_object != null):
		outline_object.outline.hide()
		outline_object = null
	
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
				object.set_lin_vel(point.global_position)
				object.rotation.y = point.global_rotation.y
				object.set_rot(point.global_rotation)
	else:
		if object != null:
			if object.is_class("RigidBody3D"):
				print("rigid")
				var velocity = object.position - last
				object.linear_velocity = velocity * 2000 * delta
				object.set_lin_vel(object.linear_velocity)
		object = null
