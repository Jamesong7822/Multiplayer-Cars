shader_type spatial;


uniform sampler2D image;
uniform vec2 direction;
uniform float speed;


void fragment () {
	vec2 newUV = vec2(UV.x + TIME*speed*direction.x, UV.y+TIME*speed*direction.y);
	ALBEDO = texture(image, newUV).rgb;
	ALPHA = texture(image, newUV).a;
}