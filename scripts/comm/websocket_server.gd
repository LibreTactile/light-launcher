extends Node

var tcp_server = TCPServer.new()
var clients = {}
var next_client_id = 1

func _ready():
	var error = tcp_server.listen(8765)
	if error == OK:
		print("WebSocket server started on port 8765")
	else:
		print("Failed to start server: ", error)

func _process(_delta):
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
			
			# Send response
			var response = "Response: %s" % data
			websocket.send_text(response)
	
	# Remove disconnected clients
	for client_id in to_remove:
		print("Client disconnected: ", client_id)
		clients.erase(client_id)
