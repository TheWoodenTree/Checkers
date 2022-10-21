extends Node
class_name Tile

const TILE_SIZE = 128

var row: int
var col: int
var pos: Vector2
var title: String
var board: Object
var pawn: Pawn
var rect: Rect2
var highlight: ColorRect
var selected: bool
var ne: Tile
var se: Tile
var nw: Tile
var sw: Tile


func _init(r, c, b):
	row = r
	col = c
	pos.x = col * TILE_SIZE - TILE_SIZE / 2.0
	pos.y = (9 - row) * TILE_SIZE - TILE_SIZE / 2.0
	title = char(col + 96) + "%d" % row
	board = b
	pawn = null
	selected = false
	ne = null
	se = null
	nw = null
	sw = null
	
	var rect_pos = Vector2i((col - 1) * TILE_SIZE, ((9 - row) - 1) * TILE_SIZE)
	var rect_size = Vector2i(TILE_SIZE, TILE_SIZE)
	rect = Rect2(rect_pos, rect_size)

func has_pawn():
	return pawn != null

func is_selected():
	return selected

func is_row_col(r, c):
	return row == r and col == c

func init_adj_tiles():
	if board.tiles_dict.has([Vector2i(row + 1, col + 1)]):
		ne = board.tiles_dict[Vector2i(row + 1, col + 1)]
	else:
		ne = null
	
	if board.tiles_dict.has([Vector2i(row - 1, col + 1)]):
		se = board.tiles_dict[Vector2i(row - 1, col + 1)]
	else:
		se = null
	
	if board.tiles_dict.has([Vector2i(row + 1, col - 1)]):
		nw = board.tiles_dict[Vector2i(row + 1, col - 1)]
	else:
		nw = null
	
	if board.tiles_dict.has([Vector2i(row - 1, col - 1)]):
		sw = board.tiles_dict[Vector2i(row - 1, col - 1)]
	else:
		sw = null

func update_adj_pawns():
	if ne != null and ne.pawn != null:
		ne.pawn.update_valid_moves()
	if nw != null and nw.pawn != null:
		nw.pawn.update_valid_moves()
	if se != null and se.pawn != null:
		se.pawn.update_valid_moves()
	if sw != null and sw.pawn != null:
		sw.pawn.update_valid_moves()
