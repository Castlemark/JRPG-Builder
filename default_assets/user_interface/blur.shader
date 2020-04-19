shader_type canvas_item;

uniform float amount : hint_range(0.0, 5.0);
uniform vec4 color : hint_color;

void fragment() {

	vec4 final_color = color * textureLod(SCREEN_TEXTURE, SCREEN_UV, amount);
	COLOR.rgb = final_color.rgb;
}
