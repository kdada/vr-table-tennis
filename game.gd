extends Node3D

var ball: RigidBody3D

var players: Node3D
var scoreboard_a: Label3D
var scoreboard_b: Label3D
var table_part_a: Area3D
var table_part_b: Area3D
var reset_score: Area3D
var countdown: Label3D
var countdown_startup: float = 5
var score_a = 0
var score_b = 0
var last_drop_point = ""
var drop_point_of_last_frame = ""
var player_properties = {}
var box_rid: RID
const racket_position_sample_count: int = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = self.get_parent()
	self.players = root.get_node("Players")
	self.ball = root.get_node("Activity/Ball")
	self.scoreboard_a = root.get_node("Activity/ScoreA")
	self.scoreboard_b = root.get_node("Activity/ScoreB")
	self.table_part_a = root.get_node("Activity/TablePartA")
	self.table_part_b = root.get_node("Activity/TablePartB")
	self.reset_score = root.get_node("Activity/ResetScore")
	self.countdown = root.get_node("Activity/Countdown")

	self.box_rid = PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(self.box_rid, Vector3(1, 1, 1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for player in self.players.get_children():
		var properties = self.player_properties.get(player.name, {"last_racket_position": Vector3(0, 0, 0),
			"position_samples": [], "silent_duration": 0.0})
		if properties.silent_duration > 0:
			properties.silent_duration -= delta

		if !self.player_properties.has(player.name):
			self.player_properties[player.name] = properties

	_process_stage_1(delta)

	for player in self.players.get_children():
		var properties = self.player_properties.get(player.name)
		if properties.position_samples.size() >= racket_position_sample_count:
			properties.position_samples.pop_front()
		properties.position_samples.push_back(player.racket.global_position)
		properties.last_racket_position = properties.position_samples[0]


func _process_stage_1(delta: float) -> void:
	for n in self.reset_score.get_overlapping_bodies():
		if n == self.ball:
			self.countdown_startup = 5
			self.score_a = 0
			self.score_b = 0
			self.scoreboard_a.text = "{scoreA} : {scoreB}".format({"scoreA": 0, "scoreB": 0})
			self.scoreboard_b.text = "{scoreB} : {scoreA}".format({"scoreA": 0, "scoreB": 0})

	if self.countdown_startup > 0:
		self.countdown_startup -= delta	
		if self.countdown_startup > 0:
			self.countdown.text = str(int(self.countdown_startup) + 1)
			if self.countdown_startup < 3:
				self.ball.position = Vector3(-5, 1.7, -7.5)
			return

		self.countdown.text = ""
		self.last_drop_point = ""
		self.ball.position = Vector3(-5, 1.7, -7.5)
		self.ball.linear_velocity = Vector3(0,0,3)

	var dropped_on_table_part_a = false 
	for n in self.table_part_a.get_overlapping_bodies():
		if n == self.ball:
			dropped_on_table_part_a = true
			break
	
	var exited_from_table_part_a = false
	if self.drop_point_of_last_frame == "a" && !dropped_on_table_part_a:
		exited_from_table_part_a = true
		self.drop_point_of_last_frame = ""
	
	if self.drop_point_of_last_frame == "" && dropped_on_table_part_a:
		self.drop_point_of_last_frame = "a"


	var dropped_on_table_part_b = false
	for n in self.table_part_b.get_overlapping_bodies():
		if n == self.ball:
			dropped_on_table_part_b = true
			break

	var exited_from_table_part_b = false
	if self.drop_point_of_last_frame == "b" && !dropped_on_table_part_b:
		exited_from_table_part_b = true
		self.drop_point_of_last_frame = ""
	
	if self.drop_point_of_last_frame == "" && dropped_on_table_part_b:
		self.drop_point_of_last_frame = "b"

	
	var end = false
	
	if exited_from_table_part_a:
		if self.last_drop_point == "a":
			end = true
		else:
			self.last_drop_point = "a"

	
	if exited_from_table_part_b:
		if self.last_drop_point == "b":
			end = true
		else:
			self.last_drop_point = "b"

	if !end && self.ball.position.y < 0.5:
		end = true

	if end:
		if self.last_drop_point == "a":
			self.score_b += 1
		elif self.last_drop_point == "b":
			self.score_a += 1
		self.scoreboard_a.text = "{scoreA} : {scoreB}".format({"scoreA": score_a, "scoreB": score_b})
		self.scoreboard_b.text = "{scoreB} : {scoreA}".format({"scoreA": score_a, "scoreB": score_b})
		self.countdown_startup = 5
	


	for player in self.players.get_children():
		var properties = self.player_properties.get(player.name)
		if properties.silent_duration > 0:
			continue
		
		var racket: Node3D = player.racket
		if (self.ball.global_position - racket.global_position).length() > 1:
			continue

		var last_racket_position: Vector3 = properties.last_racket_position
		
		var space_state  = self.ball.get_world_3d().get_direct_space_state()
		var parameter = PhysicsShapeQueryParameters3D.new()
		parameter.collision_mask = 2
		parameter.shape_rid = self.box_rid
		parameter.transform = racket.global_transform
		var nodes = space_state.intersect_shape(parameter)
		for n in nodes:
			if n.collider != self.ball:
				continue
			
			var racket_velocity = (racket.global_position - last_racket_position) / delta / (racket_position_sample_count - 3)
			var ball_original_velocity = self.ball.linear_velocity
			var inversed_transform = racket.global_transform.affine_inverse()
			var ball_position = inversed_transform * self.ball.global_position
			var ball_velocity_position = inversed_transform * (self.ball.global_position + self.ball.linear_velocity)
			var ball_velocity  = ball_velocity_position - ball_position
			ball_velocity.x = -ball_velocity.x
			ball_velocity_position = ball_velocity + ball_position
			ball_velocity_position = racket.global_transform * ball_velocity_position
			var ball_new_velocity = ball_velocity_position - self.ball.global_position

			ball_new_velocity = ball_new_velocity.normalized() * ball_original_velocity.length()
			self.ball.linear_velocity = ball_new_velocity + racket_velocity
			var direction = player.racket_forward.global_position - racket.global_position
			var dot = direction.dot(ball_new_velocity)
			properties.silent_duration = 0.1
			if dot < 0:
				direction = -direction
			self.ball.global_position += direction * 0.1
			break