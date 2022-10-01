extends Node2D

const AIvsAI = 0
const PLAYERvsAI = 1
const PLAYERvsPLAYER = 2
const MOVE_TIME = 1

@onready var board = get_tree().root.get_node("board")
