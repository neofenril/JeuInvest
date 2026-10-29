class_name Hasard
extends RefCounted
## Générateur pseudo-aléatoire déterministe (mulberry32), bit à bit identique à celui de la V1 web.
## Les entiers sont gardés sur 32 bits non signés (masque M32).

const M32 := 0xFFFFFFFF

var _a: int


func _init(graine: int) -> void:
	_a = graine & M32


## Multiplication 32 bits (équivalent de Math.imul) sans débordement des entiers 64 bits.
static func _imul(x: int, y: int) -> int:
	var xl := x & 0xFFFF
	var xh := (x >> 16) & 0xFFFF
	var yl := y & 0xFFFF
	var yh := (y >> 16) & 0xFFFF
	return ((((xh * yl + xl * yh) & 0xFFFF) << 16) + xl * yl) & M32


## Nombre uniforme dans [0, 1[.
func u() -> float:
	_a = (_a + 0x6D2B79F5) & M32
	var t := _imul(_a ^ (_a >> 15), 1 | _a)
	t = ((t + _imul(t ^ (t >> 7), 61 | t)) & M32) ^ t
	return float((t ^ (t >> 14)) & M32) / 4294967296.0


func entre(a: float, b: float) -> float:
	return a + (b - a) * u()


func entier(a: int, b: int) -> int:
	return a + int(floor(u() * (b - a + 1)))


## Loi normale centrée réduite (Box-Muller).
func normal() -> float:
	var u1 := u()
	if u1 == 0.0:
		u1 = 1e-12
	var u2 := u()
	return sqrt(-2.0 * log(u1)) * cos(TAU * u2)


## Loi de Student à 4 degrés de liberté, réduite (variance 1), bornée à ±3,5.
func student4() -> float:
	var z := normal()
	var r1 := u()
	if r1 == 0.0:
		r1 = 1e-12
	var r2 := u()
	if r2 == 0.0:
		r2 = 1e-12
	var chi2 := -2.0 * log(r1 * r2)
	var t := z / sqrt(chi2 / 4.0) / sqrt(2.0)
	return clampf(t, -3.5, 3.5)
