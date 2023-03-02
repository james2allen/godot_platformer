shader_type canvas_item;


uniform float x_speed;
uniform float y_speed;


void fragment () {
	COLOR = texture(TEXTURE, vec2(UV.x + TIME * x_speed, UV.y+ TIME * y_speed));
}