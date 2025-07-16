# websocket_server.gd (autoload version)
extends Node

# TCP server instance
var tcp_server = TCPServer.new()
# Dictionary to store connected clients
var clients = {}
# ID for the next client
var next_client_id = 1

# Service Discovery variables
var udp_socket = UDPServer.new()
var discovery_port = 8766  # Port for service discovery broadcasts
var server_port = 8765     # WebSocket server port
var discovery_timer = Timer.new()
var discovery_interval = 2.0  # Broadcast every 2 seconds
var discovery_enabled = false

## Signal emitted when model data is received.
# @param data The data received from the client.
signal model_data_received(data)

# Singleton instance of the WebSocket server.
static var instance = null

## Called when the node is added to the scene.
# Initializes the singleton instance and starts the server.
func _ready():
	instance = self
	setup_discovery_timer()
	start_server(8765)

## Sets up the discovery timer and connects its signal.
func setup_discovery_timer():
	discovery_timer.wait_time = discovery_interval
	discovery_timer.timeout.connect(_on_discovery_timer_timeout)
	discovery_timer.autostart = false
	add_child(discovery_timer)

## Starts the WebSocket server on the specified port.
# @param port The port number to start the server on.
static func start_server(port: int) -> void:
	if instance:
		instance.server_port = port
		var error = instance.tcp_server.listen(port)
		if error == OK:
			print("WebSocket server started on port ", port)
			instance.start_service_discovery()
		else:
			print("Failed to start server: ", error)

## Starts the service discovery system.
func start_service_discovery():
	var error = udp_socket.listen(discovery_port)
	if error == OK:
		print("Service discovery started on port ", discovery_port)
		discovery_enabled = true
		# Start broadcasting immediately if no clients are connected
		if clients.size() == 0:
			discovery_timer.start()
	else:
		print("Failed to start service discovery: ", error)

## Called when the discovery timer times out.
func _on_discovery_timer_timeout():
	if clients.size() == 0:  # Only broadcast when no clients are connected
		broadcast_service_info()

## Broadcasts service information to the network.
func broadcast_service_info():
	if not discovery_enabled:
		return
	
	# Get local IP address
	var local_ip = get_local_ip()
	if local_ip == "":
		return
	
	# Create service discovery message
	var service_info = {
		"service": "websocket_server",
		"ip": local_ip,
		"port": server_port,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_string = JSON.stringify(service_info)
	var packet = json_string.to_utf8_buffer()
	
	# Broadcast to local network (255.255.255.255)
	var broadcast_ip = "255.255.255.255"
	udp_socket.put_packet(packet, broadcast_ip, discovery_port)
	
	print("Broadcasting service info: ", json_string)

## Gets the local IP address of the machine.
# @return The local IP address as a string, or empty string if not found.
func get_local_ip() -> String:
	var addresses = IP.get_local_addresses()
	for address in addresses:
		# Skip loopback and IPv6 addresses
		if not address.begins_with("127.") and not address.begins_with("::") and address.find(":") == -1:
			return address
	return ""

## Called every frame. Handles new connections and processes data from clients.
# @param _delta The time elapsed since the last frame.
func _process(_delta):
	# Check for new connections
	if tcp_server.is_connection_available():
		var connection = tcp_server.take_connection()
		var ws_peer = WebSocketPeer.new()
		ws_peer.accept_stream(connection)
		var client_id = next_client_id
		next_client_id += 1
		clients[client_id] = ws_peer
		print("Client connected: ", client_id)
		
		# Stop discovery broadcasts when a client connects
		if not discovery_timer.is_stopped():
			discovery_timer.stop()
			print("Service discovery broadcasts stopped - client connected")
	
	var to_remove = []
	for client_id in clients:
		var websocket = clients[client_id]
		websocket.poll()
		
		var state = websocket.get_ready_state()
		if state == WebSocketPeer.STATE_CLOSED:
			to_remove.append(client_id)
			continue
		
		while websocket.get_available_packet_count() > 0:
			var packet = websocket.get_packet()
			var data = packet.get_string_from_utf8()
			print("Received data from client ", client_id, ": ", data)
			emit_signal("model_data_received", data)
	
	for client_id in to_remove:
		print("Client disconnected: ", client_id)
		clients.erase(client_id)
	
	# Restart discovery broadcasts if no clients are connected
	if clients.size() == 0 and discovery_enabled and discovery_timer.is_stopped():
		discovery_timer.start()
		print("Service discovery broadcasts restarted - no clients connected")

## Sends data to all connected clients.
# @param data The data to send to the clients.
static func send_to_all(data: String) -> void:
	if instance:
		for client_id in instance.clients:
			var websocket = instance.clients[client_id]
			# In Godot 4, we just send the packet - no flush needed
			websocket.send_text(data)
			print("Sent data to client ", client_id, ": ", data)

## Connects a receiver to the model_data_received signal.
## @param _receiver The object that will receive the signal (unused in static context).
## @param method The method to call on the receiver when the signal is emitted.
static func connect_to_signal(_receiver: Object, method: Callable) -> void:
	if instance:
		instance.model_data_received.connect(method)

## Stops the service discovery system.
static func stop_service_discovery() -> void:
	if instance:
		instance.discovery_enabled = false
		instance.discovery_timer.stop()
		instance.udp_socket.stop()
		print("Service discovery stopped")

## Manually triggers a service discovery broadcast.
static func broadcast_now() -> void:
	if instance and instance.discovery_enabled:
		instance.broadcast_service_info()

## Gets the current server status information.
# @return A dictionary containing server status information.
static func get_server_status() -> Dictionary:
	if instance:
		return {
			"server_running": instance.tcp_server.is_listening(),
			"server_port": instance.server_port,
			"connected_clients": instance.clients.size(),
			"discovery_enabled": instance.discovery_enabled,
			"discovery_active": not instance.discovery_timer.is_stopped(),
			"local_ip": instance.get_local_ip()
		}
	return {}

## Cleanup when the node is removed from the scene.
func _exit_tree():
	stop_service_discovery()
	tcp_server.stop()
	for client_id in clients:
		clients[client_id].close()
	clients.clear()
