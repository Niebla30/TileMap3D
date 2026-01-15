shader_type canvas_item;

uniform int frame = 0; // Índices: 0 (Arriba-Izquierda), 1 (Arriba-Derecha), 2 (Abajo-Izquierda), 3 (Abajo-Derecha)
const float columnas = 6.0;
const float filas = 2.0;

void vertex() {
	// 1. Tamaño de un frame en espacio UV (0.5 en este caso)
	vec2 size = vec2(1.0 / columnas, 1.0 / filas);

	// 2. Calcular coordenadas de la celda en el spritesheet
	float f_col = mod(float(frame), columnas);
	float f_row = floor(float(frame) / columnas);

	// 3. Re-mapear las UVs al cuadrante correcto
	// Multiplicamos por size para encoger la textura y sumamos el offset para posicionarla
	UV = (UV * size) + vec2(f_col * size.x, f_row * size.y);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
