shader_type spatial;
render_mode unshaded;

uniform vec4 baseColor;
uniform float opacity;
uniform sampler2D TexA;

varying vec4 color;

void vertex() {
	
	color = INSTANCE_CUSTOM;
}

void fragment() {
	ALBEDO = color.rgb * texture(TexA, UV).rgb;
	ALPHA = texture(TexA, UV).r * 1.0 - color.y;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
