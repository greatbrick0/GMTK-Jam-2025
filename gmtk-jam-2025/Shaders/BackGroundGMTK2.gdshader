shader_type canvas_item;

group_uniforms BackGround;

uniform vec4 colorMain: source_color = vec4(0.05, 0.04, 0.20, 1.0);
uniform sampler2D gradientA;
uniform sampler2D TexA;
uniform vec2 TilingA;
uniform vec2 OffsetA;

uniform sampler2D TexB;
uniform vec2 TilingB;
uniform vec2 OffsetB;

uniform float transparency: hint_range(0.0,1.0);


group_uniforms Tiling;


vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}


void fragment() {
	
	vec2 UVA = UV * TilingA + OffsetA * TIME;
	vec2 UVB = UV * TilingB + OffsetB * TIME;
	UVA = vec2(mod(UVA.x,1), mod(UVA.y,1));
	UVB = vec2(mod(UVB.x,1), mod(UVB.y,1));
	vec4 nebulanoise1 = texture(TexA, UVA);
	vec4 nebulanoise2 = texture(TexB, UVB);
	vec4 nebula = min(nebulanoise1,nebulanoise2);
	vec4 nebulaColor1 = texture(gradientA, nebula.rg);
	
	vec4 outputColor = colorMain + nebulaColor1;
	COLOR = vec4(outputColor);

	
	
	
}

