extends Node
## Central hub of game logic
##
## This script manages the game state, spawns new pieces, and facilitates communication between
## the GameBoard and PieceController.

@export var test_lib: PentominoLibrary

@onready var board = $Board
@onready var controller = $PieceController

var test_lib_idx = 0

func _ready() -> void:
	controller.board_ref = board
	spawn_piece_by_idx(test_lib_idx)

func _input(event: InputEvent) -> void:
	# For piece swapping
	if event.is_action_pressed("ui_focus_next"):
		test_lib_idx = posmod(test_lib_idx + 1, test_lib.pieces.size())
		spawn_piece_by_idx(test_lib_idx)
	if event.is_action_pressed("ui_focus_prev"):
		test_lib_idx = posmod(test_lib_idx - 1, test_lib.pieces.size())
		spawn_piece_by_idx(test_lib_idx)

# TODO: add logic NOT based on test library
func spawn_piece_by_idx(idx: int) -> void:
	var active_piece_copy = test_lib.pieces[idx].duplicate()
	
	controller.piece_data = active_piece_copy
	controller.reset()
	
	print("Testing Piece: ", active_piece_copy.name)
