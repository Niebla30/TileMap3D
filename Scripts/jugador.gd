extends CharacterBody2D

@onready var anim_tree: AnimationTree = $AnimationTree

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var cell_actual: Vector2i = Vector2i(-1, -1) 
var altura: float
var hmap_size: Vector2i

func _ready() -> void:
	anim_tree.active = true
	hmap_size = Global.hmap_size()
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# 1. Obtener vector de entrada desde las acciones
	var input_vec = Input.get_vector("player_left", "player_right", "player_up", "player_down")
		
	if input_vec != Vector2.ZERO:
		# 2. Actualizar el BlendSpace2D con el vector de entrada (8 direcciones)
		anim_tree.set("parameters/blend_position", input_vec)
		anim_tree.active = true

		# 3. Conversión a espacio isométrico
		var direccion_iso = input_vec.normalized()
		direccion_iso.y *= 0.5 # Mantenemos la perspectiva de diamante
		velocity = direccion_iso * SPEED
				
		var cell: Vector2i = Global.world_to_hmap(global_position, altura)
		cell = Vector2i(clamp(cell.x, 0, hmap_size.x - 1), clamp(cell.y, 0, hmap_size.y - 1))		
		if cell != cell_actual:
			print(cell)
			cell_actual = cell
			altura = Global.hmap_get_height(cell)
			var world_pos = Global.hmap_to_world(cell)
			global_position.y = world_pos.y
			Global.celda_cambiada.emit(cell)
	else:
		# 4. Detener movimiento y pausar animación (al no tener Idle)
		velocity = Vector2.ZERO
		anim_tree.active = false

	move_and_slide()
	
func posicion_inicio():
	var celda_central: Vector2i = Global.hmap_size() * 0.5
	global_position = Global.hmap_to_world(celda_central)
	cell_actual = celda_central
	altura = Global.hmap_get_height(celda_central)
	
	#var celda_central: Vector2i = Global.MAP_SIZE * 0.5
	#var idTile = Global.grid_id(celda_central)
	#global_position = Global.pool[idTile].global_position
	#cell_actual = celda_central
	#altura =  Global.pool[idTile].height
