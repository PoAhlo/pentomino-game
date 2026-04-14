extends Node2D

@export var library: PentominoLibrary

@onready var background_layer: TileMapLayer = $BackgroundLayer
@onready var active_layer: TileMapLayer = $ActivePieceLayer

var active_piece_index: int = -1
var active_piece_data: PentominoData
var curr_pos: Vector2i = Vector2i(6, 3)
var block_source_id: int = -1

func _ready() -> void:
	# Get TileSet from the active piece layer
	var ts = active_layer.tile_set
	# get id of first source, the atlas
	if ts.get_source_count() > 0:
		block_source_id = ts.get_source_id(0)
	
	if library.pieces.size() > 0:
		active_piece_index = 0
		active_piece_data = library.pieces[active_piece_index]
	
	if active_piece_data:
		draw_piece(active_piece_data, curr_pos)
	else:
		print("!!! WARNING: No PentominoData assigned to Main node in the Inspector.")

func _input(event: InputEvent) -> void:
	# A quick test: Press 'Space' to rotate the piece in place
	if event.is_action_pressed("rotate_clockwise"):
		rotate_piece_clockwise()
	elif event.is_action_pressed("ui_focus_next"):
		change_piece(1)
	elif event.is_action_pressed("ui_focus_prev"):
		change_piece(-1)

func draw_piece(data: PentominoData, pos: Vector2i) -> void:
	# Clear the layer so we don't leave a trail of old blocks
	active_layer.clear()
	
	if block_source_id == -1:
		print("TileSet not loaded properly")
		return
	
	for coord in data.coordinates:
		var target_grid_pos = pos + coord
		active_layer.set_cell(target_grid_pos, block_source_id, data.atlas_coords)

func rotate_piece_clockwise() -> void:
	# Coodinate Rotation: (x, y) -> (-y, x)
	var rotated_coords: Array[Vector2i] = []
	for c in active_piece_data.coordinates:
		rotated_coords.append(Vector2i(-c.y, c.x))
	
	# Update the coordinates in the resource and redraw
	active_piece_data.coordinates = rotated_coords
	draw_piece(active_piece_data, curr_pos)

func change_piece(direction: int) -> void:
	# update position
	curr_pos = Vector2i(6, 3)
	
	# update index
	active_piece_index = posmod(active_piece_index + direction, library.pieces.size())
	active_piece_data = library.pieces[active_piece_index]
	
	draw_piece(active_piece_data, curr_pos)

func is_pos_valid(test_coords: Array[Vector2i]) -> bool:
	for mino in test_coords:
		var mino_pos = test_pos + mino
		
		
