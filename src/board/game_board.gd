class_name GameBoard
extends Node2D
## Manages the 12x22 game board and tile data
##
## The GameBoard performs collision detection against boundaries and locked pieces, and handles
## the persistence of pieces once they have landed.

@onready var background_layer: TileMapLayer = $BackgroundLayer
@onready var locked_layer: TileMapLayer = $LockedPieceLayer

const GRID_WIDTH = 12
const GRID_HEIGHT = 22

## Check if a piece at position new_pos and coordinates new_coords is valid
func is_position_valid(new_pos: Vector2i, new_coords: Array[Vector2i]) -> bool:
	for mino in new_coords:
		var target: Vector2i = new_pos + mino
		
		# Bounds check, allowing for spilling on top
		if target.x < 0 or target.x >= 12 or target.y < -2 or target.y > 21:
			return false
		
		# Check if it collides with a locked piece
		if locked_layer.get_cell_source_id(target) != -1:
			return false
	
	return true

#TODO: lock_piece()
