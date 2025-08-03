shader_type spatial;
render_mode unshaded;

uniform vec4 baseColor;
uniform float opacity;
uniform sampler2D TexA;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	EMISSION = baseColor.rgb * texture(TexA, UV).rgb;
	ALPHA = opacity * texture(TexA, UV).r;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
