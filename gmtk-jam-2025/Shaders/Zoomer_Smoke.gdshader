shader_type spatial;
render_mode unshaded;

uniform vec4 albedo: source_color;
uniform sampler2D texture_albedo;

uniform sampler2D erosion;


uniform float erosion_progress = 1;

varying float lifetime;

void vertex() {
	// Called for every vertex the material is visible on.
	 lifetime = INSTANCE_CUSTOM.y;
	
}

void fragment() {
	
	
	// Called for every pixel the material is visible on.
	vec4 albedo_tex = texture(texture_albedo, vec2(lifetime,0.0));
	
	ALBEDO  = albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
	
	//sample erosion texture
	vec4 erosion_tex = texture(erosion, UV);
	
	
	float erosion_val =  smoothstep(0,erosion_tex.r,smoothstep(0,erosion_tex.r,smoothstep(0,  erosion_tex.r, 1.0 - lifetime)));
	
	erosion_val *= erosion_val;
	
	ALPHA *= erosion_val;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
