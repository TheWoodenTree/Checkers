extends Node2D
class_name Board

const P1_TURN: int = 0
const P2_TURN: int = 1
const BOARD_SIZE: int = 1024
@warning_ignore(integer_division)
const TILE_SIZE: int = BOARD_SIZE / 8

var tiles: Array
var tiles_dict: Dictionary
var white_pawns: Array
var black_pawns: Array

var turn = P1_TURN

var last_selected_pawn: Pawn = null
var selected_pawn: Pawn = null

var pawn_preload = preload("res://src/actors/pawn.tscn")

@onready var ai = $ai

@export var mode: int = Global.AIvsAI

signal turn_ended


class Tile:
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


func _ready():
	_generate_board()
	#ai.connect("turn_ended", switch_turns)
	self.connect("turn_ended", switch_turns)


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		ai.think(1, null)


func switch_turns():
	if turn == P1_TURN:
		turn = P2_TURN
	else:
		turn = P1_TURN


func _generate_board():
	for row in range(1, 9):
		for col in range(1, 9):
			var new_tile = Tile.new(9 - row, col, self)
			tiles.append(new_tile)
			tiles_dict[Vector2i(9 - row, col)] = new_tile
	
	for tile in tiles:
		for tile2 in tiles:
			if tile2.is_row_col(tile.row + 1, tile.col + 1):
				tile.ne = tile2
			elif tile2.is_row_col(tile.row + 1, tile.col - 1):
				tile.nw = tile2
			elif tile2.is_row_col(tile.row - 1, tile.col - 1):
				tile.sw = tile2
			elif tile2.is_row_col(tile.row - 1, tile.col + 1):
				tile.se = tile2
	
	_place_pawns()


func _place_pawns():
	for tile in tiles:
		var row = tile.row
		var col = tile.col
		
		if row != 4 and row != 5 and (row + col) % 2 != 0:
			#await get_tree().create_timer(0.1).timeout
			var pawn = pawn_preload.instantiate()
			if row >= 6:
				pawn.get_node("sprite").modulate = Color.ORANGE_RED
				pawn.color = "black"
				black_pawns.append(pawn)
			else:
				pawn.get_node("sprite").modulate = Color.WHITE
				pawn.color = "white"
				white_pawns.append(pawn)
			tile.pawn = pawn
			pawn.init(tile)
			add_child(pawn)
	update_pawns()


func update_pawns():
	for pawn in white_pawns:
		pawn.update_valid_moves()
	for pawn in black_pawns:
		pawn.update_valid_moves()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and turn == P1_TURN:
			var pos = event.position
			for tile in tiles:
				if tile.rect.has_point(pos):
					if tile.has_pawn() and tile.pawn.color == "white" and not tile.pawn.selected:
						selected_pawn = tile.pawn
						if selected_pawn != last_selected_pawn and last_selected_pawn != null:
							last_selected_pawn.set_selected(false)
						last_selected_pawn = selected_pawn
						selected_pawn.set_selected(true)
						break
					elif not tile.has_pawn() and selected_pawn != null:
						if tile in selected_pawn.valid_move_tiles:
							selected_pawn.move(tile)
							if not selected_pawn.just_captured or \
							selected_pawn.just_captured and not selected_pawn.can_capture:
								await get_tree().create_timer(Global.MOVE_TIME).timeout
								emit_signal("turn_ended")
								selected_pawn.set_selected(false)
								selected_pawn.just_captured = false
								selected_pawn = null
								last_selected_pawn = null
						else:
							selected_pawn.shake()
		
		# Deselect pawn with right click
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if selected_pawn != null:
				selected_pawn.set_selected(false)
				selected_pawn = null
				last_selected_pawn = null


func start_game():
	pass
