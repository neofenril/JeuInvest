// Ciel de la ville (09 §2.9) : ColorRect plein écran, plan 0.
shader_type canvas_item;

uniform vec4 haut_jour : source_color = vec4(0.42, 0.66, 0.86, 1.0);
uniform vec4 bas_jour  : source_color = vec4(0.93, 0.87, 0.72, 1.0);
uniform vec4 haut_nuit : source_color = vec4(0.05, 0.06, 0.13, 1.0);
uniform vec4 bas_nuit  : source_color = vec4(0.16, 0.12, 0.22, 1.0);
uniform vec4 lueur_couchant : source_color = vec4(0.98, 0.55, 0.36, 1.0);
uniform float jour : hint_range(0.0, 1.0) = 1.0;      // 1 = plein jour, 0 = nuit
uniform float couchant : hint_range(0.0, 1.0) = 0.0;  // lueur orange à l'horizon
uniform float krach : hint_range(0.0, 1.0) = 0.0;     // ciel d'orage rouge-gris
uniform float gel : hint_range(0.0, 1.0) = 0.0;       // pause : bleui, désaturé
uniform float grain = 0.02;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	vec3 col = mix(mix(haut_nuit.rgb, haut_jour.rgb, jour), mix(bas_nuit.rgb, bas_jour.rgb, jour),
				   smoothstep(0.0, 1.0, UV.y));
	col = mix(col, lueur_couchant.rgb, couchant * smoothstep(0.4, 1.0, UV.y) * 0.7);
	col += step(0.9975, hash(floor(UV * vec2(420.0, 240.0)))) * (1.0 - jour) * (1.0 - UV.y) * 0.8;
	// Orage : nuées sombres qui ondulent
	float nuee = 0.5 + 0.5 * sin(UV.x * 7.0 + TIME * 0.6) * sin(UV.y * 5.0 - TIME * 0.4);
	col = mix(col, vec3(0.36, 0.12, 0.12) * (0.8 + 0.3 * nuee), krach * 0.6);
	float g = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(g * 0.85, g * 0.95, g * 1.15), gel * 0.5);
	col += (hash(UV * 900.0 + fract(TIME)) - 0.5) * grain;
	COLOR = vec4(col, 1.0);
}
