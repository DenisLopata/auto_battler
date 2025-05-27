// === 4. Arcade Hero Shader ===
// Effects: CRT warp, color banding, retro grid
shader_type canvas_item;

uniform float crt_intensity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 uv = UV;

    // CRT warp
    vec2 warped_uv = uv * 2.0 - 1.0;
    warped_uv *= vec2(1.0 + 0.1 * (warped_uv.x * warped_uv.x + warped_uv.y * warped_uv.y));
    warped_uv = (warped_uv + 1.0) / 2.0;

    // Sample original and warped color
    vec4 original = texture(TEXTURE, uv);
    vec4 warped = texture(TEXTURE, warped_uv);

    // Apply banding
    float banding = floor(warped.r * 8.0) / 8.0;
    warped.rgb = vec3(banding);

    // Retro grid overlay
    float grid = step(0.01, fract(UV.x * 40.0)) * step(0.01, fract(UV.y * 40.0));
    warped.rgb += vec3(grid) * 0.05;

    // Blend between original and effect
    COLOR = mix(original, warped, crt_intensity);
}
