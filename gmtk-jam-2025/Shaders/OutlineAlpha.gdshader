shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec4 albedo: source_color = vec4(0,0,0,1);
uniform float size: hint_range(1.0,1.5,0.01) = 1.03;

uniform sampler2D texture_albedo;

uniform sampler2D erosion;

uniform float erosion_progress = 1;
varying float lifetime;

void vertex() {
	VERTEX *= size;
	 lifetime = INSTANCE_CUSTOM.y;
}



void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = albedo.rgb;
	
	vec4 albedo_tex = texture(texture_albedo, UV);
	albedo_tex *= COLOR;
	

	ALPHA *= albedo.a * albedo_tex.a;
	
	//sample erosion texture
	vec4 erosion_tex = texture(erosion, UV);
	
	
	float erosion_val =  smoothstep(0,erosion_tex.r,smoothstep(0,  erosion_tex.r, 1.0 - lifetime));
	
	erosion_val *= erosion_val;
	
	ALPHA *= erosion_val;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
