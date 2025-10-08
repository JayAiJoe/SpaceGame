shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float glow_strength = 0.02;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float alpha = tex.a;

    // Slight blur-like halo
    vec4 sum = vec4(0.0);
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * glow_strength;
            sum += texture(TEXTURE, UV + offset);
        }
    }

    COLOR = tex + glow_color * (sum.a * 0.25);
    COLOR.a = tex.a; // Preserve transparency
}
