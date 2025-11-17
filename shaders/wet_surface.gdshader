shader_type canvas_item;

// Wet Surface Shader
// Creates reflective puddle effects for wet ground
// Best used on ground tiles

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.3;
uniform float distortion_amount : hint_range(0.0, 0.1) = 0.02;
uniform float puddle_scale : hint_range(0.1, 10.0) = 2.0;
uniform float animation_speed : hint_range(0.0, 5.0) = 0.5;
uniform vec4 water_tint : source_color = vec4(0.2, 0.3, 0.4, 1.0);

// Noise function for puddle pattern
float noise(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// Smooth noise
float smooth_noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);

	float a = noise(i);
	float b = noise(i + vec2(1.0, 0.0));
	float c = noise(i + vec2(0.0, 1.0));
	float d = noise(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal noise for puddle shape
float fractal_noise(vec2 uv) {
	float value = 0.0;
	float amplitude = 0.5;

	for (int i = 0; i < 4; i++) {
		value += amplitude * smooth_noise(uv);
		uv *= 2.0;
		amplitude *= 0.5;
	}

	return value;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// Create puddle mask using fractal noise
	vec2 puddle_uv = UV * puddle_scale;
	puddle_uv.x += TIME * animation_speed * 0.1; // Subtle animation

	float puddle_mask = fractal_noise(puddle_uv);
	puddle_mask = smoothstep(0.4, 0.6, puddle_mask); // Sharper puddle edges

	// Create ripple distortion
	vec2 ripple_uv = UV * 20.0;
	float ripple = sin(ripple_uv.x * 10.0 + TIME * 2.0) * cos(ripple_uv.y * 10.0 + TIME * 2.0);
	ripple *= 0.5 + 0.5 * sin(TIME * animation_speed);

	// Apply distortion to reflection
	vec2 distorted_uv = UV;
	distorted_uv += ripple * distortion_amount * puddle_mask;

	// Sample what would be reflected (inverted UV for reflection)
	vec2 reflection_uv = vec2(distorted_uv.x, 1.0 - distorted_uv.y);

	// Get reflection color (using original texture as stand-in)
	vec4 reflection = texture(TEXTURE, reflection_uv);
	reflection.rgb *= water_tint.rgb;

	// Mix original color with reflection based on puddle mask
	vec3 final_color = mix(
		color.rgb,
		reflection.rgb,
		puddle_mask * reflection_strength
	);

	// Darken wet areas slightly
	final_color *= 1.0 - puddle_mask * 0.2;

	COLOR = vec4(final_color, color.a);
}
