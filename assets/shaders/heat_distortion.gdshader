// === 2. Fire Brawler Shader ===
// Effects: Heat distortion, glow flicker, ember sparks
shader_type canvas_item;

uniform float heat_intensity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 fire_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // Orange

void fragment() {
    vec2 uv_distort = UV + vec2(sin(UV.y * 50.0 + TIME * 6.0), cos(UV.x * 50.0 + TIME * 3.0)) * 0.003 * heat_intensity;
    vec4 tex = texture(TEXTURE, uv_distort);

    float flicker = fract(sin(dot(UV * 1000.0, vec2(12.9898, 78.233))) * 43758.5453 + TIME * 10.0);
    flicker = step(0.95, flicker) * 0.5;

    tex.rgb += fire_color.rgb * flicker * heat_intensity;

    COLOR = tex;
}