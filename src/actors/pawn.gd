extends Node2D
class_name Pawn

@onready var sprite = $sprite
@onready var shader = $sprite.material
@onready var crown = $crown
@onready var crown_shader = $crown.material

var can_capture = false
var just_captured = false
var kinged = false
var start_time: float = 0.0
var selected: bool = false
var elapsed_time: float
var color: String
var curr_tile: Tile = null
var valid_moves: Array
var float_scale: float = 0.0
var shake_scale: float = 0.0
var move_history: Array

signal pawn_moved
signal pawn_test_moved


func _process(delta):
	if selected:
		elapsed_time = (Time.get_ticks_msec() - start_time) / 1000.0
		shader.set_shader_parameter("elapsedTime", elapsed_time)
		crown_shader.set_shader_parameter("elapsedTime", elapsed_time)
	
	if float_scale > 0:
		elapsed_time = (Time.get_ticks_msec() - start_time) / 1000.0
		float_scale -= 25 * delta
		if float_scale < 0:
			float_scale = 0
		shader.set_shader_parameter("floatScale", float_scale)
		crown_shader.set_shader_parameter("floatScale", float_scale)

	if shake_scale > 0:
		shake_scale -= 25.0 * delta
		if shake_scale < 0:
			shake_scale = 0
		shader.set_shader_parameter("shakeScale", shake_scale)
		crown_shader.set_shader_parameter("shakeScale", shake_scale)


func init(t):
	curr_tile = t
	position = curr_tile.pos


func set_selected(s):
	selected = s
	start_time = Time.get_ticks_msec()
	shader.set_shader_parameter("selected", selected)
	crown_shader.set_shader_parameter("selected", selected)
	var color_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if selected:
		color_tween.tween_property(sprite, "modulate", Color.LIGHT_BLUE, 0.1)
	else:
		color_tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		float_scale = 6.0


func shake():
	if shake_scale < 0.01:
		var color_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		color_tween.tween_property(sprite, "modulate", Color.RED, 0.15)
		color_tween.set_ease(Tween.EASE_IN)
		if selected:
			color_tween.tween_property(sprite, "modulate", Color.LIGHT_BLUE, 0.15)
		else:
			color_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
		shake_scale = 10.0


func update_valid_moves():
	valid_moves.clear()
	can_capture = false
	if color == "white" or (color == "black" and kinged):
		if curr_tile.ne != null:
			if curr_tile.ne.has_pawn() and curr_tile.ne.pawn.color != color \
			and curr_tile.ne.ne != null and not curr_tile.ne.ne.has_pawn():
				valid_moves.append(Move.new(self, curr_tile.ne.ne))
				can_capture = true
			elif not curr_tile.ne.has_pawn() and not can_capture:
				valid_moves.append(Move.new(self, curr_tile.ne))
			
		if curr_tile.nw != null:
			if curr_tile.nw.has_pawn() and curr_tile.nw.pawn.color != color \
			and curr_tile.nw.nw != null and not curr_tile.nw.nw.has_pawn():
				valid_moves.append(Move.new(self, curr_tile.nw.nw))
				can_capture = true
			elif not curr_tile.nw.has_pawn() and not can_capture:
				valid_moves.append(Move.new(self, curr_tile.nw))
	
	if color == "black" or (color == "white" and kinged):
		if curr_tile.se != null:
			if curr_tile.se.has_pawn() and curr_tile.se.pawn.color != color \
			and curr_tile.se.se != null and not curr_tile.se.se.has_pawn():
				valid_moves.append(Move.new(self, curr_tile.se.se))
				can_capture = true
			elif not curr_tile.se.has_pawn() and not can_capture:
				valid_moves.append(Move.new(self, curr_tile.se))
			
		if curr_tile.sw != null:
			if curr_tile.sw.has_pawn() and curr_tile.sw.pawn.color != color \
			and curr_tile.sw.sw != null and not curr_tile.sw.sw.has_pawn():
				valid_moves.append(Move.new(self, curr_tile.sw.sw))
				can_capture = true
			elif not curr_tile.sw.has_pawn() and not can_capture:
				valid_moves.append(Move.new(self, curr_tile.sw))
	
	# Remove all non-capture moves if a capture move is possible
	if can_capture:
		for move in valid_moves:
			if curr_tile.ne == move.to_tile:
				valid_moves.erase(move)
			elif curr_tile.nw == move.to_tile:
				valid_moves.erase(move)
			elif curr_tile.se == move.to_tile:
				valid_moves.erase(move)
			elif curr_tile.sw == move.to_tile:
				valid_moves.erase(move)


func do_test_move(move: Move):
	move_history.append(move)
	curr_tile.pawn = null
	curr_tile = move.to_tile
	curr_tile.pawn = self
	position = curr_tile.pos
	
	if move.is_capture:
		if move.captured_pawn.color == "white":
			Global.board.white_pawns.erase(move.captured_pawn)
		if move.captured_pawn.color == "black":
			Global.board.black_pawns.erase(move.captured_pawn)
		move.captured_pawn.curr_tile.pawn = null
		just_captured = true
	
	check_for_king(move)
	Global.board.update_pawns()
	await get_tree().create_timer(Global.MOVE_TIME).timeout


func undo_move(num_moves):
	for i in range(0, num_moves):
		var last_move: Move = move_history.pop_back()
		var second_last_move: Move
		if move_history.size() > 1:
			second_last_move = move_history.back()
		else:
			second_last_move = null
		
		curr_tile.pawn = null
		curr_tile = last_move.from_tile
		curr_tile.pawn = self
		position = curr_tile.pos
		
		if last_move.is_capture:
			can_capture = true
			var captured_pawn = last_move.captured_pawn
			if captured_pawn.color == "white":
				Global.board.white_pawns.append(captured_pawn)
			elif captured_pawn.color == "black":
				Global.board.black_pawns.append(captured_pawn)
		else:
			can_capture = false
		
		if second_last_move != null and not second_last_move.is_capture:
			just_captured = false
		
		if last_move.will_king:
			kinged = false
			crown.visible = false
		
		Global.board.update_pawns()


func do_move(move: Move):
	move_history.append(move)
	curr_tile.pawn = null
	curr_tile = move.to_tile
	curr_tile.pawn = self
	if move.is_capture:
		capture(move.captured_pawn)
	var move_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position", curr_tile.pos, Global.MOVE_TIME)
	check_for_king(move)
	Global.board.update_pawns()


func check_for_king(move):
	if move.will_king:
		if color == "white":
			kinged = true
			await get_tree().create_timer(Global.MOVE_TIME).timeout
			crown.visible = true
			
		if color == "black":
			kinged = true
			await get_tree().create_timer(Global.MOVE_TIME).timeout
			crown.visible = true


func capture(captured_pawn):
	if captured_pawn.color == "white":
		Global.board.white_pawns.erase(captured_pawn)
	if captured_pawn.color == "black":
		Global.board.black_pawns.erase(captured_pawn)
	
	captured_pawn.curr_tile.pawn = null
	
	captured_pawn.queue_free()
	just_captured = true
