class_name PentominoData
extends Resource
## Custom resource class to hold information related to each Pentomino

@export var name: String = ""
@export var atlas_coords: Vector2i = Vector2i(0, 0) # Coordinate for the texture in block_atlas.png
@export var coordinates: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0)
]
