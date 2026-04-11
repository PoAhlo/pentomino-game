extends Resource
class_name PentominoData

@export var name: String = ""
# Coordinate for the texture in block_atlas.png
@export var atlas_coords: Vector2i = Vector2i(0, 0)
@export var coordinates: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0)
]
