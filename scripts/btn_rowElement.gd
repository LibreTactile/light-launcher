extends Button

# Enum for button states
enum ButtonState {INACTIVE, ACTIVE, PULSATING}

# Button properties
var button_state = ButtonState.PULSATING
var is_vibrating = false
var vibration_timer = null
var pulse_on_time = 0.2
var pulse_off_time = 0.5
var active_touches = {}  # Track all active touches and their inside status
# Called when the node enters the scene tree for the first time
func _ready():
	vibration_timer = Timer.new()
	add_child(vibration_timer)
	vibration_timer.one_shot = true
	vibration_timer.timeout.connect(_on_vibration_timer_timeout)
	update_appearance()

# Handle all input events
func _input(event):
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
		return

	# Handle touch events
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch started
			var was_any_inside = active_touches.values().any(func(v): return v)
			active_touches[event.index] = _is_point_inside(event.position)
			
			if not was_any_inside and active_touches[event.index]:
				_trigger_vibration()
		else:
			# Touch ended
			var was_inside = active_touches.erase(event.index)
			if was_inside:
				_update_vibration_state()

	# Handle drag events
	if event is InputEventScreenDrag:
		if active_touches.has(event.index):
			var was_inside = active_touches[event.index]
			var is_now_inside = _is_point_inside(event.position)
			active_touches[event.index] = is_now_inside
			
			if was_inside != is_now_inside:
				_update_vibration_state()

# Update vibration state based on all active touches
func _update_vibration_state():
	var any_inside = active_touches.values().any(func(val): return val)
	if any_inside:
		if not is_vibrating:
			_trigger_vibration()
	else:
		_stop_vibration()

# Trigger vibration based on button state
func _trigger_vibration():
	is_vibrating = true
	match button_state:
		ButtonState.ACTIVE:
			start_continuous_vibration(50, 50,1.0)
		ButtonState.INACTIVE:
			pass
		ButtonState.PULSATING:
			start_pulsating_vibration()

# Start continuous vibration pattern
func start_continuous_vibration(duration_ms, interval_ms,amplitude):
	if vibration_timer.is_stopped():
		vibration_timer.wait_time = interval_ms / 1000.0
		vibration_timer.start()
	Input.vibrate_handheld(duration_ms,amplitude)

# Handle vibration timer timeout
func _on_vibration_timer_timeout():
	if not is_vibrating:
		return
		
	match button_state:
		ButtonState.ACTIVE:
			start_continuous_vibration(50, 50,1.0)
		ButtonState.INACTIVE:
			pass
		ButtonState.PULSATING:
			# Existing pulsating logic
			if is_vibrating:
				Input.vibrate_handheld(300)
				vibration_timer.wait_time = pulse_on_time
			else:
				vibration_timer.wait_time = pulse_off_time
			vibration_timer.start()

# Stop vibration
func _stop_vibration():
	if is_vibrating:
		is_vibrating = false
		vibration_timer.stop()

# Helper to check if touch point is inside button
func _is_point_inside(point):
	return get_global_rect().has_point(point)

# Start pulsating vibration
func start_pulsating_vibration():
	is_vibrating = true
	Input.vibrate_handheld(300)
	vibration_timer.wait_time = pulse_on_time
	vibration_timer.start()

# Set button state
func set_state(new_state):
	button_state = new_state
	
	# Stop any existing vibration pattern
	if is_vibrating and button_state != ButtonState.PULSATING:
		is_vibrating = false
		vibration_timer.stop()
	
	# Start pulsating if that's the new state
	if button_state == ButtonState.PULSATING and not is_vibrating:
		start_pulsating_vibration()
	
	# Update button appearance
	update_appearance()

# Update button appearance based on state
func update_appearance():
	match button_state:
		ButtonState.ACTIVE:
			modulate = Color(0, 1, 0, 1)  # Green
		ButtonState.INACTIVE:
			modulate = Color(0.5, 0.5, 0.5, 1)  # Gray
		ButtonState.PULSATING:
			modulate = Color(1, 0, 0, 1)  # Red
