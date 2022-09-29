extends Node2D

const BOARD_SIZE: int = 1024
const TILE_SIZE: int = 1024 / 8

var tiles: Array
var white_pawns: Array
var black_pawns: Array

var last_selected_pawn: Pawn = null
var selected_pawn: Pawn = null

var pawn_preload = preload("res://src/actors/pawn.tscn")


class Tile:
	var row: int
	var col: int
	var pos: Vector2
	var title: String
	var pawn: Pawn
	var rect: Rect2
	var highlight: ColorRect
	var selected: bool
	
	func _init(r, c):
		row = 9 - r
		col = c
		pos.x = col * TILE_SIZE - TILE_SIZE / 2.0
		pos.y = (9 - row) * TILE_SIZE - TILE_SIZE / 2.0
		title = char(col + 96) + "%d" % row
		pawn = null
		selected = false
		
		var rect_pos = Vector2((col - 1) * TILE_SIZE, ((9 - row) - 1) * TILE_SIZE)
		var rect_size = Vector2(TILE_SIZE, TILE_SIZE)
		rect = Rect2(rect_pos, rect_size)
	
	func has_pawn():
		return pawn != null
	
	func is_selected():
		return selected
	
	func is_col_row(r, c):
		return row == r and col == c


func _ready():
	_generate_board()


func _process(_delta):
	pass


func _generate_board():
	for row in range(1, 9):
		for col in range(1, 9):
			tiles.append(Tile.new(row, col))
	
	_place_pawns()


func _place_pawns():
	for tile in tiles:
		var row = tile.row
		var col = tile.col
		
		if row != 4 and row != 5 and (row + col) % 2 != 0:
			#await get_tree().create_timer(0.1).timeout
			var pawn = pawn_preload.instantiate()
			pawn.position = tile.pos
			if row >= 6:
				pawn.get_node("sprite").modulate = Color.ORANGE_RED
				pawn.color = "black"
				black_pawns.append(pawn)
			else:
				pawn.get_node("sprite").modulate = Color.WHITE
				pawn.color = "white"
				white_pawns.append(pawn)
			tile.pawn = pawn
			add_child(pawn)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var pos = event.position
			var pawn_found = false
			for tile in tiles:
				# Check to see which tile is selected, check to see if it has a
				# pawn on it, check to see if that pawn is white, and check to 
				# see if that pawn is not already selected
				if tile.rect.has_point(pos) and tile.has_pawn() and \
				tile.pawn.color == "white" and not tile.pawn.selected:
					selected_pawn = tile.pawn
					# If a different pawn is selected, deselect last pawn
					if selected_pawn != last_selected_pawn and last_selected_pawn != null:
						last_selected_pawn.set_selected(false)
					last_selected_pawn = selected_pawn
					selected_pawn.set_selected(true)
					pawn_found = true
					print(tile.title + ": " + str(tile.row) + ", " + str(tile.col))
					break
			if not pawn_found and selected_pawn != null:
				selected_pawn.set_selected(false)
				selected_pawn = null

func start_game():
	pass
