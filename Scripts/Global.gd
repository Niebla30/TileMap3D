extends Node

signal celda_cambiada (pos: Vector2i)

const MAP_SIZE: Vector2i = Vector2i(32, 32)
const MAP_HALFSIZE: Vector2i = MAP_SIZE * 0.5
const TILE_SIZE: Vector2i = Vector2i(192, 96)
const TILE_HALFSIZE: Vector2i = Vector2i(96, 48)
const TILE_VOLUME: int = 81
const TILE_OVERDRAW: int = 19
# Para el Atlas (Shader)
const ATLAS_LAYOUT: Vector2i = Vector2i(2, 2) # 2 columnas, 2 filas
const HEIGHT_SCALE: float = 1500.0

var pool: Array[Node2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func world_to_grid(world_pos: Vector2) -> Vector2i:
	# 1. Normalizamos la posición respecto al tamaño del medio tile
	# TILE_HALF es Vector2(40, 20) si tu tile es 80x40
	var x_norm = world_pos.x / TILE_HALFSIZE.x
	var y_norm = world_pos.y / TILE_HALFSIZE.y
	
	# 2. Aplicamos la rotación inversa de 45 grados y escala
	# La fórmula matemática para diamante 2:1 es:
	# grid_x = (x / half_w + y / half_h) / 2
	# grid_y = (y / half_h - x / half_w) / 2
	var gx = (x_norm + y_norm) * 0.5
	var gy = (y_norm - x_norm) * 0.5
	
	# 3. Usamos floor para obtener el índice entero de la celda
	return Vector2i(floor(gx), floor(gy))
	
func world_to_grid_corregido(world_pos: Vector2, altura: float) -> Vector2i:
	var pos_plana_y = world_pos.y + altura
	var x_norm = world_pos.x / TILE_SIZE.x
	var y_norm = pos_plana_y / TILE_SIZE.y
	var gx = x_norm + y_norm
	var gy = y_norm - x_norm
	
	return Vector2i(floor(gx + 0.5), floor(gy + 0.5))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	# Esta es la función inversa para colocar objetos en el mundo
	return Vector2((grid_pos.x - grid_pos.y) * TILE_HALFSIZE.x, (grid_pos.x + grid_pos.y) * TILE_HALFSIZE.y)
		
func grid_id(grid_pos: Vector2i) -> int:
	return grid_pos.x * MAP_SIZE.x + grid_pos.y
	
