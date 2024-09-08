extends Node

@onready var main_menu = $Overlays/MainMenu
@onready var address_entry = $Overlays/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/AddressEntry
@onready var port_entry = $Overlays/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/PortEntry
@onready var hud = $Overlays/HUD
@onready var health_bar = $Overlays/HUD/HealthBar
@onready var client_type_label = $Overlays/HUD/Clienttypelabel
@onready var environment = preload("res://src/levels/supermarket.tscn")


const Player = preload("res://src/player/player.tscn")
const PORT = 9999
var port = 9999
var enet_peer = ENetMultiplayerPeer.new()
var game_code
var thread = null
signal upnp_ready

func _unhandled_input(event):
	if Input.is_action_just_pressed("escape"):
		if not multiplayer.is_server():
			remove_player(multiplayer.get_unique_id())
			multiplayer.multiplayer_peer.disconnect_peer(1)
		else:
			for i in multiplayer.get_peers():
				remove_player(i)
			remove_player(multiplayer.get_unique_id())
			multiplayer.multiplayer_peer.close()
		_to_main_menu()

func _on_host_button_pressed():
	_load_environment()
	main_menu.hide()
	hud.show()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.server_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	client_type_label.text = "Server"
	thread = Thread.new()
	thread.start(upnp_setup)



func _on_join_button_pressed():
	_load_environment()
	main_menu.hide()
	hud.show()
	var address = address_entry.text
	if(address_entry.text == ""): 
		address = "127.0.0.1"
	print(address)
	
	if(port_entry.text != ""):
		port = port_entry.text
		print(port)
	else: 
		port = PORT
	multiplayer.connection_failed.connect(_to_main_menu)
	enet_peer.create_client(address, int(port))
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.server_disconnected.connect(_to_main_menu)
	client_type_label.text = "Client"

func _load_environment():
	add_child(environment.instantiate())

func _unload_environment():
	remove_child(get_node_or_null("Supermarket"))

func _to_main_menu():
	_unload_environment()
	port = PORT
	main_menu.show()
	hud.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if(multiplayer.peer_connected.is_connected(add_player)): multiplayer.peer_connected.disconnect(add_player)
	if(multiplayer.peer_disconnected.is_connected(remove_player)): multiplayer.peer_disconnected.disconnect(remove_player)
	if(multiplayer.server_disconnected.is_connected(remove_player)): multiplayer.server_disconnected.disconnect(remove_player)
	if(multiplayer.server_disconnected.is_connected(_to_main_menu)): multiplayer.server_disconnected.disconnect(_to_main_menu)
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
	health_bar.value = health_value

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
	
	print("Success! Join Address: %s" % upnp.query_external_address())
	emit_signal("upnp_ready", upnp.query_external_address())


func _on_upnp_ready(address) -> void:
	client_type_label.text = ""
	client_type_label.text = "Server \nip: %s" % address
