extends Node

@onready var overlays = $Overlays
@onready var level = $Level

const Player = preload("res://src/player/player.tscn")
const PORT = 9999
var port = 9999
var enet_peer = ENetMultiplayerPeer.new()
var game_code
var thread = null
signal upnp_ready

func _ready() -> void:
	load("res://src/Global.gd")


func _unhandled_input(event):
	if Input.is_action_just_pressed("escape"):
		if(Global.gamestate == "game"):
			overlays._open_pause_menu()
		elif (Global.gamestate == "pause_menu"):
			overlays._close_pause_menu()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_host_button_pressed():
	overlays.main_menu.hide()
	overlays.hud.show()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.server_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	overlays.client_type_label.text = "Server"
	overlays._set_ip_label("127.0.0.1", port)
	level._load_environment()
	Global.gamestate = "game"
	thread = Thread.new()
	thread.start(upnp_setup)

func _on_join_button_pressed():
	overlays.main_menu.hide()
	overlays.hud.show()
	var address = overlays.address_entry.text
	if(overlays.address_entry.text == ""): 
		address = "127.0.0.1"
	if(overlays.port_entry.text != ""):
		port = overlays.port_entry.text
	else: 
		port = PORT
	multiplayer.connection_failed.connect(overlays._open_main_menu)
	enet_peer.create_client(address, int(port))
	overlays._set_ip_label(address, port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.server_disconnected.connect(_on_leave_game)
	level._load_environment()
	Global.gamestate = "game"
	overlays.client_type_label.text = "Client"


func _disconnect():
	if not multiplayer.is_server():
		remove_player(multiplayer.get_unique_id())
		multiplayer.multiplayer_peer.disconnect_peer(1)
	else:
		for i in multiplayer.get_peers():
			remove_player(i)
		remove_player(multiplayer.get_unique_id())
		multiplayer.multiplayer_peer.close()


func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	overlays.health_bar.value = health_value

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)

func nat_holepunch():
	var hole_puncher = preload('res://addons/Holepunch/holepunch_node.gd').new()
	# your rendezvous server IP or domain
	hole_puncher.rendevouz_address = "1.1.1.1"
	# the port the HolePuncher python application is running on
	hole_puncher.rendevouz_port = "3000"
	add_child(hole_puncher)
	# Generate a unique ID for this machine
	var player_id = OS.get_unique_id()
	hole_puncher.start_traversal(game_code, multiplayer.is_server(), player_id)
	# Yield an array of [own_port, host_port, host_ip]
	var result = await [hole_puncher, 'hole_punched']
	print(result)
	return result

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	overlays._set_ip_label(upnp.query_external_address(), port)

func _reset_gamestate():
	if(multiplayer.peer_connected.is_connected(add_player)): multiplayer.peer_connected.disconnect(add_player)
	if(multiplayer.peer_disconnected.is_connected(remove_player)): multiplayer.peer_disconnected.disconnect(remove_player)
	if(multiplayer.server_disconnected.is_connected(remove_player)): multiplayer.server_disconnected.disconnect(remove_player)
	if(multiplayer.server_disconnected.is_connected(_on_leave_game)): multiplayer.server_disconnected.disconnect(_on_leave_game)


func _on_leave_game() -> void:
	level._unload_environment()
	overlays.pause_menu.hide()
	overlays.full_overlay.hide()
	_disconnect()
	_reset_gamestate()
	Global._reset_gamestate()
	overlays._open_main_menu()
	
