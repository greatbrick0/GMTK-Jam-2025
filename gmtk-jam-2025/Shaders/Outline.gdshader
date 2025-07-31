shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec4 color: source_color = vec4(0,0,0,1);
uniform float size: hint_range(1.0,1.5,0.01) = 1.03;


void vertex() {
	VERTEX *= size;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color.rgb;
	ALPHA = color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
