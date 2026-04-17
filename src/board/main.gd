extends Node2D

@export var library: PentominoLibrary

## Delayed Auto Shift: How long to hold before a piece starts auto-sliding
@export var DAS_S: float = 0.18
## Auto Repeat Rate: Time before piece auto-slides
@export var ARR_S: float = 0.04
## Soft Drop Multiplier: How much faster than current gravity does soft drop move down
@export var SOFT_DROP_MULT: float = 15.0
# how fast a piece falls
@export var gravity_interval_s: float = 1.0

@onready var background_layer: TileMapLayer = $BackgroundLayer
@onready var locked_layer: TileMapLayer = $LockedPieceLayer
@onready var active_layer: TileMapLayer = $ActivePieceLayer

var active_piece_index: int = -1
var active_piece_data: PentominoData
var curr_pos: Vector2i = Vector2i(6, 1)
var block_source_id: int = -1

var gravity_timer: float = 0.0
var move_timer: float = 0.0
var last_input_dir: Vector2i = Vector2i.ZERO

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
		draw_active_piece()
	else:
		print("!!! WARNING: No PentominoData assigned to Main node in the Inspector.")

func _input(event: InputEvent) -> void:
	# rotating
	if event.is_action_pressed("rotate_clockwise"):
		print("rotate_clockwise")
		#rotate_piece_clockwise()
	if event.is_action_pressed("rotate_counterclockwise"):
		print("rotate_counterclockwise")
	
	# moving
	if event.is_action_pressed("soft_drop"):
		move_active_piece(Vector2i.DOWN)
		gravity_timer = 0.0
	
	# For piece swapping
	if event.is_action_pressed("ui_focus_next"):
		change_piece(1)
	if event.is_action_pressed("ui_focus_prev"):
		change_piece(-1)

func _process(delta: float) -> void:
	handle_horizontal_input(delta)
	handle_gravity(delta)

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
		move_active_piece(curr_dir) # initial input change immediately moves piece
		last_input_dir = curr_dir
		move_timer = DAS_S
	else: # direction being held
		move_timer -= delta
		if move_timer <= 0:
			move_active_piece(curr_dir)
			move_timer = ARR_S

func handle_gravity(delta: float) -> void:
	# current speed
	var curr_interval_s = gravity_interval_s
	
	# If holding down, make the interval shorter
	if Input.is_action_pressed("soft_drop"):
		curr_interval_s /= SOFT_DROP_MULT
	
	gravity_timer -= delta
	
	if gravity_timer <= 0:
		gravity_timer = curr_interval_s
		move_active_piece(Vector2i.DOWN)


func draw_active_piece() -> void:
	# Clear the layer so we don't leave a trail of old blocks
	active_layer.clear()
	
	if block_source_id == -1:
		print("TileSet not loaded properly")
		return
	
	for coord in active_piece_data.coordinates:
		var target_grid_pos = curr_pos + coord
		active_layer.set_cell(target_grid_pos, block_source_id, active_piece_data.atlas_coords)

#func rotate_piece_clockwise() -> void:
	## Coodinate Rotation: (x, y) -> (-y, x)
	#var rotated_coords: Array[Vector2i] = []
	#for c in active_piece_data.coordinates:
		#rotated_coords.append(Vector2i(-c.y, c.x))
	#
	## Update the coordinates in the resource and redraw
	#active_piece_data.coordinates = rotated_coords
	#draw_piece(active_piece_data, curr_pos)

func change_piece(direction: int) -> void:
	# update position
	curr_pos = Vector2i(6, 1)
	
	# update index
	active_piece_index = posmod(active_piece_index + direction, library.pieces.size())
	active_piece_data = library.pieces[active_piece_index]
	
	draw_active_piece()

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

func move_active_piece(direction: Vector2i) -> bool:
	var next_pos = curr_pos + direction
	
	if is_position_valid(next_pos, active_piece_data.coordinates):
		curr_pos = next_pos
		draw_active_piece()
		return true # success
	
	return false
