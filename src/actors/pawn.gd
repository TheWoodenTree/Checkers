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
var curr_tile: Object = null
var valid_move_tiles: Array
var float_scale: float = 0.0
var shake_scale: float = 0.0
var capturable_pawns: Dictionary
var previous_self: Pawn = null

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
	valid_move_tiles.clear()
	can_capture = false
	if color == "white" or (color == "black" and kinged):
		if curr_tile.ne != null:
			if curr_tile.ne.has_pawn() and curr_tile.ne.pawn.color != color \
			and curr_tile.ne.ne != null and not curr_tile.ne.ne.has_pawn():
				valid_move_tiles.append(curr_tile.ne.ne)
				print(capturable_pawns.values())
				capturable_pawns[curr_tile.ne.ne] = curr_tile.ne.pawn
				print(capturable_pawns.values())
				print("")
				can_capture = true
			elif not curr_tile.ne.has_pawn() and not can_capture:
				valid_move_tiles.append(curr_tile.ne)
			
		if curr_tile.nw != null:
			if curr_tile.nw.has_pawn() and curr_tile.nw.pawn.color != color \
			and curr_tile.nw.nw != null and not curr_tile.nw.nw.has_pawn():
				valid_move_tiles.append(curr_tile.nw.nw)
				print(capturable_pawns.values())
				capturable_pawns[curr_tile.nw.nw] = curr_tile.nw.pawn
				print(capturable_pawns.values())
				print("")
				can_capture = true
			elif not curr_tile.nw.has_pawn() and not can_capture:
				valid_move_tiles.append(curr_tile.nw)
	
	if color == "black" or (color == "white" and kinged):
		if curr_tile.se != null:
			if curr_tile.se.has_pawn() and curr_tile.se.pawn.color != color \
			and curr_tile.se.se != null and not curr_tile.se.se.has_pawn():
				valid_move_tiles.append(curr_tile.se.se)
				print(capturable_pawns.values())
				capturable_pawns[curr_tile.se.se] = curr_tile.se.pawn
				print(capturable_pawns.values())
				print("")
				can_capture = true
			elif not curr_tile.se.has_pawn() and not can_capture:
				valid_move_tiles.append(curr_tile.se)
			
		if curr_tile.sw != null:
			if curr_tile.sw.has_pawn() and curr_tile.sw.pawn.color != color \
			and curr_tile.sw.sw != null and not curr_tile.sw.sw.has_pawn():
				valid_move_tiles.append(curr_tile.sw.sw)
				print(capturable_pawns.values())
				capturable_pawns[curr_tile.sw.sw] = curr_tile.sw.pawn
				print(capturable_pawns.values())
				print("")
				can_capture = true
			elif not curr_tile.sw.has_pawn() and not can_capture:
				valid_move_tiles.append(curr_tile.sw)
	
	# Remove all non-capture moves if a capture move is possible
	if can_capture:
		for tile in valid_move_tiles:
			if curr_tile.ne == tile:
				valid_move_tiles.erase(tile)
			elif curr_tile.nw == tile:
				valid_move_tiles.erase(tile)
			elif curr_tile.se == tile:
				valid_move_tiles.erase(tile)
			elif curr_tile.sw == tile:
				valid_move_tiles.erase(tile)


func test_move(new_tile):
	curr_tile.pawn = null
	curr_tile = new_tile
	curr_tile.pawn = self
	if can_capture:
		capture(capturable_pawns[curr_tile])
	check_for_king()


func undo_move():
	pass


func move(new_tile):
	var last_tile = curr_tile
	curr_tile.pawn = null
	curr_tile = new_tile
	curr_tile.pawn = self
	last_tile.update_adj_pawns()
	curr_tile.update_adj_pawns()
	if can_capture:
		capture(capturable_pawns[curr_tile])
	var move_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position", curr_tile.pos, Global.MOVE_TIME)
	check_for_king()


func check_for_king():
	if curr_tile.row == 8 and color == "white":
		kinged = true
		await get_tree().create_timer(Global.MOVE_TIME).timeout
		crown.visible = true
		
	if curr_tile.row == 1 and color == "black":
		kinged = true
		await get_tree().create_timer(Global.MOVE_TIME).timeout
		crown.visible = true


func capture(captured_pawn):
	#print("Cunt")
	if captured_pawn.color == "white":
		Global.board.white_pawns.erase(captured_pawn)
	if captured_pawn.color == "black":
		Global.board.black_pawns.erase(captured_pawn)
	
	#print("Dict: ")
	print(capturable_pawns[curr_tile])
	capturable_pawns.erase(curr_tile)
	captured_pawn.curr_tile.pawn = null
	
	var captured_pawn_tile = captured_pawn.curr_tile
	captured_pawn.queue_free()
	captured_pawn_tile.update_adj_pawns()
	
	just_captured = true
