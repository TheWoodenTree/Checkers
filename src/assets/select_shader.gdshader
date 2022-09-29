shader_type canvas_item;

uniform bool selected = false;
uniform float elapsedTime;

void vertex() {
	if (selected) {
		VERTEX.y += sin(elapsedTime * 4.0) * 6.0;
		//VERTEX.y += (sin(elapsedTime) + 1.0) * 0.0;
		//VERTEX.x += sin(elapsedTime * 4.0) * 6.0;
		//VERTEX.y += cos(4.0 * elapsedTime - PI / PI) * 6.0;
	}
}

//void fragment() {
	// Place fragment code here.
//}
