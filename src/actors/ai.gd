extends Node2D

const CAPTURE_VAL: int = 1
const KING_VAL: int = 3
const FUTURE_DEPTH: int = 0

var turn: int = 1
var board_copy: Board
var moveable_pawns: Array
var curr_pawn: Pawn = null
var pawns: Array


func _ready():
	Global.board.connect("turn_ended", think.bind(FUTURE_DEPTH, board_copy))


func think(depth):
#	while Global.board.mode == Global.AIvsAI:
#		if Global.board.turn == Global.board.P1_TURN:
#			pawns = Global.board.white_pawns
#		else:
#			pawns = Global.board.black_pawns
#		moveable_pawns.clear()
#		for pawn in pawns:
#			if pawn.valid_moves.size() > 0:
#				moveable_pawns.append(pawn)
#
#		if moveable_pawns.size() > 0:
#			curr_pawn = moveable_pawns[randi_range(0, moveable_pawns.size() - 1)]
#			curr_pawn.update_valid_moves()
#		var num_valid_moves = curr_pawn.valid_moves.size()
#		var move: Move
#		var not_moved = true
#		while not_moved or (curr_pawn.just_captured and curr_pawn.can_capture):
#			if curr_pawn.valid_moves.size() > 0:
#				move = curr_pawn.valid_moves[randi_range(0, num_valid_moves - 1)]
#				curr_pawn.do_move(move)
#				await get_tree().create_timer(Global.MOVE_TIME).timeout
#				#curr_pawn.undo_move()
#				curr_pawn.update_valid_moves()
#				not_moved = false
#				num_valid_moves = curr_pawn.valid_moves.size()
#			else:
#				break
#		curr_pawn.just_captured = false
#		if Global.board.turn == Global.board.P1_TURN:
#			Global.board.turn = Global.board.P2_TURN
#		else:
#			Global.board.turn = Global.board.P1_TURN
	
	
	assume_move(depth)


func assume_move(depth):
	for pawn in Global.board.black_pawns:
		var num_valid_moves = pawn.valid_moves.size()
		var not_moved = true
		var num_moves = 0
		while not_moved or (pawn.just_captured and pawn.can_capture):
			if num_valid_moves > 0:
				print("BLACK")
				var move: Move = pawn.valid_moves[randi_range(0, num_valid_moves - 1)]
				pawn.do_test_move(move)
				num_valid_moves = pawn.valid_moves.size()
				not_moved = false
				num_moves += 1
			else:
				break
			#await get_tree().create_timer(Global.MOVE_TIME).timeout
			assume_enemy_move(depth)
			pawn.undo_move(num_moves)


func assume_enemy_move(depth):
	for pawn in Global.board.white_pawns:
		var num_valid_moves = pawn.valid_moves.size()
		print("WHITE")
		var not_moved = true
		var num_moves = 0
		while not_moved or (pawn.just_captured and pawn.can_capture):
			if num_valid_moves > 0:
				var move: Move = pawn.valid_moves[randi_range(0, num_valid_moves - 1)]
				pawn.do_test_move(move)
				num_valid_moves = pawn.valid_moves.size()
				not_moved = false
				num_moves += 1
			else:
				break
		if depth > 0:
			think(depth - 1)
		pawn.undo_move(num_moves)


func end_turn():
	emit_signal("turn_ended")
