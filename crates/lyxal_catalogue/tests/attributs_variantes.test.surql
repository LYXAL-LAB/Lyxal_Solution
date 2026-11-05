-- lyxal-test: assertions
-- Attributs, valeurs, attributs statiques, variantes et empreintes de combinaison.
-- Le dictionnaire d'attributs est administré (session root) ; les variantes d'un article
-- maître sont gérées par l'agent de synchronisation.
--
-- identité sync: { "id": "catalogue_session:sync", "sub": "service:sync", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "catalogue_sync_agent", "scope": ["catalogue:sync:write"] }
-- identité alpha: { "id": "catalogue_session:alpha", "sub": "user:alpha", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "tenant_user", "tenant_id": "alpha" }

-- préparation: table de test lisible par toutes les identités
DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;

-- test: création d'un attribut pilote de déclinaison
RETURN fn::catalogue_attribut_create({ code: "taille", libelle: "Taille", type_donnee: "STRING", is_variant_driver: true }).data.{ code, is_variant_driver } == { code: "TAILLE", is_variant_driver: true };

-- test: création d'un second attribut pilote
RETURN fn::catalogue_attribut_create({ code: "COULEUR", libelle: "Couleur", type_donnee: "COLOR", is_variant_driver: true }).ok;

-- test: création d'un attribut commun, numérique et avec unité
RETURN fn::catalogue_attribut_create({ code: "EPAISSEUR", libelle: "Épaisseur", type_donnee: "NUMBER", unite: "base_unite:U" }).data.is_variant_driver == false;

-- test: un code d'attribut déjà pris est refusé
RETURN fn::catalogue_attribut_create({ code: "Taille", libelle: "Doublon", type_donnee: "STRING" }).error.code == "CATALOGUE_ATTRIBUT_ALREADY_EXISTS";

-- test: un type de donnée inconnu est refusé
RETURN fn::catalogue_attribut_create({ code: "POIDS", libelle: "Poids", type_donnee: "MATRICE" }).error.details.fields == { type_donnee: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: une unité inconnue est refusée
RETURN fn::catalogue_attribut_create({ code: "POIDS", libelle: "Poids", type_donnee: "NUMBER", unite: "base_unite:INCONNUE" }).error.code == "CATALOGUE_ATTRIBUT_UNITE_INVALID";

-- test: un locataire ne crée pas d'attribut
-- en tant que: alpha
RETURN fn::catalogue_attribut_create({ code: "PIRATE", libelle: "x", type_donnee: "STRING" }).error.code == "CATALOGUE_WRITE_FORBIDDEN";

-- préparation: identifiants des attributs
CREATE test_ref:attributs SET
    taille = <string> (SELECT VALUE id FROM ONLY catalogue_attribut WHERE code = "TAILLE" LIMIT 1),
    couleur = <string> (SELECT VALUE id FROM ONLY catalogue_attribut WHERE code = "COULEUR" LIMIT 1),
    epaisseur = <string> (SELECT VALUE id FROM ONLY catalogue_attribut WHERE code = "EPAISSEUR" LIMIT 1);

-- test: valeurs de l'attribut taille
RETURN [
    fn::catalogue_attribut_valeur_create({ attribut: test_ref:attributs.taille, code: "m", valeur_texte: "M", ordre: 2 }).data.{ code, libelle_affichage },
    fn::catalogue_attribut_valeur_create({ attribut: test_ref:attributs.taille, code: "L", valeur_texte: "L", libelle_affichage: "Large", ordre: 3 }).data.{ code, libelle_affichage }
] == [{ code: "M", libelle_affichage: "M" }, { code: "L", libelle_affichage: "Large" }];

-- test: valeurs de l'attribut couleur
RETURN fn::catalogue_attribut_valeur_create({ attribut: test_ref:attributs.couleur, code: "ROUGE", valeur_texte: "#FF0000" }).ok AND fn::catalogue_attribut_valeur_create({ attribut: test_ref:attributs.couleur, code: "BLEU", valeur_texte: "#0000FF" }).ok;

-- test: une valeur numérique est acceptée en entier ou en flottant
RETURN fn::catalogue_attribut_valeur_create({ attribut: test_ref:attributs.epaisseur, code: "E13", valeur_nombre: 12.5 }).data.valeur_nombre == 12.5dec;

-- test: une valeur sans nombre pour un attribut numérique est refusée
RETURN fn::catalogue_attribut_valeur_create({ attribut: test_ref:attributs.epaisseur, code: "E0", valeur_texte: "treize" }).error.code == "CATALOGUE_ATTRIBUT_TYPE_MISMATCH";

-- test: une valeur pour un attribut inconnu est refusée
RETURN fn::catalogue_attribut_valeur_create({ attribut: "catalogue_attribut:inconnu", code: "X", valeur_texte: "x" }).error.code == "CATALOGUE_ATTRIBUT_NOT_FOUND";

-- test: une date mal formée est refusée
RETURN fn::catalogue_attribut_valeur_create({ attribut: test_ref:attributs.taille, code: "D", valeur_date: "hier" }).error.details.fields == { valeur_date: ["CORE_VALIDATION_TYPE"] };

-- préparation: identifiants des valeurs
CREATE test_ref:valeurs SET
    m = <string> (SELECT VALUE id FROM ONLY catalogue_attribut_valeur WHERE code = "M" LIMIT 1),
    l = <string> (SELECT VALUE id FROM ONLY catalogue_attribut_valeur WHERE code = "L" LIMIT 1),
    rouge = <string> (SELECT VALUE id FROM ONLY catalogue_attribut_valeur WHERE code = "ROUGE" LIMIT 1),
    bleu = <string> (SELECT VALUE id FROM ONLY catalogue_attribut_valeur WHERE code = "BLEU" LIMIT 1),
    e13 = <string> (SELECT VALUE id FROM ONLY catalogue_attribut_valeur WHERE code = "E13" LIMIT 1);

-- test: l'agent de synchronisation crée un article maître déclinable
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "TSHIRT", type: "catalogue_type:PRODUIT", libelle: "T-shirt", unite_reference: "base_unite:U", has_variants: true, master_id: "M-TSHIRT" }).ok;

-- préparation: identifiant de l'article
CREATE test_ref:item SET id_item = <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = "TSHIRT" LIMIT 1);

-- test: attribut statique de l'article
-- en tant que: sync
RETURN fn::catalogue_attribut_set_static({ item_id: test_ref:item.id_item, attribut_id: test_ref:attributs.epaisseur, valeur_id: test_ref:valeurs.e13 }).data.variante == NONE;

-- test: un attribut statique se remplace sans doublon
-- en tant que: sync
RETURN fn::catalogue_attribut_set_static({ item_id: test_ref:item.id_item, attribut_id: test_ref:attributs.epaisseur, valeur_id: test_ref:valeurs.e13 }).ok AND count(SELECT * FROM catalogue_variante_attribut WHERE variante IS NONE) == 1;

-- test: une valeur d'un autre attribut est refusée
-- en tant que: sync
RETURN fn::catalogue_attribut_set_static({ item_id: test_ref:item.id_item, attribut_id: test_ref:attributs.epaisseur, valeur_id: test_ref:valeurs.m }).error.code == "CATALOGUE_ATTRIBUT_VALEUR_INVALID";

-- test: un locataire ne modifie pas les attributs d'un article maître
-- en tant que: alpha
RETURN fn::catalogue_attribut_set_static({ item_id: test_ref:item.id_item, attribut_id: test_ref:attributs.epaisseur, valeur_id: test_ref:valeurs.e13 }).error.code == "CATALOGUE_WRITE_FORBIDDEN";

-- test: création de deux variantes
-- en tant que: sync
RETURN fn::catalogue_variante_create({ item_id: test_ref:item.id_item, code: "tshirt-1", is_default: true }).data.code == "TSHIRT-1" AND fn::catalogue_variante_create({ item_id: test_ref:item.id_item, code: "TSHIRT-2", libelle: "Second", code_barre: "4006381333931", is_default: true }).data.code_barre == "4006381333931";

-- test: une seule variante par défaut
RETURN (SELECT VALUE code FROM catalogue_variante WHERE is_default = true) == ["TSHIRT-2"];

-- test: un code de variante déjà pris est refusé
-- en tant que: sync
RETURN fn::catalogue_variante_create({ item_id: test_ref:item.id_item, code: "TSHIRT-1" }).error.code == "CATALOGUE_VARIANTE_ALREADY_EXISTS";

-- test: une variante d'un article inconnu est refusée
-- en tant que: sync
RETURN fn::catalogue_variante_create({ item_id: "catalogue_item:inconnu", code: "X-1" }).error.code == "CATALOGUE_ITEM_NOT_FOUND";

-- test: un locataire ne crée pas de variante d'un article maître
-- en tant que: alpha
RETURN fn::catalogue_variante_create({ item_id: test_ref:item.id_item, code: "PIRATE-1" }).error.code == "CATALOGUE_WRITE_FORBIDDEN";

-- préparation: identifiants des variantes
CREATE test_ref:variantes SET
    v1 = <string> (SELECT VALUE id FROM ONLY catalogue_variante WHERE code = "TSHIRT-1" LIMIT 1),
    v2 = <string> (SELECT VALUE id FROM ONLY catalogue_variante WHERE code = "TSHIRT-2" LIMIT 1);

-- test: combinaison de la première variante (taille M, rouge)
-- en tant que: sync
RETURN fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v1, item_id: test_ref:item.id_item, attributs: [{ attribut: test_ref:attributs.taille, valeur: test_ref:valeurs.m }, { attribut: test_ref:attributs.couleur, valeur: test_ref:valeurs.rouge }] }).data.attributs_count == 2;

-- test: l'empreinte est celle de la combinaison réelle
RETURN (SELECT VALUE empreinte_attributs FROM ONLY <record> test_ref:variantes.v1) == fn::catalogue_variante_fingerprint({ pairs: [{ attribut: <record> test_ref:attributs.couleur, attribut_valeur: <record> test_ref:valeurs.rouge }, { attribut: <record> test_ref:attributs.taille, attribut_valeur: <record> test_ref:valeurs.m }] });

-- test: la même combinaison sur la seconde variante est refusée
-- en tant que: sync
RETURN fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v2, item_id: test_ref:item.id_item, attributs: [{ attribut: test_ref:attributs.couleur, valeur: test_ref:valeurs.rouge }, { attribut: test_ref:attributs.taille, valeur: test_ref:valeurs.m }] }).error.{ code, http_status } == { code: "CATALOGUE_VARIANTE_DUPLICATE_COMBINAISON", http_status: 409 };

-- test: la seconde variante prend une autre combinaison
-- en tant que: sync
RETURN fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v2, item_id: test_ref:item.id_item, attributs: [{ attribut: test_ref:attributs.taille, valeur: test_ref:valeurs.l }, { attribut: test_ref:attributs.couleur, valeur: test_ref:valeurs.bleu }] }).ok;

-- test: un attribut non pilote est refusé dans une combinaison
-- en tant que: sync
RETURN fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v1, item_id: test_ref:item.id_item, attributs: [{ attribut: test_ref:attributs.epaisseur, valeur: test_ref:valeurs.e13 }] }).error.code == "CATALOGUE_ATTRIBUT_NOT_VARIANT_DRIVER";

-- test: une valeur qui n'appartient pas à l'attribut est refusée
-- en tant que: sync
RETURN fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v1, item_id: test_ref:item.id_item, attributs: [{ attribut: test_ref:attributs.taille, valeur: test_ref:valeurs.rouge }] }).error.code == "CATALOGUE_ATTRIBUT_VALEUR_INVALID";

-- test: une variante d'un autre article est refusée
-- en tant que: sync
RETURN fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v1, item_id: "catalogue_item:autre", attributs: [] }).error.code == "CATALOGUE_VARIANTE_ITEM_MISMATCH";

-- test: un identifiant invalide dans la combinaison est signalé par position
-- en tant que: sync
RETURN fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v1, item_id: test_ref:item.id_item, attributs: [{ attribut: test_ref:attributs.taille, valeur: test_ref:valeurs.m }, { attribut: "catalogue_item:x", valeur: test_ref:valeurs.m }] }).error.details.fields.attributs[0].{ index, attribut } == { index: 1, attribut: "CORE_VALIDATION_NOT_ALLOWED" };

-- test: la combinaison refusée n'a rien modifié
RETURN count(SELECT * FROM catalogue_variante_attribut WHERE variante = <record> test_ref:variantes.v1) == 2;

-- préparation: empreinte avant écriture directe
UPDATE test_ref:variantes SET avant = (SELECT VALUE empreinte_attributs FROM ONLY <record> test_ref:variantes.v1);

-- préparation: écriture directe d'un attribut de variante (taille M → L)
-- en tant que: sync
UPDATE catalogue_variante_attribut SET attribut_valeur = <record> test_ref:valeurs.l WHERE variante = <record> test_ref:variantes.v1 AND attribut = <record> test_ref:attributs.taille;

-- test: une écriture directe d'attribut recalcule l'empreinte
RETURN (SELECT VALUE empreinte_attributs FROM ONLY <record> test_ref:variantes.v1) == fn::catalogue_variante_fingerprint({ pairs: [{ attribut: <record> test_ref:attributs.taille, attribut_valeur: <record> test_ref:valeurs.l }, { attribut: <record> test_ref:attributs.couleur, attribut_valeur: <record> test_ref:valeurs.rouge }] }) AND test_ref:variantes.avant != (SELECT VALUE empreinte_attributs FROM ONLY <record> test_ref:variantes.v1);

-- test: l'empreinte ne se modifie pas directement
-- en tant que: sync
-- attendu-erreur: CATALOGUE_VARIANTE_FINGERPRINT_FORBIDDEN
UPDATE <record> test_ref:variantes.v1 SET empreinte_attributs = "falsifiee";

-- test: un locataire ne modifie pas la combinaison d'une variante maître
-- en tant que: alpha
RETURN [
    fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v1, item_id: test_ref:item.id_item, attributs: [] }).error.code,
    fn::catalogue_variante_set_attributs({ variante_id: test_ref:variantes.v2, item_id: test_ref:item.id_item, attributs: [{ attribut: test_ref:attributs.taille, valeur: test_ref:valeurs.m }] }).error.code
] == ["CATALOGUE_WRITE_FORBIDDEN", "CATALOGUE_WRITE_FORBIDDEN"];

-- test: la combinaison maître est intacte
RETURN count(SELECT * FROM catalogue_variante_attribut WHERE variante IS NOT NONE) == 4;

-- test: l'article montre ses variantes et ses attributs statiques
-- en tant que: alpha
RETURN fn::catalogue_item_get({ code: "TSHIRT" }).data.{ n: array::len(variantes), s: array::len(attributs_statiques) } == { n: 2, s: 1 };
