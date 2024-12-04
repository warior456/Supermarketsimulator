extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/Pistol/MuzzleFlash
@onready var player_raycast = $Camera3D/playerRaycast

var health = 3
var sens = 0.50
var push_force = 50.0
const WALK_SPEED = 3
const RUN_SPEED = 7
const ACCELERATION = 50
const JUMP_VELOCITY = 4

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 10

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	

func _unhandled_input(event):
	if (!is_multiplayer_authority()): return
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * .005 * sens
		camera.rotate_x(-event.relative.y * .005 * sens)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_pressed("shoot") \
			and anim_player.current_animation != "shoot":
		play_shoot_effects.rpc()
		if player_raycast.is_colliding():
			var hit_player = player_raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

func _physics_process(delta):
	if not multiplayer: return
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Vector2.ZERO
	if (Global.gamestate == "game"):
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		input_dir = Input.get_vector("left", "right", "up", "down")
	
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction && is_on_floor():
		velocity.x = move_toward(velocity.x, RUN_SPEED * direction.x, (abs(direction.x) + abs(velocity.x + ACCELERATION)) * delta * ACCELERATION)
		velocity.z = move_toward(velocity.z, RUN_SPEED * direction.z, (abs(direction.z) + abs(velocity.z + ACCELERATION)) * delta * ACCELERATION)
	elif (direction):
		velocity.x = move_toward(velocity.x, RUN_SPEED * direction.x, (abs(direction.x) + abs(velocity.x + 1)) * delta * ACCELERATION/5)
		velocity.z = move_toward(velocity.z, RUN_SPEED * direction.z, (abs(direction.z) + abs(velocity.z + 1)) * delta * ACCELERATION/5)
	elif (is_on_floor()):
		velocity.x = move_toward(velocity.x, 0, delta * abs(velocity.x) * ACCELERATION/3)
		velocity.z = move_toward(velocity.z, 0, delta * abs(velocity.z) * ACCELERATION/3)
	else :
		velocity.x = move_toward(velocity.x, 0, abs(velocity.x * velocity.x) * delta * 0.1)
		velocity.z = move_toward(velocity.z, 0, abs(velocity.z * velocity.z) * delta * 0.1)

	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")
	move_and_slide()
	#for i in get_slide_collision_count():
		#var c = get_slide_collision(i)
		#if c.get_collider() is RigidBody3D:
			#c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
		


@rpc("call_local")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
