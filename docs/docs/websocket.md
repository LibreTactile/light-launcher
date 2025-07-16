# WebSocket Server Documentation

This `websocket_server.gd` script defines a **singleton (autoload) WebSocket server** with **service discovery** for Godot (4.x). It's designed to allow other clients on the local network to discover and connect to the server automatically when no clients are connected.

This script provides:
* A full-featured, minimal WebSocket server with automatic port fallback
* Zero-configuration local network discovery (via UDP broadcast)
* A signal-based mechanism for receiving client messages
* Static methods for interacting with it globally
* Robust error handling and connection management

## 🔌 WebSocket Server Setup

* **`tcp_server`** is a low-level TCP server used as the base to accept WebSocket connections
* **Clients** are managed in a dictionary: `clients = {}` with unique IDs
* The server listens on a default port (8765), but automatically tries alternative ports if the main port is unavailable
* **Port fallback**: If port 8765 is in use, it tries ports 8766-8774 automatically

### Error Handling
* **ERR_ALREADY_IN_USE (22)**: Automatically tries alternative ports
* **Server restart protection**: Stops existing servers before starting new ones
* **Connection state validation**: Checks WebSocket state before sending data

---

## 📡 Service Discovery

* Uses **UDP broadcasts** to announce its presence on the local network, enabling clients to find the server without hardcoding an IP
* The server sends JSON packets with IP and port info every 2 seconds (when no clients are connected)
* UDP port used for discovery: **8766** (with automatic fallback to 8767-8775 if needed)
* **Broadcast method**: Creates fresh UDP peers for each broadcast to avoid connection issues

> Discovery is disabled when a client connects and resumes if no clients are connected.

### Discovery Message Format
```json
{
  "service": "websocket_server",
  "ip": "192.168.x.x",
  "port": 8765,
  "timestamp": 1726521140
}
```

### IP Address Priority
* Prioritizes private network ranges (192.168.x.x, 10.x.x.x, 172.x.x.x)
* Falls back to any non-loopback IPv4 address if no private IP is found
* Skips loopback (127.x.x.x) and IPv6 addresses

---

## 🧠 Singleton Pattern

* The script sets `static var instance` in `_ready()` to act as a **singleton**, allowing global access to methods and state via `WebSocketServer.instance`
* All static methods operate on the singleton instance

---

## 🔄 _process(_delta) Loop

This is the main runtime loop that:
* Accepts new WebSocket connections
* Polls each client's WebSocket for new data
* Emits a signal (`model_data_received`) when new data is received
* Removes disconnected clients automatically
* Restarts service discovery if no clients are left

### Connection Management
* Each client gets a unique ID starting from 1
* Clients are automatically removed when their WebSocket state becomes CLOSED
* Discovery broadcasts stop when the first client connects
* Discovery broadcasts resume when the last client disconnects

---

## 📤 Sending & Receiving Data

### Receiving
* When a client sends a packet, it's decoded from UTF-8 and emitted as a signal (`model_data_received`)
* The signal includes the raw data string

### Sending
* `send_to_all(data: String)` sends data to all connected clients via WebSocket
* Only sends to clients in OPEN state to prevent errors
* Provides console output for debugging sent messages

---

## 🧭 Discovery Mechanism

* Uses fresh `PacketPeerUDP` instances for each broadcast to avoid connection issues
* Broadcasts to `255.255.255.255` (the local network)
* Enables broadcast mode with `set_broadcast_enabled(true)`
* Uses `set_dest_address()` instead of `connect_to_host()` for better reliability
* The discovery only happens if no clients are connected
* Automatic port fallback if discovery port is unavailable

---

## 🔗 Signal & Connectivity Management

### Static Methods
* `connect_to_signal(receiver, method)` - Allows other nodes to listen to the `model_data_received` signal
* `stop_service_discovery()` - Disables discovery manually
* `broadcast_now()` - Forces a manual broadcast of server info
* `get_server_status()` - Returns current server state as a dictionary

### Server Status Dictionary
```gdscript
{
  "server_running": bool,      # Whether TCP server is listening
  "server_port": int,          # Current server port
  "connected_clients": int,    # Number of connected clients
  "discovery_enabled": bool,   # Whether discovery is enabled
  "discovery_active": bool,    # Whether discovery timer is running
  "local_ip": String          # Current local IP address
}
```

---

## 🧹 Cleanup

In `_exit_tree()`, the server:
* Stops the TCP server from listening
* Closes all client WebSocket connections
* Stops the discovery system properly
* Clears the client dictionary
* Closes UDP connections

---

## 🚀 Usage Example

```gdscript
# In your autoload setup, add websocket_server.gd as "WebSocketServer"

# Connect to receive data in another script
func _ready():
    WebSocketServer.connect_to_signal(self, _on_model_data_received)

func _on_model_data_received(data: String):
    print("Received: ", data)
    # Process the received data
    
# Send data to all clients
WebSocketServer.send_to_all("Hello from server!")

# Check server status
var status = WebSocketServer.get_server_status()
print("Server running: ", status.server_running)
print("Connected clients: ", status.connected_clients)
```

---

## 🔧 Configuration

### Default Ports
* **WebSocket Server**: 8765 (fallback: 8766-8774)
* **Service Discovery**: 8766 (fallback: 8767-8775)

### Timers
* **Discovery Interval**: 2.0 seconds between broadcasts
* **Discovery Condition**: Only when no clients are connected

### Network Settings
* **Broadcast Address**: 255.255.255.255
* **IP Priority**: Private network ranges first, then any IPv4

---

## 🐛 Troubleshooting

### Common Issues
1. **Port already in use**: Server automatically tries alternative ports
2. **UDP broadcast failures**: Uses fresh UDP peers for each broadcast
3. **Connection drops**: Automatic cleanup removes disconnected clients
4. **Discovery not working**: Check firewall settings for UDP port access

### Debug Output
The server provides extensive console output for:
* Server startup and port selection
* Client connections and disconnections
* Discovery broadcast attempts
* Data transmission events
* Error conditions and fallbacks