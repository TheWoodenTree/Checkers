extends Node2D

var moveable_pawns: Array
var curr_pawn: Pawn = null
var pawns: Array


func _ready():
	Global.board.connect("turn_ended", think)


func think():
	print("My Turn!")
	pawns = Global.board.black_pawns
	moveable_pawns.clear()
	for pawn in pawns:
		if pawn.valid_move_tiles.size() > 0:
			moveable_pawns.append(pawn)
	
	#await get_tree().create_timer(2.0).timeout
	
	if moveable_pawns.size() > 0:
		curr_pawn = moveable_pawns[randi_range(0, moveable_pawns.size() - 1)]
	var to_tile = curr_pawn.valid_move_tiles[randi_range(0, curr_pawn.valid_move_tiles.size() - 1)]
	if curr_pawn.valid_move_tiles.size() > 0:
		curr_pawn.move(to_tile)
	while curr_pawn.just_captured and curr_pawn.can_capture:
		await get_tree().create_timer(Global.MOVE_TIME).timeout
		to_tile = curr_pawn.valid_move_tiles[randi_range(0, curr_pawn.valid_move_tiles.size() - 1)]
		curr_pawn.move(to_tile)
	curr_pawn.just_captured = false
	Global.board.turn = Global.board.P1_TURN


func end_turn():
	emit_signal("turn_ended")
