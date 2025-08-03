shader_type canvas_item;

group_uniforms BackGround;

uniform vec4 colorMain: source_color = vec4(0.05, 0.04, 0.20, 1.0);


group_uniforms Noise;
uniform sampler2D noise1;
uniform sampler2D noise2;
uniform float Vrows: hint_range(0, 30.0, .1) = 3.0;
uniform float Vcolumns: hint_range(0, 30.0, .1) = 3.0;
uniform float TimeModify: hint_range(0.0, 10, 0.1) = 1.0;

group_uniforms Tiling;
uniform vec2 tiling_noise1 = vec2(1.0,1.0);
uniform vec2 offset_noise1;

vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv, float columns, float rows) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1.0;

	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));

			vec2 point = random(index_uv + neighbor);
			float speed = 4.5;
			point = vec2( cos(TIME * TimeModify * point.x * speed), sin(TIME * TimeModify * point.y * speed) ) * 0.5 + 0.5;

			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}

	return minimum_dist;
}

void fragment() {

	vec2 noise_uv = UV * tiling_noise1 + offset_noise1 * TIME * TimeModify;
	//worley
	float worley = worley(noise_uv, Vcolumns, Vrows);

	COLOR = vec4(vec3(worley),1.0f);




}

