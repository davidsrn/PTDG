shader_type canvas_item;

// Neon Glow Shader
// Creates a pulsing neon glow effect for cyberpunk aesthetic
// Use on towers, UI elements, and environmental lights

// Customizable parameters
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // Cyan by default
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float glow_size : hint_range(0.0, 0.5) = 0.1;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_amplitude : hint_range(0.0, 1.0) = 0.3;
uniform bool enable_pulse = true;
uniform float base_brightness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	// Sample the texture
	vec4 tex_color = texture(TEXTURE, UV);

	// Calculate pulsing effect
	float pulse = 1.0;
	if (enable_pulse) {
		pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amplitude;
	}

	// Calculate distance from edge for glow
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);

	// Create glow based on alpha channel
	float alpha_glow = tex_color.a;

	// Multi-sample blur for glow effect
	vec4 glow = vec4(0.0);
	float samples = 8.0;
	float angle_step = 6.28318530718 / samples; // 2*PI / samples

	for (float i = 0.0; i < samples; i += 1.0) {
		float angle = i * angle_step;
		vec2 offset = vec2(cos(angle), sin(angle)) * glow_size;
		glow += texture(TEXTURE, UV + offset);
	}

	glow /= samples;
	glow.rgb = glow_color.rgb * glow.a;

	// Combine original texture with glow
	vec3 final_color = tex_color.rgb * base_brightness;

	// Add glow
	final_color += glow.rgb * glow_intensity * pulse;

	// Output
	COLOR.rgb = final_color;
	COLOR.a = max(tex_color.a, glow.a * 0.5);
}
