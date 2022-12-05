extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	if !self.multiplayer.is_server() && !self.freeze:
		self.process_mode = Node.PROCESS_MODE_DISABLED
		self.freeze = true
