extends RefCounted
## Foyer visible (lot 10b-ville, V1) : fonction pure qui traduit EtatPartie.foyer_visuel() (lot_10a.md §4) en images.
## Aucun prénom ni genre en dur : seuls `sexe`, `age`, `lien` et le nombre et l'âge des enfants comptent.
##   d = {"joueur": {"prenom","sexe":"h"|"f","age"}, "proche": {"prenom","sexe","lien"} | {}, "enfants": [{"prenom","age"}], "marie": bool}
## Sortie : {"joueur": clé de figurine (voisins.gd), "proche": "" | "sylvie" | "h0".."h2", "enfants": [{"images": [...], "x": int}]}.
## Les enfants ne sont dessinés que si « etendu » (à partir de 01/1989, D1 : le décor de 1984-1988 reste identique, ses
## berceaux et tricycles viennent des cartes du foyer, traces_foyer.gd).

const SLOTS_X := [162, 202, 226, 250]          # trottoir devant la maison, de gauche à droite
const MAX_ENFANTS_DESSINES := 4
const AGE_TEMPES := 33                          # homme : tempes grises
const AGE_GRISONNANT := 36                      # homme : cheveux grisonnants ; femme : silhouette « 36-55 ans »


static func cle_joueur(j: Dictionary) -> String:
	var age := int(j.get("age", 30))
	if str(j.get("sexe", "h")) == "f":
		return "joueuse_a" if age < AGE_GRISONNANT else "joueuse_b"
	if age < AGE_TEMPES:
		return "gerard"
	return "gerard_gris" if age < AGE_GRISONNANT else "gerard_age"


static func cle_proche(p: Dictionary) -> String:
	if p.is_empty():
		return ""
	if str(p.get("sexe", "f")) == "f":
		return "sylvie"
	return "h%d" % (absi(str(p.get("prenom", "")).hash()) % 3)


## Classe d'âge d'un enfant : "bebe" (< 2 ans), "petit" (2 à 6), "enfant" (7 à 12), "ado" (13 et plus).
static func classe_age(age: int) -> String:
	if age < 2:
		return "bebe"
	if age < 7:
		return "petit"
	return "enfant" if age < 13 else "ado"


static func plan(d: Dictionary, etendu: bool) -> Dictionary:
	var r := {"joueur": cle_joueur(d.get("joueur", {})), "proche": cle_proche(d.get("proche", {})), "enfants": []}
	if not etendu:
		return r
	var bebes := 0
	var petits := 0
	var grands: Array = []
	for e: Dictionary in d.get("enfants", []):
		match classe_age(int(e.get("age", 0))):
			"bebe":
				bebes += 1
			"petit":
				petits += 1
			"enfant":
				grands.append(["objet/enfant_cartable_1", "objet/enfant_cartable_2"])
			_:
				grands.append(["objet/ado_1", "objet/ado_2"])
	var liste: Array = []
	if bebes >= 2:
		liste.append(["objet/poussette_double"])
	elif bebes == 1:
		liste.append(["objet/poussette"])
	if petits >= 2:
		liste.append(["objet/tricycles"])
	elif petits == 1:
		liste.append(["objet/tricycle"])
	liste.append_array(grands)
	for i in mini(liste.size(), MAX_ENFANTS_DESSINES):
		r["enfants"].append({"images": liste[i], "x": SLOTS_X[i]})
	return r
