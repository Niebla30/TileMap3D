extends Node2D

@export var height_map_tex: Texture2D
@onready var tile_scene = preload("res://Scenes/tile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.celda_cambiada.connect(_on_celda_cambiada)
	Global.hmap_image = height_map_tex.get_image()
	#calcula_alturas()

#Para saber las alturas mínima y máxima del height_map
func calcula_alturas(): 
	var maxh: float = 0.0
	var minh: float = 3.0
	for i in Global.hmap_image.get_size().x:
		for j in Global.hmap_image.get_size().y:
			var h_value = Global.hmap_image.get_pixel(i, j).r
			if maxh < h_value:
				maxh = h_value
			if minh > h_value:
				minh = h_value
	print("Maximos: ", maxh, " - ", minh)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func generar_mapa():
	var cont: int = 0
	var centro_hmap: Vector2i = Global.hmap_center()
	
	var offset_mapa: Vector2i = Vector2(0, 0) #para cambiar la zona del mapa que se muestra al inicio
	
	for i in range(Global.MAP_SIZE.x):
		for j in range(Global.MAP_SIZE.y):
			var tile = tile_scene.instantiate()
			add_child(tile)
			
			var iso_x = (i - j) * Global.TILE_HALFSIZE.x
			var iso_y = (i + j) * Global.TILE_HALFSIZE.y
			
			var cell = Vector2i(centro_hmap.x + offset_mapa.x + i, centro_hmap.y + offset_mapa.y + j)
			var h_value = Global.hmap_get_height(cell)
			
			tile.global_position = Vector2(iso_x, iso_y - h_value)
			tile.pos_heightmap = Vector2i (centro_hmap.x + i, centro_hmap.y + j)
			tile.pos_grid = Vector2i(i,j)
			tile.id = cont
			tile.height = h_value
			cont += 1

			var h_value_normalized = Global.hmap_get_height_normalized(cell)						
			asignar_shader(h_value_normalized, tile)
			
			#if i == 16 and j == 16:
			#	asignar_shader(0.6, tile)
				
			Global.pool.push_back(tile)

func _on_celda_cambiada(pos: Vector2i):
	comprobar_grid(pos)

#Esto es idea de la AI para hacer los saltos de tiles
func comprobar_grid(pos_jugador: Vector2i): #se puede hacer por señal al cambiar el jugador de celda
	
	#var idTile: int = Global.grid_id(pos_jugador)
	var pos_heightmap_jugador: Vector2i = pos_jugador #Global.pool[idTile].pos_heightmap
	   
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
	var indice_relativo = tile.pos_heightmap - Global.hmap_center()
	var iso_x = (indice_relativo.x - indice_relativo.y) * Global.TILE_HALFSIZE.x
	var iso_y = (indice_relativo.x + indice_relativo.y) * Global.TILE_HALFSIZE.y
	var h_value = Global.hmap_get_height(tile.pos_heightmap)
		
	tile.global_position = Vector2(iso_x, iso_y - (h_value))
	tile.height =  h_value
	
	var h_value_normalized = Global.hmap_get_height_normalized(tile.pos_heightmap)
	asignar_shader(h_value_normalized, tile)
	
func asignar_shader(altura: float, tile: Node2D):
	var mat = tile.get_node("TileMesh").material as ShaderMaterial
	tile.get_node("TileWater").visible = false
	if altura < 0.02:
		mat.set_shader_parameter("frame", 5)
		tile.get_node("TileWater").position.y = tile.height - 0.02
		tile.get_node("TileWater").visible = true
	elif altura < 0.08:
		mat.set_shader_parameter("frame", 5)
	elif altura < 0.16:
		mat.set_shader_parameter("frame", 4)
	elif altura < 0.24:
		mat.set_shader_parameter("frame", 3)
	elif altura < 0.32:
		mat.set_shader_parameter("frame", 2)
	elif altura < 0.40:
		mat.set_shader_parameter("frame", 0)
	elif altura < 0.48:
		mat.set_shader_parameter("frame", 7)
	elif altura < 0.60:
		mat.set_shader_parameter("frame", 1)
	elif altura < 0.68:
		mat.set_shader_parameter("frame", 9)
	elif altura < 0.76:
		mat.set_shader_parameter("frame", 11)
	elif altura < 0.84:
		mat.set_shader_parameter("frame", 10)	
	elif altura < 0.92:
		mat.set_shader_parameter("frame", 8)
	elif altura <= 1.00:
		mat.set_shader_parameter("frame", 6)
	
