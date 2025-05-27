// === Water Elemental Shader ===
// Effects: Droplets, shimmer, wet screen distortion
shader_type canvas_item;

uniform float water_intensity : hint_range(0.0, 1.0) = 1.0;
uniform float time_speed = 1.0;
uniform float droplet_scale = 30.0;
uniform float ripple_strength = 0.01;
uniform float shimmer_speed = 1.5;

void fragment() {
	vec2 uv = UV;
	vec4 base_color = texture(TEXTURE, uv);

	if (water_intensity > 0.0) {
		// Simulate droplet streaks
		float droplet = sin(uv.y * droplet_scale + TIME * time_speed);
		droplet *= sin(uv.x * 10.0 + TIME * 0.5 * time_speed);
		droplet = clamp(droplet, 0.0, 1.0);

		// Ripple distortion around droplets
		vec2 ripple_offset = vec2(0.0, droplet) * ripple_strength * water_intensity;
		vec2 displaced_uv = uv + ripple_offset;

		base_color = texture(TEXTURE, displaced_uv);

		// Shimmer highlight
		float shimmer = sin((uv.y + uv.x) * 100.0 + TIME * shimmer_speed) * 0.1;
		base_color.rgb += shimmer * water_intensity;
	}

	COLOR = base_color;
}
