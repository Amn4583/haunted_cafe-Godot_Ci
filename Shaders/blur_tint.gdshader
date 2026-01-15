shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 10.0) = 4.0;
uniform vec4 tint_color : source_color = vec4(0.2, 1.0, 0.2, 0.3); // green tint

void fragment() {
    vec2 size = SCREEN_PIXEL_SIZE * blur_amount;
    vec4 col = vec4(0.0);
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-size.x, -size.y));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( size.x, -size.y));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-size.x,  size.y));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( size.x,  size.y));
    col *= 0.25; // average of 4 samples

    // Apply green tint and slight darkening
    COLOR = mix(col, tint_color, tint_color.a);
}