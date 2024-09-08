extends CanvasLayer

@onready var main_menu = $MainMenu
@onready var pause_menu = $pausemenu
@onready var full_overlay = $fullScreenOverlay
@onready var hud = $HUD
@onready var health_bar = $HUD/HealthBar
@onready var client_type_label = $HUD/Clienttypelabel

@onready var address_entry = $MainMenu/MarginContainer/VBoxContainer/HBoxContainer/AddressEntry
@onready var port_entry = $MainMenu/MarginContainer/VBoxContainer/HBoxContainer/PortEntry
@onready var address_info = $pausemenu/MarginContainer/VBoxContainer/HBoxContainer/AddressInfo
@onready var port_info = $pausemenu/MarginContainer/VBoxContainer/HBoxContainer/PortInfo

signal unload_environment
signal reset_gamestate
signal leave_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _notification(notif) -> void:
	if notif == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		pass
	elif notif == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		if(Global.gamestate == "game"):
			_open_pause_menu()
		pass

func _open_main_menu():
	#port = PORT
	main_menu.show()
	hud.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	multiplayer.multiplayer_peer.close()	

func _close_main_menu():
	main_menu.hide()

func _open_pause_menu():
	Global.gamestate = "pause_menu"
	pause_menu.show()
	full_overlay.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
func _close_pause_menu():
	Global.gamestate = "game"
	pause_menu.hide()
	full_overlay.hide()

func _set_ip_label(address, port):
	address_info.text = str(address)
	port_info.text = str(port)

func _on_continue_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_close_pause_menu()


func _on_leave_button_pressed() -> void:
	_close_pause_menu()
	emit_signal("leave_game")
