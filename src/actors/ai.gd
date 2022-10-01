extends Node2D

const CAPTURE_VAL: int = 1
const KING_VAL: int = 3
const FUTURE_DEPTH: int = 1

var turn: int = 1
var board_copy: Board
var moveable_pawns: Array
var curr_pawn: Pawn = null
var pawns: Array


func _ready():
	Global.board.connect("turn_ended", think.bind(FUTURE_DEPTH, board_copy))


func think(depth, board_copy):
	while Global.board.mode == Global.AIvsAI:
		if Global.board.turn == Global.board.P1_TURN:
			pawns = Global.board.white_pawns
		else:
			pawns = Global.board.black_pawns
		moveable_pawns.clear()
		for pawn in pawns:
			if pawn.valid_move_tiles.size() > 0:
				moveable_pawns.append(pawn)

		if moveable_pawns.size() > 0:
			curr_pawn = moveable_pawns[randi_range(0, moveable_pawns.size() - 1)]
			curr_pawn.update_valid_moves()
		var num_valid_moves = curr_pawn.valid_move_tiles.size()
		var to_tile
		var not_moved = true
		while not_moved or (curr_pawn.just_captured and curr_pawn.can_capture):
			if curr_pawn.valid_move_tiles.size() > 0:
				await get_tree().create_timer(Global.MOVE_TIME).timeout
				to_tile = curr_pawn.valid_move_tiles[randi_range(0, num_valid_moves - 1)]
				curr_pawn.move(to_tile)
				curr_pawn.update_valid_moves()
				not_moved = false
				num_valid_moves = curr_pawn.valid_move_tiles.size()
			else:
				break
		curr_pawn.just_captured = false
		if Global.board.turn == Global.board.P1_TURN:
			Global.board.turn = Global.board.P2_TURN
		else:
			Global.board.turn = Global.board.P1_TURN
	
	
	
#	if depth > 0:
#		#var new_board_copy = board_copy.duplicate()
#		assume_move(depth, Global.board)
#	#else:
#		#board_copy.queue_free()


func assume_move(depth, board_copy):
	var initial_board_copy = board_copy#.duplicate()
	for pawn in board_copy.black_pawns:
		var num_valid_moves = pawn.valid_move_tiles.size()
		if num_valid_moves > 0:
			var to_tile = pawn.valid_move_tiles[randi_range(0, num_valid_moves - 1)]
			pawn.move(to_tile, true)
			await get_tree().create_timer(Global.MOVE_TIME).timeout
			assume_enemy_move(depth, board_copy)
		#	board_copy = initial_board_copy


func assume_enemy_move(depth, board_copy):
	var initial_board_copy = board_copy#.duplicate()
	for pawn in board_copy.white_pawns:
		var num_valid_moves = pawn.valid_move_tiles.size()
		if num_valid_moves > 0:
			print(pawn.curr_tile.title)
			var to_tile = pawn.valid_move_tiles[randi_range(0, num_valid_moves - 1)]
			pawn.move(to_tile, true)
			await get_tree().create_timer(Global.MOVE_TIME).timeout
			think(depth - 1, board_copy)
		#	board_copy = initial_board_copy
			


func end_turn():
	emit_signal("turn_ended")
