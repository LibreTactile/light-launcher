# websocket_server.gd (autoload version)
extends Node

# TCP server instance
var tcp_server = TCPServer.new()
# Dictionary to store connected clients
var clients = {}
# ID for the next client
var next_client_id = 1

## Signal emitted when model data is received.
# @param data The data received from the client.
signal model_data_received(data)

# Singleton instance of the WebSocket server.
static var instance = null

## Called when the node is added to the scene.
# Initializes the singleton instance and starts the server.
func _ready():
	instance = self
	start_server(8765)

## Starts the WebSocket server on the specified port.
# @param port The port number to start the server on.
static func start_server(port: int) -> void:
	if instance:
		var error = instance.tcp_server.listen(port)
		if error == OK:
			print("WebSocket server started on port ", port)
		else:
			print("Failed to start server: ", error)

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

## Sends data to all connected clients.
# @param data The data to send to the clients.
static func send_to_all(data: String) -> void:
	if instance:
		for client_id in instance.clients:
			var websocket = instance.clients[client_id]
			websocket.put_packet(data.to_utf8_buffer())
			websocket.flush()
			print("Sent data to client ", client_id, ": ", data)

## Connects a receiver to the model_data_received signal.
## @param receiver The object that will receive the signal.
## @param method The method to call on the receiver when the signal is emitted.
static func connect_to_signal(receiver: Object, method: Callable) -> void:
	if instance:
		instance.model_data_received.connect(method)
