extends Node

# TCP server instance
var tcp_server = TCPServer.new()
# Dictionary to store connected clients
var clients = {}
# ID for the next client
var next_client_id = 1

# Define the signal
signal model_data_received(data)

# Called when the node is added to the scene.
# Starts the TCP server on port 8765.
func _ready():
	# Start listening on port 8765
	var error = tcp_server.listen(8765)
	if error == OK:
		print("WebSocket server started on port 8765")
	else:
		print("Failed to start server: ", error)

# Called every frame. Handles new connections and processes data from clients.
# @param _delta Time elapsed since the last frame.
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
		
		# Check the state of the WebSocket connection
		var state = websocket.get_ready_state()
		if state == WebSocketPeer.STATE_CLOSED:
			to_remove.append(client_id)
			continue
		
		# Process all available packets
		while websocket.get_available_packet_count() > 0:
			var packet = websocket.get_packet()
			var data = packet.get_string_from_utf8()
			print("Received data from client ", client_id, ": ", data)
			
			# trigger signal model_data_received
			emit_signal("model_data_received", data)

	
	# Remove disconnected clients
	for client_id in to_remove:
		print("Client disconnected: ", client_id)
		clients.erase(client_id)

# Send data to all connected clients.
# @param data The data to send.
func send_data(data: String) -> void:
	for client_id in clients:
		var websocket = clients[client_id]
		websocket.put_packet(data.to_utf8_buffer())
		websocket.flush()
		print("Sent data to client ", client_id, ": ", data)
