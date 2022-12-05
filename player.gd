extends Node3D
class_name PlayerNode

@export var transform_head: Transform3D
@export var transform_left_hand: Transform3D
@export var transform_right_hand: Transform3D
@export var transform_origin: Transform3D


var head: Node3D
var left_hand: Node3D
var right_hand: Node3D
var racket: Node3D
var racket_forward: Node3D
var initialized_transform_origin: Transform3D
var initialized: bool = false

func _enter_tree() -> void:
	self.set_multiplayer_authority(str(self.name).to_int())

func _ready() -> void:
	self.head = self.get_node("Head")
	self.left_hand = self.get_node("LeftHand")
	self.right_hand = self.get_node("RightHand")
	self.racket = self.right_hand.get_node("Racket")
	self.racket_forward = self.right_hand.get_node("Forward")
	if self.get_multiplayer_authority() == self.multiplayer.get_unique_id():
		self.head.visible = false
		rpc("_initialized_ready")


func _process(_delta: float) -> void:
	self.transform = self.transform_origin
	self.head.transform = self.transform_head
	self.left_hand.transform = self.transform_left_hand
	self.right_hand.transform = self.transform_right_hand


@rpc(any_peer, call_remote, reliable)
func _set_initialized_transform_origin(start: Transform3D):
	self.initialized_transform_origin = start
	self.initialized = true

@rpc(authority, call_remote, reliable)
func _initialized_ready():
	rpc("_set_initialized_transform_origin", self.initialized_transform_origin)