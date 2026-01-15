extends Node2D

@export var height_map_tex: Texture2D
@onready var tile_scene = preload("res://Scenes/tile.tscn")

var height_map_image: Image

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.celda_cambiada.connect(_on_celda_cambiada)
	height_map_image = height_map_tex.get_image()

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func generar_mapa():
	var cont: int = 0
	var centro_hmap: Vector2i = centro_heightmap()
	
	var offset_mapa: Vector2i = Vector2(0, 0) #para cambiar la zona del mapa que se muestra al inicio
	
	for i in range(Global.MAP_SIZE.x):
		for j in range(Global.MAP_SIZE.y):
			var tile = tile_scene.instantiate()
			add_child(tile)
			
			var iso_x = (i - j) * Global.TILE_HALFSIZE.x
			var iso_y = (i + j) * Global.TILE_HALFSIZE.y
						
			var h_value = height_map_image.get_pixel(centro_hmap.x + offset_mapa.x + i, centro_hmap.y + offset_mapa.y + j).r
			tile.global_position = Vector2(iso_x, iso_y - (h_value * Global.HEIGHT_SCALE))
			tile.pos_heightmap = Vector2i (centro_hmap.x + i, centro_hmap.y + j)
			tile.pos_grid = Vector2i(i,j)
			tile.id = cont
			tile.height = h_value * Global.HEIGHT_SCALE
			cont += 1
						
			#Se puede poner el tipo de material dependiendo de la altura, después
			var mat = tile.get_node("TileMesh").material as ShaderMaterial
			if h_value < 0.25:
				mat.set_shader_parameter("frame", 0)
			elif h_value < 0.5:
				mat.set_shader_parameter("frame", 1)
			elif h_value < 0.75:
				mat.set_shader_parameter("frame", 2)
			elif h_value <= 1.0:
				mat.set_shader_parameter("frame", 3)
			
			if i == Global.MAP_HALFSIZE.x and j == Global.MAP_HALFSIZE.y:
				mat.set_shader_parameter("frame", 3)
			
			Global.pool.push_back(tile)

func centro_heightmap() -> Vector2i:
	var offset: Vector2i
	var map_size = height_map_image.get_size()	
	offset = (map_size - Global.MAP_SIZE) * 0.5
	print (offset)
	return offset

func _on_celda_cambiada(pos: Vector2i):
	comprobar_grid(pos)

#Esto es idea de la AI para hacer los saltos de tiles
func comprobar_grid(pos_jugador: Vector2i): #se puede hacer por señal al cambiar el jugador de celda
	
	var idTile: int = Global.grid_id(pos_jugador)
	var pos_heightmap_jugador: Vector2i = Global.pool[idTile].pos_heightmap
	   
	for tile in Global.pool:
		# 1. Calculamos la distancia lógica entre el tile y el jugador (sobre el heightmap)
		var diff: Vector2i = tile.pos_heightmap - pos_heightmap_jugador
		
		# 2. Si el tile se aleja más de la mitad de la grid, lo mandamos al lado opuesto
		var salto_realizado = false
		
		if diff.x > Global.MAP_HALFSIZE.x:
			tile.pos_heightmap.x -= Global.MAP_SIZE.x
			salto_realizado = true
		elif diff.x < -Global.MAP_HALFSIZE.x:
			tile.pos_heightmap.x += Global.MAP_SIZE.x
			salto_realizado = true
			
		if diff.y > Global.MAP_HALFSIZE.y:
			tile.pos_heightmap.y -= Global.MAP_SIZE.y
			salto_realizado = true
		elif diff.y < -Global.MAP_HALFSIZE.y:
			tile.pos_heightmap.y += Global.MAP_SIZE.y
			salto_realizado = true
			
		# 3. Solo si el tile ha "saltado", actualizamos su posición física y arte
		if salto_realizado:
			actualizar_identidad(tile)

func actualizar_identidad(tile: Node2D):
	var indice_relativo = tile.pos_heightmap - centro_heightmap()
	var iso_x = (indice_relativo.x - indice_relativo.y) * Global.TILE_HALFSIZE.x
	var iso_y = (indice_relativo.x + indice_relativo.y) * Global.TILE_HALFSIZE.y
	var h_value = height_map_image.get_pixel(tile.pos_heightmap.x, tile.pos_heightmap.y).r
	
	tile.global_position = Vector2(iso_x, iso_y - (h_value * Global.HEIGHT_SCALE))
	tile.height =  h_value * Global.HEIGHT_SCALE
	
	var mat = tile.get_node("TileMesh").material as ShaderMaterial
	if h_value < 0.25:
		mat.set_shader_parameter("frame", 0)
	elif h_value < 0.5:
		mat.set_shader_parameter("frame", 1)
	elif h_value < 0.75:
		mat.set_shader_parameter("frame", 2)
	elif h_value <= 1.0:
		mat.set_shader_parameter("frame", 3)
	
	print("Muevo la celda ", tile.pos_grid, " que ahora muestra ", tile.pos_heightmap)
