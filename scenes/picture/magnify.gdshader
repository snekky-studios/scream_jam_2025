shader_type canvas_item;

uniform float x;
uniform float y;
uniform float radius;

float circle(vec2 _st, vec2 _center, float _radius)
{
	return step(distance(_st, _center), _radius);
}

void fragment()
{
	vec2 center = vec2(x, y);
	COLOR.a = circle(UV, center, radius);
}
