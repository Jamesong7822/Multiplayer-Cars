shader_type spatial;


uniform sampler2D image;
uniform vec2 direction;
uniform float speed;
uniform vec4 emission: hint_color;


void fragment () {
	vec2 newUV = vec2(UV.x + TIME*speed*direction.x, UV.y+TIME*speed*direction.y);
	ALBEDO = texture(image, newUV).rgb;
	ALPHA = texture(image, newUV).a;
	EMISSION = emission.rgb;
}