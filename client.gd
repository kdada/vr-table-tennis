extends Node3D

var initialized = false
var xr_origin: XROrigin3D
var xr_camera: XRCamera3D
var xr_left_hand: XRController3D
var xr_right_hand: XRController3D
var start_transform_a: Transform3D
var connected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.start_transform_a = self.get_node("../StartPositionA").transform
	self.xr_origin = preload("res://xr_origin.tscn").instantiate()
	self.xr_camera = self.xr_origin.get_node("XRCamera3D")
	self.xr_left_hand = self.xr_origin.get_node("LeftHand")
	self.xr_right_hand = self.xr_origin.get_node("RightHand")
	self.xr_origin.transform = self.start_transform_a
	self.add_child(self.xr_origin)

	var peer = ENetMultiplayerPeer.new()
	peer.create_client("YOUR_DOMAIN_OR_IP",19979)
	self.multiplayer.connected_to_server.connect(self.connected_to_server)
	self.multiplayer.connection_failed.connect(self.failed_to_connect_to_server)
	self.multiplayer.multiplayer_peer = peer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !connected:
		return

	if !self.multiplayer.has_multiplayer_peer() || self.multiplayer.is_server():
		return
	
	var uid = self.multiplayer.multiplayer_peer.get_unique_id()

	var player_node: PlayerNode = self.get_node("../Players/" + str(uid))
	if player_node == null || !player_node.initialized:
		return

	if !initialized:
		initialized = true
		self.xr_origin.transform = player_node.initialized_transform_origin
		print(player_node.initialized_transform_origin)

	player_node.transform_head = self.xr_camera.transform
	player_node.transform_left_hand = self.xr_left_hand.transform
	player_node.transform_right_hand = self.xr_right_hand.transform
	player_node.transform_origin = self.xr_origin.transform

	
func connected_to_server():
	connected = true
	print("Connected to server")


func failed_to_connect_to_server():
	connected = false
	print("Failed to connect to server")

