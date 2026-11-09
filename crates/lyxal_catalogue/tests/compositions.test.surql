-- lyxal-test: assertions
-- Compositions : versions, lignes, publication et verrouillage, gardes anti-cycle
-- (directes, indirectes, sur une chaîne de 8 niveaux), isolation des compositions privées.
--
-- identité sync: { "id": "auth_session:sync", "pv": 1, "permissions": ["catalogue.master.write"] }
-- identité alpha: { "id": "auth_session:alpha", "pv": 1, "permissions": ["catalogue.item.read", "catalogue.item.manage"] }
-- identité beta: { "id": "auth_session:beta", "pv": 1, "permissions": ["catalogue.item.read", "catalogue.item.manage"] }

-- préparation: organisations, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    CREATE auth_identity:sync CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "sync@lyxal.test" } };
    CREATE auth_session:sync CONTENT { identity: auth_identity:sync, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:alpha CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "alpha@lyxal.test" } };
    RELATE auth_identity:alpha->auth_member_of->auth_organization:alpha;
    CREATE auth_session:alpha CONTENT { identity: auth_identity:alpha, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:beta CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "beta@lyxal.test" } };
    RELATE auth_identity:beta->auth_member_of->auth_organization:beta;
    CREATE auth_session:beta CONTENT { identity: auth_identity:beta, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- préparation: table de test lisible par toutes les identités
DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;

-- test: chaîne de 9 articles maîtres N0 à N8
-- en tant que: sync
RETURN array::all(array::map(<array> (0..9), |$i| fn::catalogue_item_create({ code: string::concat("N", <string> $i), type: "catalogue_type:OUVRAGE", libelle: string::concat("Niveau ", <string> $i), unite_reference: "base_unite:U", master_id: string::concat("M-N", <string> $i) }).ok));

-- préparation: identifiants des articles
CREATE test_ref:items CONTENT object::from_entries((SELECT VALUE [string::lowercase(code), <string> id] FROM catalogue_item));

-- test: création d'une composition (version 1, brouillon)
-- en tant que: sync
RETURN fn::catalogue_composition_create({ parent_item: test_ref:items.n0 }).data.{ version, statut, is_locked, libelle } == { version: 1, statut: "DRAFT", is_locked: false, libelle: "Composition Niveau 0 v1" };

-- préparation: identifiant de la composition de N0
CREATE test_ref:c0 SET id_comp = <string> (SELECT VALUE id FROM ONLY catalogue_composition WHERE parent_item = <record> test_ref:items.n0 LIMIT 1);

-- test: une composition vide ne se publie pas
-- en tant que: sync
RETURN fn::catalogue_composition_publish({ composition_id: test_ref:c0.id_comp }).error.code == "CATALOGUE_COMPOSITION_EMPTY";

-- test: ajout d'une ligne (quantité flottante, perte par défaut)
-- en tant que: sync
RETURN fn::catalogue_composition_add_line({ composition_id: test_ref:c0.id_comp, composant_item: test_ref:items.n1, quantite: 2.5, unite: "base_unite:U" }).data.{ quantite, coefficient_perte } == { quantite: 2.5dec, coefficient_perte: 1dec };

-- test: une quantité nulle est refusée
-- en tant que: sync
RETURN fn::catalogue_composition_add_line({ composition_id: test_ref:c0.id_comp, composant_item: test_ref:items.n1, quantite: 0, unite: "base_unite:U" }).error.details.fields == { quantite: ["CORE_VALIDATION_TOO_SMALL"] };

-- test: un coefficient de perte inférieur à 1 est refusé
-- en tant que: sync
RETURN fn::catalogue_composition_add_line({ composition_id: test_ref:c0.id_comp, composant_item: test_ref:items.n1, quantite: 1, unite: "base_unite:U", coefficient_perte: 0.9 }).error.details.fields == { coefficient_perte: ["CORE_VALIDATION_TOO_SMALL"] };

-- test: une unité inconnue est refusée
-- en tant que: sync
RETURN fn::catalogue_composition_add_line({ composition_id: test_ref:c0.id_comp, composant_item: test_ref:items.n1, quantite: 1, unite: "base_unite:INCONNUE" }).error.code == "CATALOGUE_COMPOSITION_UNITE_INCOMPATIBLE";

-- test: un article ne se compose pas de lui-même
-- en tant que: sync
RETURN fn::catalogue_composition_add_line({ composition_id: test_ref:c0.id_comp, composant_item: test_ref:items.n0, quantite: 1, unite: "base_unite:U" }).error.code == "CATALOGUE_COMPOSITION_CYCLE_DETECTED";

-- test: publication de la composition de N0
-- en tant que: sync
RETURN fn::catalogue_composition_publish({ composition_id: test_ref:c0.id_comp }).data.{ statut, is_locked } == { statut: "PUBLISHED", is_locked: true };

-- test: l'article parent devient composé
RETURN (SELECT VALUE is_composite FROM ONLY <record> test_ref:items.n0) == true;

-- test: une composition publiée n'accepte plus de ligne
-- en tant que: sync
RETURN fn::catalogue_composition_add_line({ composition_id: test_ref:c0.id_comp, composant_item: test_ref:items.n2, quantite: 1, unite: "base_unite:U" }).error.code == "CATALOGUE_COMPOSITION_IMMUTABLE";

-- test: une composition publiée ne se republie pas
-- en tant que: sync
RETURN fn::catalogue_composition_publish({ composition_id: test_ref:c0.id_comp }).error.code == "CATALOGUE_COMPOSITION_NOT_DRAFT";

-- test: une composition publiée ne se modifie pas directement
-- en tant que: sync
-- attendu-erreur: CATALOGUE_COMPOSITION_IMMUTABLE
UPDATE <record> test_ref:c0.id_comp SET libelle = "Modifiée";

-- test: une ligne d'une composition publiée ne se modifie pas directement
-- en tant que: sync
-- attendu-erreur: CATALOGUE_COMPOSITION_IMMUTABLE
UPDATE catalogue_composition_ligne SET quantite = 9dec WHERE composition = <record> test_ref:c0.id_comp;

-- test: nouvelle version : brouillon avec les lignes copiées
-- en tant que: sync
RETURN fn::catalogue_composition_clone_version({ source_composition_id: test_ref:c0.id_comp }).data.{ v: new_composition.version, s: new_composition.statut, n: lignes_cloned } == { v: 2, s: "DRAFT", n: 1 };

-- préparation: identifiant de la version 2
CREATE test_ref:c0v2 SET id_comp = <string> (SELECT VALUE id FROM ONLY catalogue_composition WHERE parent_item = <record> test_ref:items.n0 AND version = 2 LIMIT 1);

-- test: publier la version 2 archive la version 1
-- en tant que: sync
RETURN fn::catalogue_composition_publish({ composition_id: test_ref:c0v2.id_comp }).ok AND (SELECT VALUE statut FROM catalogue_composition WHERE parent_item = <record> test_ref:items.n0 ORDER BY version) == ["ARCHIVED", "PUBLISHED"];

-- test: chaîne N1 → N2 → … → N8, une composition publiée par niveau
-- en tant que: sync
RETURN array::all(array::map(<array> (1..8), |$i| {
    LET $parent = <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = string::concat("N", <string> $i) LIMIT 1);
    LET $child = <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = string::concat("N", <string> ($i + 1)) LIMIT 1);
    LET $comp = fn::catalogue_composition_create({ parent_item: $parent }).data.id;
    LET $line = fn::catalogue_composition_add_line({ composition_id: <string> $comp, composant_item: $child, quantite: 1, unite: "base_unite:U" });
    RETURN $line.ok AND fn::catalogue_composition_publish({ composition_id: <string> $comp }).ok;
}));

-- préparation: brouillon de composition pour N8
-- en tant que: sync
fn::catalogue_composition_create({ parent_item: test_ref:items.n8 });

-- préparation: identifiant du brouillon de N8
CREATE test_ref:c8 SET id_comp = <string> (SELECT VALUE id FROM ONLY catalogue_composition WHERE parent_item = <record> test_ref:items.n8 LIMIT 1);

-- test: cycle indirect sur 8 niveaux (N8 consommerait N0) refusé
-- en tant que: sync
RETURN fn::catalogue_composition_add_line({ composition_id: test_ref:c8.id_comp, composant_item: test_ref:items.n0, quantite: 1, unite: "base_unite:U" }).error.code == "CATALOGUE_COMPOSITION_CYCLE_DETECTED";

-- test: cycle intermédiaire (N8 consommerait N4) refusé
-- en tant que: sync
RETURN fn::catalogue_composition_add_line({ composition_id: test_ref:c8.id_comp, composant_item: test_ref:items.n4, quantite: 1, unite: "base_unite:U" }).error.code == "CATALOGUE_COMPOSITION_CYCLE_DETECTED";

-- test: garde anti-cycle interne appelée directement
RETURN [
    fn::catalogue_composition_check_cycle({ parent_item: <record> test_ref:items.n8, composant_item: <record> test_ref:items.n0 }),
    fn::catalogue_composition_check_cycle({ parent_item: <record> test_ref:items.n0, composant_item: <record> test_ref:items.n8 })
] == [true, false];

-- test: un composant hors de la chaîne est accepté (pas de faux positif)
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "LIBRE", type: "catalogue_type:PRODUIT", libelle: "Libre", unite_reference: "base_unite:U", master_id: "M-LIBRE" }).ok AND fn::catalogue_composition_add_line({ composition_id: test_ref:c8.id_comp, composant_item: <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = "LIBRE" LIMIT 1), quantite: 3, unite: "base_unite:U" }).ok;

-- test: une composition scellée ne se supprime pas
-- en tant que: sync
-- attendu-erreur: CATALOGUE_COMPOSITION_IMMUTABLE
DELETE <record> test_ref:c0.id_comp;

-- test: un locataire ne compose pas un article maître
-- en tant que: alpha
RETURN fn::catalogue_composition_create({ parent_item: test_ref:items.n8 }).error.code == "CATALOGUE_WRITE_FORBIDDEN";

-- test: Alpha compose son article privé avec un article maître
-- en tant que: alpha
RETURN fn::catalogue_item_create({ code: "KIT-ALPHA", type: "catalogue_type:ENSEMBLE", libelle: "Kit Alpha", unite_reference: "base_unite:U" }).ok AND fn::catalogue_composition_add_line({ composition_id: <string> fn::catalogue_composition_create({ parent_item: <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = "KIT-ALPHA" LIMIT 1) }).data.id, composant_item: test_ref:items.n8, quantite: 4, unite: "base_unite:U" }).ok;

-- test: Beta ne voit pas la composition privée d'Alpha
-- en tant que: beta
RETURN (SELECT * FROM catalogue_composition WHERE parent_item.code = "KIT-ALPHA") == [] AND (SELECT * FROM catalogue_composition_ligne WHERE composition.parent_item.code = "KIT-ALPHA") == [];

-- test: l'agent de synchronisation ne voit pas la composition privée d'Alpha
-- en tant que: sync
RETURN (SELECT * FROM catalogue_composition WHERE parent_item.code = "KIT-ALPHA") == [];

-- test: Beta ne modifie pas directement la ligne privée d'Alpha
-- en tant que: beta
RETURN (UPDATE catalogue_composition_ligne SET quantite = 99dec WHERE quantite = 4dec RETURN AFTER) == [];

-- test: Alpha voit la composition active de N0 dans la fiche article
-- en tant que: alpha
RETURN fn::catalogue_item_get({ code: "N0" }).data.composition_active.version == 2;
