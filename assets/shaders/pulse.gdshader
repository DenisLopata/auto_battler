// === 5. Electric Mage Shader ===
// Effects: Flash pulses, sinewave distort, static
shader_type canvas_item;

uniform float zap_intensity : hint_range(0.0, 1.0) = 1.0;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    uv.y += sin(UV.x * 30.0 + TIME * 10.0) * 0.01 * zap_intensity;
    vec4 col = texture(TEXTURE, uv);

    float noise = rand(UV * TIME) * 0.2;
    float flash = step(0.95, sin(TIME * 20.0)) * 0.5;

    col.rgb += vec3(noise + flash) * zap_intensity;

    COLOR = col;
}