// background_transition.gdshader
shader_type canvas_item;

uniform sampler2D old_texture;
uniform float transition_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 tile_size = vec2(16.0, 16.0);

void fragment() {
	vec2 uv = UV;
	vec2 pixel_pos = uv * vec2(textureSize(TEXTURE, 0));
	vec2 tile = floor(pixel_pos / tile_size);

	// Create a pseudo-random delay based on tile position
	float tile_delay = fract(sin(dot(tile ,vec2(12.9898,78.233))) * 43758.5453);

	float local_progress = clamp((transition_progress - tile_delay) * 5.0, 0.0, 1.0);

	vec4 old_col = texture(old_texture, uv);
	vec4 new_col = texture(TEXTURE, uv);

	COLOR = mix(old_col, new_col, local_progress);
}
