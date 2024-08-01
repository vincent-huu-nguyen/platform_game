shader_type canvas_item;

uniform vec4 old_scarf_color: source_color;
uniform vec4 new_scarf_color: source_color;

uniform vec4 old_scarf_outline_color: source_color;
uniform vec4 new_scarf_outline_color: source_color;

void fragment() {
    vec4 pixel_color = texture(TEXTURE, UV);
    if (length(pixel_color.rgb - old_scarf_color.rgb) < 0.01) {
        COLOR.rgb = new_scarf_color.rgb;
    }
	if (length(pixel_color.rgb - old_scarf_outline_color.rgb) < 0.01) {
        COLOR.rgb = new_scarf_outline_color.rgb;
    }
}
