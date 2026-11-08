shader_type canvas_item;

uniform sampler2D space_tex : source_color;

void fragment() {
	COLOR.rgb *= texture(space_tex, UV).rgb;
}