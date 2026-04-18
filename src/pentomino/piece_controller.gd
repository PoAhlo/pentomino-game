class_name PieceController
extends Node
## Handles the movement, rotation and input for the active piece
##
## This script managed the current Pentomino. It processes player input, applies gravity, and
## calculates spatial transformations. It relies on GameBoard to validate proposed movements.

@onready var active_layer: TileMapLayer = $ActivePieceLayer

# References set by Main
var board_ref: GameBoard
var piece_data: PentominoData

# Settings
## Delayed Auto Shift: How long to hold before a piece starts auto-sliding
@export var das_s: float = 0.18
## Auto Repeat Rate: Time before piece auto-slides
@export var arr_s: float = 0.04
## Soft Drop Multiplier: How much faster than current gravity does soft drop move down
@export var soft_drop_mult: float = 15.0
## Gravity Inverval: how fast a piece falls 
@export var gravity_interval_s: float = 1.0  # TODO: Speed up over time

var atlas_source_id: int = -1

# State
var curr_pos: Vector2i
var gravity_timer: float = 0.0
var move_timer: float = 0.0
var last_input_dir: Vector2i = Vector2i.ZERO

func _ready() -> void:
	# Get TileSet from the active piece layer
	var ts = active_layer.tile_set
	# get id of first source, the atlas
	if ts.get_source_count() > 0:
		atlas_source_id = ts.get_source_id(0)
	
	if piece_data:
		draw()

func _input(event: InputEvent) -> void:
	# rotating
	if event.is_action_pressed("rotate_clockwise"):
		print("rotate_clockwise")
		#rotate_piece_clockwise()
	if event.is_action_pressed("rotate_counterclockwise"):
		print("rotate_counterclockwise")
	
	# moving
	if event.is_action_pressed("soft_drop"):
		attempt_move(Vector2i.DOWN)
		gravity_timer = gravity_interval_s / soft_drop_mult

func _process(delta: float) -> void:
	handle_horizontal_input(delta)
	handle_gravity(delta)

## Handles input, allowing for auto-sliding after delay
func handle_horizontal_input(delta: float) -> void:
	var curr_dir = Vector2i.ZERO
	
	# Determine direction
	if Input.is_action_pressed("move_left"):
		curr_dir = Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		curr_dir = Vector2i.RIGHT
	
	# If direction is still 0, nothing is being inputted.  Reset
	if curr_dir == Vector2i.ZERO:
		last_input_dir = Vector2i.ZERO
		move_timer = 0.0
		return
	
	# new direction or change in direction
	if curr_dir != last_input_dir:
		attempt_move(curr_dir) # initial input change immediately moves piece
		last_input_dir = curr_dir
		move_timer = das_s
	else: # direction being held
		move_timer -= delta
		if move_timer <= 0:
			attempt_move(curr_dir)
			move_timer = arr_s

## Moves piece downward using gravity_timer
func handle_gravity(delta: float) -> void:
	# current speed
	var curr_interval_s = gravity_interval_s
	
	# If holding down, make the interval shorter
	if Input.is_action_pressed("soft_drop"):
		curr_interval_s /= soft_drop_mult
	else:
		curr_interval_s = gravity_interval_s
	
	gravity_timer -= delta
	
	if gravity_timer <= 0:
		gravity_timer = curr_interval_s
		attempt_move(Vector2i.DOWN)

## Attempt to move the piece in the given direction, returns true if success, otherwise false
func attempt_move(direction: Vector2i) -> bool:
	var next_pos = curr_pos + direction
	
	if board_ref.is_position_valid(next_pos, piece_data.coordinates):
		curr_pos = next_pos
		draw()
		return true # success
	
	return false

# TODO: rotate()

## Draw the active piece
func draw() -> void:
	# Clear the layer so we don't leave a trail of old blocks
	active_layer.clear()
	
	if atlas_source_id == -1:
		print("TileSet not loaded properly")
		return
	
	for coord in piece_data.coordinates:
		var target_grid_pos = curr_pos + coord
		active_layer.set_cell(target_grid_pos, atlas_source_id, piece_data.atlas_coords)

## Reset the piece location and timers
func reset() -> void:
	# set to top middle
	curr_pos = Vector2i(6, 1)
	
	# reset timers
	move_timer = 0.0
	gravity_timer = gravity_interval_s
	
	draw()
