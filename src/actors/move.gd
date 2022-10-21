extends Node
class_name Move

var from_tile: Tile
var to_tile: Tile
var pawn: Pawn
var captured_pawn: Pawn
var is_capture: bool
var will_king: bool


func _init(p: Pawn, to: Tile):
	from_tile = p.curr_tile
	to_tile = to
	pawn = p
	if from_tile.ne != null and to_tile == from_tile.ne.ne:
		captured_pawn = from_tile.ne.pawn
		is_capture = true
	elif from_tile.nw != null and to_tile == from_tile.nw.nw:
		captured_pawn = from_tile.nw.pawn
		is_capture = true
	elif from_tile.se != null and to_tile == from_tile.se.se:
		captured_pawn = from_tile.se.pawn
		is_capture = true
	elif from_tile.sw != null and to_tile == from_tile.sw.sw:
		captured_pawn = from_tile.sw.pawn
		is_capture = true
	else:
		captured_pawn = null
		is_capture = false
	
	if to_tile.row == 8 or to_tile.row == 1:
		will_king = true
	else:
		will_king = false
