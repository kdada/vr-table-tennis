extends XROrigin3D

var interface : XRInterface
var front: Node3D
var right: Node3D
var moving_silent: float
var rotating_silent: float
var left_controller: XRController3D
var right_controller: XRController3D
var moving_speed: float
var rotating_speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.front = self.get_node("./Front")
	self.right = self.get_node("./Right")
	self.interface = XRServer.find_interface("OpenXR")
	self.left_controller = self.get_node("./LeftHand")
	self.right_controller = self.get_node("./RightHand")
	self.left_controller.button_pressed.connect(self.left_controller_button_pressed)
	self.right_controller.button_pressed.connect(self.right_controller_button_pressed)
	self.moving_speed = 0
	self.rotating_speed = PI/12

	if interface and interface.is_initialized():
		print("OpenXR initialised successfully")
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialised, please check if your headset is connected")

func left_controller_button_pressed(button_name: String):
	if button_name == "by_button":
		self.moving_speed += 1
		if self.moving_speed > 3:
			self.moving_speed = 3

	if button_name == "ax_button":
		self.moving_speed -= 1
		if self.moving_speed < 0:
			self.moving_speed = 0

func right_controller_button_pressed(button_name: String):
	if button_name == "by_button":
		self.rotating_speed += PI/12
		if self.rotating_speed > PI:
			self.rotating_speed = PI

	if button_name == "ax_button":
		self.rotating_speed -= PI/12
		if self.rotating_speed < PI/12:
			self.rotating_speed = PI/12



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var moving = left_controller.get_axis("primary")
	var front_vector = (self.front.global_position - self.global_position).normalized()
	var right_vector = (self.right.global_position - self.global_position).normalized()
	if self.moving_speed > 0:
		moving = moving.normalized() * self.moving_speed * delta
		self.global_position += front_vector * moving.y + right_vector * moving.x
	else:
		if self.moving_silent <= 0:
			self.moving_silent = 0.3
			if moving.x > 0.3:
				self.global_position += right_vector
			elif moving.x < -0.3:
				self.global_position -= right_vector
			elif moving.y > 0.3:
				self.global_position += front_vector
			elif moving.y < -0.3:
				self.global_position -= front_vector

	self.moving_silent-= delta

	var rotating = right_controller.get_axis("primary")
	if self.rotating_silent <= 0:
			self.rotating_silent = 0.3
			if rotating.x > 0.3:
				self.rotate(Vector3(0,1,0), -self.rotating_speed)
			elif rotating.x < -0.3:
				self.rotate(Vector3(0,1,0), self.rotating_speed)
				
	self.rotating_silent-= delta
