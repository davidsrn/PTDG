shader_type canvas_item;

// Neon Outline Shader
// Creates a glowing outline effect around sprites
// Perfect for highlighting towers and enemies

uniform vec4 outline_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;
uniform float outline_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;
uniform bool enable_pulse : hint_range(0.0, 1.0) = true;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// Sample surrounding pixels to detect edges
	vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_width;

	float outline = 0.0;

	// 8-direction sampling for outline detection
	outline += texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0)).a;
	outline += texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)).a;
	outline += texture(TEXTURE, UV + vec2(0.0, -pixel_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(0.0, pixel_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-pixel_size.x, -pixel_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(pixel_size.x, -pixel_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-pixel_size.x, pixel_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(pixel_size.x, pixel_size.y)).a;

	outline = min(outline, 1.0);

	// Only show outline where original texture is transparent
	outline *= (1.0 - color.a);

	// Add pulsing effect
	float pulse = 1.0;
	if (enable_pulse) {
		pulse = 0.7 + 0.3 * sin(TIME * pulse_speed);
	}

	// Combine original color with outline
	vec3 final_color = color.rgb;
	final_color = mix(final_color, outline_color.rgb, outline * pulse);

	float final_alpha = max(color.a, outline);

	COLOR = vec4(final_color * outline_intensity, final_alpha);
}
