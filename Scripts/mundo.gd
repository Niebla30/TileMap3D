extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#centrar_camara()
	$Terreno.generar_mapa()
	$Jugador.posicion_inicio()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func centrar_camara():
	var centro_logico = Vector2(Global.MAP_SIZE) / 2.0
	var centro_iso_x = (centro_logico.x - centro_logico.y) * Global.TILE_HALFSIZE.x
	var centro_iso_y = (centro_logico.x + centro_logico.y) * Global.TILE_HALFSIZE.y
	$Camera2D.global_position = Vector2(centro_iso_x, centro_iso_y)
