shader_type spatial;
render_mode unshaded;

uniform vec4 baseColor;
uniform float opacity;

uniform float timeMod;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = baseColor.rgb;
	ALPHA = baseColor.a * opacity * UV.y;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
