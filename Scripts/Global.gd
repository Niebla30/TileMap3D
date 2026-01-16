extends Node

@warning_ignore("unused_signal")
signal celda_cambiada (pos: Vector2i)
signal solicitado_teletransporte(coord_mapa: Vector2i)

const MAP_SIZE: Vector2i = Vector2i(32, 32)
const MAP_HALFSIZE: Vector2i = MAP_SIZE * 0.5
const TILE_SIZE: Vector2i = Vector2i(192, 96)
const TILE_HALFSIZE: Vector2i = Vector2i(96, 48)
const TILE_VOLUME: int = 81
const TILE_OVERDRAW: int = 19

# Para el Atlas (Shader)
const ATLAS_LAYOUT: Vector2i = Vector2i(2, 6) #2 filas,6 columnas
const HEIGHT_SCALE: float = 1500.0

#Referencia a los tiles y al heightmap
var pool: Array[Node2D]
var hmap_image: Image


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func world_to_grid(world_pos: Vector2, altura: float) -> Vector2i: 
	var pos_plana_y = world_pos.y + altura
	var x_norm = world_pos.x / TILE_SIZE.x
	var y_norm = pos_plana_y / TILE_SIZE.y

	var gx = x_norm + y_norm 
	var gy = y_norm - x_norm 
	
	#El 0.5 se usa para evitar errores por redondeo
	return Vector2i(floor(gx + 0.5), floor(gy + 0.5))

#Coordenadas de mundo a celda del heightmap
func world_to_hmap(world_pos: Vector2, altura: float) -> Vector2i:
	var pos_plana_y = world_pos.y + altura
	
	var i_rel = world_pos.x / TILE_SIZE.x + pos_plana_y / TILE_SIZE.y
	var j_rel = pos_plana_y / TILE_SIZE.y - world_pos.x / TILE_SIZE.x
	
	var centro_mapa: Vector2i = hmap_center()
	
	return Vector2i(floor(i_rel + 0.5) + centro_mapa.x, floor(j_rel + 0.5) + centro_mapa.y)

#Celda del heightmap a coordenadas de mundo
func hmap_to_world(map_pos: Vector2i) -> Vector2:
	var centro = hmap_center()
	var rel_x = float(map_pos.x - centro.x)
	var rel_y = float(map_pos.y - centro.y)

	var world_x = (rel_x - rel_y) * TILE_HALFSIZE.x
	var world_y = (rel_x + rel_y) * TILE_HALFSIZE.y
	
	var h_value = hmap_get_height(map_pos)
	
	return Vector2(world_x, world_y - h_value)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	# Esta es la función inversa para colocar objetos en el mundo
	return Vector2((grid_pos.x - grid_pos.y) * TILE_HALFSIZE.x, (grid_pos.x + grid_pos.y) * TILE_HALFSIZE.y)
		
func grid_id(grid_pos: Vector2i) -> int:
	return grid_pos.x * MAP_SIZE.x + grid_pos.y
	
func hmap_center() -> Vector2i:
	var offset: Vector2i
	var map_size = hmap_image.get_size()
	offset = (map_size - MAP_SIZE) * 0.5
	return offset
	
func hmap_size() -> Vector2i:
	return hmap_image.get_size()

#Devuelve la altura del pixel del hmap, ya escalada
func hmap_get_height(cell: Vector2i) -> float:
	return hmap_image.get_pixel(cell.x, cell.y).r * HEIGHT_SCALE

#Devuelve la altura sin escalar (para el shader unicamente)
func hmap_get_height_normalized(cell: Vector2i) -> float:
	return hmap_image.get_pixel(cell.x, cell.y).r
