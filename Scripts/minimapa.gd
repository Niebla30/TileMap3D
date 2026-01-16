extends Control

@onready var minimap_tex = $Panel/TextureRect
@onready var player_marker = $Panel/TextureRect/ColorRect

var hmap_size: Vector2i
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.celda_cambiada.connect(on_player_moved)
	hmap_size = Global.hmap_size()
	on_player_moved(Global.hmap_center())
	
func on_player_moved(pos: Vector2i):
	var rel_x = float(pos.x) / hmap_size.x
	var rel_y = float(pos.y) / hmap_size.y

	var minimap_size = minimap_tex.size
	player_marker.position = Vector2(rel_x * minimap_size.x, rel_y * minimap_size.y)
	player_marker.position -= player_marker.size / 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position
		#var texture_size = size # El tamaño visual del minimapa en pantalla
		
		# 1. Calculamos la proporción (0.0 a 1.0)
		var rel_x = click_pos.x / minimap_tex.size.x
		var rel_y = click_pos.y / minimap_tex.size.y
		
		# 2. Traducimos a coordenadas reales del Heightmap (0 a 255)
		var target_map_pos = Vector2i(
			int(rel_x * hmap_size.x),
			int(rel_y * hmap_size.y)
		)
		
		# 3. Emitimos una señal global de teletransporte
		Global.solicitado_teletransporte.emit(target_map_pos)
