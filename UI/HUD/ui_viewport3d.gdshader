shader_type spatial;
render_mode unshaded, blend_add, depth_test_disabled, cull_disabled;

uniform sampler2D ui_tex : source_color, filter_nearest, repeat_disable;
uniform vec4 glow_tint : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 10.0) = 2.0;

// Scanline + flicker
uniform float scanline_strength : hint_range(0.0, 2.0) = 0.3;
uniform float scanline_speed : hint_range(-10.0, 10.0) = 1.0; // 👈 new control
uniform float flicker_speed : hint_range(0.0, 10.0) = 2.0;
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.1;

// Edge fade
uniform float border_fade_size : hint_range(0.0, 0.5) = 0.1; // how wide the fade is

void fragment() {
    vec2 uv = UV;

    // --- Horizontal & vertical gradient from edges ---
    float fade_x = smoothstep(0.0, border_fade_size, uv.x)
                 * smoothstep(1.0, 1.0 - border_fade_size, uv.x);
    float fade_y = smoothstep(0.0, border_fade_size, uv.y)
                 * smoothstep(1.0, 1.0 - border_fade_size, uv.y);
    float edge_fade = fade_x * fade_y;

    // --- Moving scanlines (scrolling downward) ---
    float scanline_offset = TIME * scanline_speed; // move over time
    float scanline = sin((uv.y + scanline_offset) * 350.0) * 0.5 + 0.5;
    scanline = mix(1.0, scanline, scanline_strength);

    // --- Flicker ---
    float flicker = 1.0 + (sin(TIME * flicker_speed) * flicker_intensity);

    // --- Combine ---
    vec4 ui_color = texture(ui_tex, uv);
    ui_color.rgb *= glow_tint.rgb * scanline * flicker;
    ui_color.rgb *= edge_fade; // fade near edges
    ui_color.a *= edge_fade;

    // --- Output ---
    ALBEDO = ui_color.rgb;
    EMISSION = ui_color.rgb * glow_strength;
    ALPHA = ui_color.a;
}
