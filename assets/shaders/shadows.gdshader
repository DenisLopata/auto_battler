// === 3. Shadow Assassin Shader (Fixed) ===
// Effects: Vignette, dark bloom, flicker
shader_type canvas_item;

uniform float shadow_strength : hint_range(0.0, 1.0) = 0.7;

void fragment() {
    vec2 center = vec2(0.5);
    float dist = distance(UV, center);
    float vignette = smoothstep(0.3, 0.7, dist);

    float flicker = sin(TIME * 8.0 + UV.x * 100.0) * 0.1;

    // Scale both vignette and flicker with shadow_strength
    float dark_factor = 1.0 - vignette * shadow_strength + flicker * shadow_strength;

    vec4 tex = texture(TEXTURE, UV);
    tex.rgb *= clamp(dark_factor, 0.0, 1.0);

    COLOR = tex;
}
