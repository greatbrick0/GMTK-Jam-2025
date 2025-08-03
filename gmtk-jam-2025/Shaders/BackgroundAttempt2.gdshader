shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 background_color: source_color;
uniform int star_count : hint_range(1,2000) = 5;

uniform float seed = 1.0;

//yoink.
float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898 + seed, 78.233))) * 43758.5453);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 screen_pos = SCREEN_UV * VIEWPORT_SIZE;
	ALBEDO = background_color.rgb;

	for (int i = 0; i < star_count; i++) {
		vec2 star_pos = vec2(
			rand(vec2(float(i), seed)) * VIEWPORT_SIZE.x,
			rand(vec2(seed, float(i))) * VIEWPORT_SIZE.y
		);
	float dist = distance(screen_pos, star_pos); //compare star position to my position?
	if (dist < 2.0) {
		float brightness = 1.0 - dist / 2.0;
		ALBEDO += vec3(brightness);
	}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
