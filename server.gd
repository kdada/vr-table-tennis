extends Node

var move_speed: float = 2
var players: Node3D
var game: Node3D

var player_count = 0
var start_transform_a: Transform3D
var start_transform_b: Transform3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var camera = Camera3D.new()
	camera.rotation = Vector3(-PI/4, PI/2, 0)
	self.add_child(camera)
	self.position = Vector3(0, 4, -8)
	self.players = self.get_node("../Players")

	self.start_transform_a = self.get_node("../StartPositionA").transform
	self.start_transform_b = self.get_node("../StartPositionB").transform

	var peer = ENetMultiplayerPeer.new()
	self.multiplayer.peer_connected.connect(self.add_player)
	self.multiplayer.peer_disconnected.connect(self.remove_player)
	peer.create_server(19979, 2)
	self.multiplayer.multiplayer_peer = peer
	print("Server started at 19979")

	self.game = preload("res://game.tscn").instantiate()
	self.get_parent().add_child(self.game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move freely.
	if Input.is_action_pressed("move_right"):
		self.position.z -= delta * self.move_speed
	if Input.is_action_pressed("move_left"):
		self.position.z += delta * self.move_speed
	if Input.is_action_pressed("move_backward"):
		self.position.x += delta * self.move_speed
	if Input.is_action_pressed("move_forward"):
		self.position.x -= delta * self.move_speed
	if Input.is_action_pressed("move_up"):
		self.position.y += delta * self.move_speed
	if Input.is_action_pressed("move_down"):
		self.position.y -= delta * self.move_speed


func add_player(id: int):
	self.player_count += 1
	var start_transform = start_transform_b
	if self.player_count % 2 == 1:
		start_transform = start_transform_a

	var player = preload("res://player.tscn").instantiate()
	player.name = str(id)
	player.initialized_transform_origin = start_transform
	player.set_multiplayer_authority(id)
	self.players.add_child(player)
	print("Client ", id, " connected")


func remove_player(id: int):
	var player = self.players.get_node(str(id))
	if player:
		player.queue_free()
	print("Client ", id, " disconnected")
