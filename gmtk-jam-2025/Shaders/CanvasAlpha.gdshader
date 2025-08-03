shader_type canvas_item;
render_mode unshaded;

uniform vec4 baseColor;
uniform float opacity;
uniform sampler2D TexA;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = texture(TexA, UV);
	COLOR= vec4(tex.rgb * baseColor.rgb, opacity * tex.r);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
