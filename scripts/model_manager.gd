extends Node

# Reference to rows and their buttons
var rows = {}  # Format: {row_index: {buttons: [], state: ButtonState}}
const ROW_COUNT = 4

# Called when the node enters the scene tree for the first time
func _ready():
	
	# Connect to static WebSocketServer signals
	WebSocketServer.connect_to_signal( self, _on_model_data_received)
	# Initialize rows
	_initialize_rows()
	# debug initialization
	# After _initialize_rows()
	# Row 1, button 1 (index 0) PULSATING
	_set_button_state(0, 0, Globals.ButtonState.PULSATING)
	# Row 2, button 2 (index 1) ACTIVE
	_set_button_state(1, 1, Globals.ButtonState.ACTIVE)
	# Row 3, button 1 (index 0) ACTIVE
	_set_button_state(2, 0, Globals.ButtonState.ACTIVE)
	# Row 3, button 2 (index 1) ACTIVE
	_set_button_state(3, 1, Globals.ButtonState.ACTIVE)

# Initialize rows and their buttons
func _initialize_rows():
	var rows_container = get_node("Element Rows")
	# Find existing rows
	for i in range(ROW_COUNT):
		var row_node = rows_container.get_child(i * 2)  # Account for separators
		if row_node and row_node.name.begins_with("element row"):
			var row_data = {
				"buttons": [],
				"state": Globals.ButtonState.INACTIVE
			}
			
			# Collect buttons in this row
			for child in row_node.get_children():
				if child is Button and child.has_method("set_state"):
					row_data.buttons.append(child)
			
			rows[i] = row_data
	
	# Set initial state
	for row_idx in rows:
		_set_row_state(row_idx, Globals.ButtonState.INACTIVE)

# Set state for an entire row
func _set_row_state(row_idx: int, state):
	if not rows.has(row_idx):
		return
	
	rows[row_idx].state = state
	for button in rows[row_idx].buttons:
		button.set_state(state)

# Set state for individual button in a row
func _set_button_state(row_idx: int, button_idx: int, state):
	if not rows.has(row_idx):
		return
	
	if button_idx >= 0 and button_idx < rows[row_idx].buttons.size():
		rows[row_idx].buttons[button_idx].set_state(state)

# Process model data and update states
func _on_model_data_received(jsonData):
	print("model manager, data recieved",jsonData)
	# Expected data format:
	# {
	#   "rows": [
	#     {
	#       "row": 0, 
	#       "state": "ACTIVE"  # Applies to whole row
	#       OR
	#       "buttons": [
	#         {"id": 0, "state": "ACTIVE"},
	#         {"id": 1, "state": "PULSATING"}
	#       ]
	#     },
	#     ...
	#   ]
	# }
	# Parse JSON string to dictionary
	var data = JSON.parse_string(jsonData)
	if data == null:
		push_error("Failed to parse JSON data")
		return
	for row_idx in rows:
		_set_row_state(row_idx, Globals.ButtonState.INACTIVE)
	if "rows" in data:
		for row_data in data.rows:
			var row_idx = row_data.row
			
			if "state" in row_data:
				# Set entire row state
				var state = _string_to_state(row_data.state)
				_set_row_state(row_idx, state)
			
			if "buttons" in row_data:
				# Set individual button states
				for btn_data in row_data.buttons:
					var state = _string_to_state(btn_data.state)
					_set_button_state(row_idx, btn_data.id, state)

# Helper to convert string to state enum
func _string_to_state(state_str: String):
	match state_str:
		"ACTIVE":
			return Globals.ButtonState.ACTIVE
		"INACTIVE":
			return Globals.ButtonState.INACTIVE
		"PULSATING":
			return Globals.ButtonState.PULSATING
		_:
			return Globals.ButtonState.INACTIVE

# Get current state of all rows
func get_current_state():
	var state_data = {"rows": []}
	
	for row_idx in rows:
		var row_state = {
			"row": row_idx,
			"buttons": []
		}
		
		# Check if all buttons have same state
		var first_state = rows[row_idx].buttons[0].button_state
		var uniform_state = true
		
		for button in rows[row_idx].buttons:
			if button.button_state != first_state:
				uniform_state = false
				break
				
		if uniform_state:
			row_state["state"] = _state_to_string(first_state)
		else:
			for btn_idx in range(rows[row_idx].buttons.size()):
				var button = rows[row_idx].buttons[btn_idx]
				row_state["buttons"].append({
					"id": btn_idx,
					"state": _state_to_string(button.button_state)
				})
		
		state_data["rows"].append(row_state)
	
	return state_data

# Helper to convert state enum to string
func _state_to_string(state):
	match state:
		Globals.ButtonState.ACTIVE:
			return "ACTIVE"
		Globals.ButtonState.INACTIVE:
			return "INACTIVE"
		Globals.ButtonState.PULSATING:
			return "PULSATING"
		_:
			return "INACTIVE"
