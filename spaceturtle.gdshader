shader_type canvas_item;

uniform sampler2D space_tex : source_color;

void fragment() {
	// White parts of the turtle become the space picture,
	// black outlines stay black, transparent stays transparent.
	COLOR.rgb *= texture(space_tex, UV).rgb;
}