shader_type canvas_item;

uniform bool selected = false;
uniform float elapsedTime;
uniform float shakeScale = 0.0;
uniform float floatScale = 0.0;

void vertex() {
	if (selected) {
		VERTEX.y += sin(elapsedTime * 4.0) * 6.0;
	}
	
	if (floatScale > 0.001) {
		VERTEX.y += sin(elapsedTime * 4.0) * floatScale;
	}
	
	if (shakeScale > 0.001) {
		VERTEX.x += sin(TIME * 20.0) * shakeScale;
	}
}

//void fragment() {
	// Place fragment code here.
//}
