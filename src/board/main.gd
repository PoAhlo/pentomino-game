extends Node2D

@export var active_data: PentominoData 
@onready var background_layer: TileMapLayer = $BackgroundLayer
@onready var active_layer: TileMapLayer = $ActivePieceLayer

var current_pos: Vector2i = Vector2i(5, 5)
var block_source_id: int = -1

func _ready() -> void:
	# Get TileSet from the active piece layer
	var ts = active_layer.tile_set
	# get id of first source, the atlas
	if ts.get_source_count() > 0:
		block_source_id = ts.get_source_id(0)
	
	if active_data:
		draw_piece(active_data, current_pos)
	else:
		print("!!! WARNING: No PentominoData assigned to Main node in the Inspector.")

func _input(event: InputEvent) -> void:
	# A quick test: Press 'Space' to rotate the piece in place
	if event.is_action_pressed("ui_accept"):
		rotate_piece_clockwise()

func draw_piece(data: PentominoData, pos: Vector2i) -> void:
	# Clear the layer so we don't leave a trail of old blocks
	active_layer.clear()
	
	if block_source_id == -1:
		print("TileSet not loaded properly")
		return
	
	for coord in data.coordinates:
		var target_grid_pos = pos + coord
		active_layer.set_cell(target_grid_pos, block_source_id, Vector2i(0, 0))

func rotate_piece_clockwise() -> void:
	# Traditional Tetris Matrix Rotation: (x, y) -> (-y, x)
	var rotated_coords: Array[Vector2i] = []
	for c in active_data.coordinates:
		rotated_coords.append(Vector2i(-c.y, c.x))
	
	# Update the coordinates in the resource and redraw
	active_data.coordinates = rotated_coords
	draw_piece(active_data, current_pos)
