// Papier journal ou courrier (09 §2.9) : bruit fin, fibres horizontales, bords légèrement assombris.
shader_type canvas_item;

uniform float bruit = 0.06;
uniform float fibres = 0.04;
uniform vec2 taille = vec2(1000.0, 600.0);
varying vec2 local;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void vertex() {
	local = VERTEX;
}

void fragment() {
	vec3 c = COLOR.rgb;
	c += (hash(floor(local)) - 0.5) * bruit;
	c -= hash(vec2(floor(local.y / 2.0), floor(local.x / 90.0))) * fibres;
	vec2 uv = clamp(local / taille, 0.0, 1.0);
	float bord = smoothstep(0.0, 0.06, uv.x) * smoothstep(0.0, 0.06, 1.0 - uv.x) * smoothstep(0.0, 0.08, uv.y) * smoothstep(0.0, 0.08, 1.0 - uv.y);
	c *= mix(0.92, 1.0, bord);
	COLOR = vec4(c, COLOR.a);
}
