extends Button

## The name of the button, exposed in the inspector
@export var button_name: String = "x"

## Track the previous press state to detect frame-specific events
var _was_pressed: bool = false

func _process(delta: float) -> void:
	# Detect button down on the exact frame of press
	if is_pressed() and not _was_pressed:
		print("button is pressed: ", button_name)
		WebSocketServer.send_to_all("B" + button_name+"D*")
	
	# Detect button up on the exact frame of release
	if not is_pressed() and _was_pressed:
		print("button is NOT pressed: ", button_name)
		WebSocketServer.send_to_all("B" + button_name+"U*")
	
	# Update the previous press state
	_was_pressed = is_pressed()
	
# Public method to change the button name from another script
# $YourButtonNode.set_button_name("NewName")
func set_button_name(new_name: String) -> void:
	button_name = new_name
