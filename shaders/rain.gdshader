shader_type canvas_item;

// Animated Rain Shader
// Creates cyberpunk-style rain effect with neon reflections
// Apply to a ColorRect or Sprite2D covering the scene

uniform float rain_density : hint_range(0.0, 1000.0) = 400.0;
uniform float rain_speed : hint_range(0.0, 10.0) = 3.0;
uniform float rain_angle : hint_range(-1.0, 1.0) = 0.1; // Slight diagonal
uniform vec4 rain_color : source_color = vec4(0.5, 0.7, 1.0, 0.6);
uniform float rain_length : hint_range(0.0, 0.1) = 0.02;
uniform float rain_width : hint_range(0.0, 0.01) = 0.002;
uniform bool enable_wind = true;
uniform float wind_strength : hint_range(0.0, 0.5) = 0.1;

// Random function
float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Create a single raindrop
float rain_drop(vec2 uv, float seed) {
	// Random position for this drop
	vec2 rain_uv = uv;

	// Add horizontal offset from seed
	rain_uv.x += random(vec2(seed, 0.0)) - 0.5;

	// Animate downward movement
	float time_offset = random(vec2(seed, 1.0));
	rain_uv.y += (TIME * rain_speed + time_offset) * 0.5;
	rain_uv.y = fract(rain_uv.y);

	// Add angle/wind
	if (enable_wind) {
		rain_uv.x += rain_angle * rain_uv.y;
		rain_uv.x += sin(TIME * 2.0 + seed) * wind_strength * 0.1;
	} else {
		rain_uv.x += rain_angle * rain_uv.y;
	}

	// Create raindrop shape (vertical line)
	float drop = 0.0;
	float x_dist = abs(fract(rain_uv.x) - 0.5);
	float y_range = rain_uv.y;

	if (x_dist < rain_width && y_range < rain_length) {
		drop = 1.0 - (x_dist / rain_width);
		drop *= 1.0 - (y_range / rain_length); // Fade out at tip
	}

	return drop;
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);

	// Create multiple layers of rain
	float rain = 0.0;
	float layers = 5.0;

	for (float i = 0.0; i < layers; i += 1.0) {
		// Create a grid for rain drops
		vec2 rain_uv = UV * vec2(rain_density / 100.0, 1.0);
		rain_uv.x += i * 0.13; // Offset each layer

		// Get rain cell
		vec2 cell_id = floor(rain_uv);
		vec2 cell_uv = fract(rain_uv);

		// Random seed for this cell
		float seed = random(cell_id + i * 100.0);

		// Only show rain in some cells (based on density)
		if (random(cell_id + vec2(i, 0.0)) > 0.5) {
			rain += rain_drop(cell_uv, seed) * (1.0 - i / layers) * 0.3;
		}
	}

	// Clamp rain intensity
	rain = min(rain, 1.0);

	// Mix original color with rain
	vec3 final_color = original_color.rgb;
	final_color = mix(final_color, rain_color.rgb, rain * rain_color.a);

	COLOR = vec4(final_color, max(original_color.a, rain * rain_color.a));
}
