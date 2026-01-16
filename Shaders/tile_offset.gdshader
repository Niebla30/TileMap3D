shader_type canvas_item;

void vertex() {
    UV.y = 1.0 - UV.y; //para invertir la textura
}
