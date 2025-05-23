shader_type canvas_item;

uniform float pulse_strength : hint_range(0.0, 2.0) = 0.0;
uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.5, 1.0); // purple-pink

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Pulse based on time
    float pulse = sin(TIME * 10.0) * 0.5 + 0.5;
    float brightness = mix(1.0, 1.5, pulse * pulse_strength);

    // Tint the color
    vec3 tinted = mix(tex_color.rgb, tint_color.rgb, pulse_strength * 0.5);

    COLOR = vec4(tinted * brightness, tex_color.a);
}
