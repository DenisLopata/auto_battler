// === 1. Cyber Ninja Shader ===
// Effects: Chromatic aberration, scanlines, neon pulse
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform float time_speed = 1.0;
uniform vec4 neon_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // Cyan

void fragment() {
    vec2 offset = vec2(0.002 * intensity);
    vec4 col;
    col.r = texture(TEXTURE, UV + offset).r;
    col.g = texture(TEXTURE, UV).g;
    col.b = texture(TEXTURE, UV - offset).b;
    col.a = texture(TEXTURE, UV).a;

    float scanline = sin(UV.y * 800.0 + TIME * 20.0 * time_speed) * 0.1;
    col.rgb *= 1.0 + scanline * intensity;

    float pulse = sin(TIME * 4.0 * time_speed) * 0.5 + 0.5;
    col.rgb = mix(col.rgb, neon_color.rgb, pulse * 0.4 * intensity);
    
    COLOR = col;
}