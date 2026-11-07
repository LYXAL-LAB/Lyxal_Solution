-- lyxal-test: assertions
-- Articles : rôles, isolation entre locataires, champs maîtres protégés.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité sync: { "id": "catalogue_session:sync", "sub": "service:sync", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "catalogue_sync_agent", "scope": ["catalogue:sync:write"] }
-- identité sync_lecture: { "id": "catalogue_session:sync_lecture", "sub": "service:sync", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "catalogue_sync_agent", "scope": ["catalogue:sync:read"] }
-- identité alpha: { "id": "catalogue_session:alpha", "sub": "user:alpha", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "tenant_user", "tenant_id": "alpha" }
-- identité beta: { "id": "catalogue_session:beta", "sub": "user:beta", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "tenant_user", "tenant_id": "beta" }
-- identité sans_tenant: { "id": "catalogue_session:sans_tenant", "sub": "user:x", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "tenant_user" }
-- identité autre_role: { "id": "catalogue_session:autre", "sub": "user:y", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "viewer", "tenant_id": "alpha" }
-- identité autre_audience: { "id": "catalogue_session:billing", "sub": "user:alpha", "iss": "lyxal-os", "aud": "lyxal-billing", "role": "tenant_user", "tenant_id": "alpha" }

-- test: l'agent de synchronisation crée un article maître
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "placo-ba13", type: "catalogue_type:PRODUIT", libelle: "Plaque BA13", unite_reference: "base_unite:U", nature_reference: "commerciale", fabricant: "placo", reference_fabricant: "BA13-250", code_barre: "400-6381 333931", master_id: "M-BA13" }).data.code_barre == "4006381333931";

-- préparation: table de test lisible par toutes les identités
DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;

-- préparation: identifiant de l'article maître
CREATE test_ref:placo SET item = <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = "PLACO-BA13" LIMIT 1);

-- test: le code est mis en majuscules et l'article est maître
-- en tant que: sync
RETURN fn::catalogue_item_get({ code: " placo-ba13 " }).data.item.{ code, is_custom, tenant_id, fabricant } == { code: "PLACO-BA13", is_custom: false, tenant_id: NONE, fabricant: "PLACO" };

-- test: un code déjà pris est refusé
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "PLACO-BA13", type: "catalogue_type:PRODUIT", libelle: "Doublon", unite_reference: "base_unite:U", master_id: "M-AUTRE" }).error.code == "CATALOGUE_ITEM_ALREADY_EXISTS";

-- test: un GTIN déjà pris est refusé
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "AUTRE", type: "catalogue_type:PRODUIT", libelle: "Autre", unite_reference: "base_unite:U", nature_reference: "COMMERCIALE", marque: "X", code_barre: "4006381333931", master_id: "M-AUTRE" }).error.code == "CATALOGUE_ITEM_GTIN_ALREADY_EXISTS";

-- test: un article générique ne porte pas de marque
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "GEN-1", type: "catalogue_type:PRODUIT", libelle: "Générique", unite_reference: "base_unite:U", marque: "X", master_id: "M-GEN" }).error.code == "CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND";

-- test: un article commercial exige un fabricant ou une marque
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "COM-1", type: "catalogue_type:PRODUIT", libelle: "Commercial", unite_reference: "base_unite:U", nature_reference: "COMMERCIALE", master_id: "M-COM" }).error.code == "CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND";

-- test: un type inconnu est refusé
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "T-1", type: "catalogue_type:INCONNU", libelle: "x", unite_reference: "base_unite:U", master_id: "M-T" }).error.code == "CATALOGUE_ITEM_TYPE_NOT_FOUND";

-- test: une unité inconnue est refusée
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "U-1", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:INCONNUE", master_id: "M-U" }).error.code == "CATALOGUE_ITEM_UNITE_INVALID";

-- test: un master_id déjà pris est refusé
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "M-1", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", master_id: "M-BA13" }).error.code == "CATALOGUE_ITEM_MASTER_ID_DUPLICATE";

-- test: l'agent de synchronisation ne crée pas d'article privé
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "PRIV-SYNC", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", is_custom: true }).error.code == "CATALOGUE_ITEM_SYNC_CANNOT_CREATE_CUSTOM";

-- test: sans le scope d'écriture, l'agent ne crée pas d'article maître
-- en tant que: sync_lecture
RETURN fn::catalogue_item_create({ code: "M-LECT", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", master_id: "M-LECT" }).error.code == "CATALOGUE_ITEM_SYNC_CANNOT_CREATE_MASTER";

-- test: un locataire ne crée pas d'article maître
-- en tant que: alpha
RETURN fn::catalogue_item_create({ code: "M-ALPHA", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", master_id: "M-ALPHA" }).error.code == "CATALOGUE_ITEM_SYNC_CANNOT_CREATE_MASTER";

-- test: le message d'erreur est résolu sous une identité utilisateur
-- en tant que: alpha
RETURN fn::catalogue_item_create({ code: "M-ALPHA", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", master_id: "M-ALPHA" }).error.{ http_status, label } == { http_status: 403, label: "Création d'article maître refusée" };

-- test: Alpha crée son article privé, rattaché à son locataire
-- en tant que: alpha
RETURN fn::catalogue_item_create({ code: "alpha-1", type: "catalogue_type:PRODUIT", libelle: "Article Alpha", unite_reference: "base_unite:U" }).data.{ is_custom, tenant_id } == { is_custom: true, tenant_id: "alpha" };

-- préparation: identifiant de l'article d'Alpha
CREATE test_ref:alpha SET item = <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = "ALPHA-1" LIMIT 1);

-- test: Beta crée son article privé
-- en tant que: beta
RETURN fn::catalogue_item_create({ code: "beta-1", type: "catalogue_type:PRODUIT", libelle: "Article Beta", unite_reference: "base_unite:U" }).ok;

-- test: Alpha ne crée pas d'article au nom de Beta
-- en tant que: alpha
RETURN fn::catalogue_item_create({ code: "alpha-2", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", tenant_id: "beta" }).error.code == "CATALOGUE_ITEM_TENANT_FORBIDDEN";

-- test: un article privé n'a pas d'identifiant maître
-- en tant que: alpha
RETURN fn::catalogue_item_create({ code: "alpha-3", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", is_custom: true, master_id: "M-X" }).error.code == "CATALOGUE_ITEM_CUSTOM_CANNOT_HAVE_MASTER_ID";

-- test: une identité sans tenant_id ne crée pas d'article privé
-- en tant que: sans_tenant
RETURN fn::catalogue_item_create({ code: "x-1", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U" }).error.code == "CATALOGUE_ITEM_TENANT_REQUIRED";

-- test: un autre rôle ne crée pas d'article privé
-- en tant que: autre_role
RETURN fn::catalogue_item_create({ code: "x-2", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U" }).error.code == "CATALOGUE_ITEM_TENANT_REQUIRED";

-- test: Alpha voit l'article maître et le sien, pas celui de Beta
-- en tant que: alpha
RETURN fn::catalogue_item_list({}).data.code == ["ALPHA-1", "PLACO-BA13"];

-- test: Beta voit l'article maître et le sien
-- en tant que: beta
RETURN fn::catalogue_item_list({}).data.code == ["BETA-1", "PLACO-BA13"];

-- test: l'agent de synchronisation ne voit que les articles maîtres
-- en tant que: sync
RETURN fn::catalogue_item_list({}).data.code == ["PLACO-BA13"];

-- test: un jeton émis pour une autre audience ne voit rien
-- en tant que: autre_audience
RETURN fn::catalogue_item_list({}).data == [];

-- test: Beta ne lit pas directement l'article privé d'Alpha
-- en tant que: beta
RETURN (SELECT VALUE code FROM catalogue_item WHERE code = "ALPHA-1") == [];

-- test: Beta ne trouve pas l'article privé d'Alpha par son code
-- en tant que: beta
RETURN fn::catalogue_item_get({ code: "ALPHA-1" }).error.code == "CATALOGUE_ITEM_NOT_FOUND";

-- test: Beta ne lit pas l'article privé d'Alpha par son identifiant
-- en tant que: beta
RETURN fn::catalogue_item_get({ id: test_ref:alpha.item }).error.code == "CATALOGUE_ITEM_NOT_FOUND";

-- test: Beta ne modifie pas l'article privé d'Alpha par la fonction
-- en tant que: beta
RETURN fn::catalogue_item_update({ id: test_ref:alpha.item, libelle: "Piraté" }).error.code == "CATALOGUE_ITEM_NOT_FOUND";

-- test: Beta ne supprime pas l'article privé d'Alpha par la fonction
-- en tant que: beta
RETURN fn::catalogue_item_delete({ id: test_ref:alpha.item }).error.code == "CATALOGUE_ITEM_NOT_FOUND";

-- test: Beta ne modifie pas directement l'article privé d'Alpha
-- en tant que: beta
RETURN (UPDATE catalogue_item SET libelle = "Piraté" WHERE code = "ALPHA-1" RETURN AFTER) == [];

-- test: l'article d'Alpha n'a pas été modifié
RETURN (SELECT VALUE libelle FROM ONLY catalogue_item WHERE code = "ALPHA-1" LIMIT 1) == "Article Alpha";

-- test: Alpha modifie son article privé
-- en tant que: alpha
RETURN fn::catalogue_item_update({ id: test_ref:alpha.item, libelle: " Article Alpha v2 ", statut_commercial: "fin_de_serie" }).data.{ libelle, statut_commercial } == { libelle: "Article Alpha v2", statut_commercial: "FIN_DE_SERIE" };

-- test: le code d'un article est immuable
-- en tant que: alpha
RETURN fn::catalogue_item_update({ id: test_ref:alpha.item, code: "ALPHA-9" }).error.code == "CATALOGUE_ITEM_CODE_IMMUTABLE";

-- test: la nature d'un article est immuable
-- en tant que: alpha
RETURN fn::catalogue_item_update({ id: test_ref:alpha.item, nature_reference: "COMMERCIALE" }).error.code == "CATALOGUE_ITEM_NATURE_IMMUTABLE";

-- test: le propriétaire d'un article privé est immuable
-- en tant que: alpha
RETURN fn::catalogue_item_update({ id: test_ref:alpha.item, tenant_id: "beta" }).error.code == "CATALOGUE_ITEM_TENANT_ID_IMMUTABLE";

-- test: un article privé ne devient pas maître
-- en tant que: alpha
RETURN fn::catalogue_item_update({ id: test_ref:alpha.item, is_custom: false }).error.code == "CATALOGUE_ITEM_CUSTOM_CANNOT_CONVERT_MASTER";

-- test: un locataire ne modifie pas un champ maître par la fonction
-- en tant que: alpha
RETURN fn::catalogue_item_update({ id: test_ref:placo.item, fabricant: "pirate" }).error.code == "CATALOGUE_ITEM_SYNC_FIELD_PROTECTED";

-- test: un locataire ne modifie aucun champ d'un article maître directement (écriture filtrée)
-- en tant que: alpha
RETURN (UPDATE catalogue_item SET description = "Piraté", unite_conditionnement = base_unite:KG WHERE code = "PLACO-BA13" RETURN AFTER) == []
    AND (SELECT VALUE description FROM ONLY catalogue_item WHERE code = "PLACO-BA13" LIMIT 1) != "Piraté";

-- test: un locataire ne désactive pas l'article maître partagé
-- en tant que: alpha
RETURN fn::catalogue_item_update({ id: test_ref:placo.item, enabled: false }).error.code == "CATALOGUE_ITEM_SYNC_FIELD_PROTECTED";

-- test: un locataire personnalise un article maître pour lui seul
-- en tant que: alpha
RETURN fn::catalogue_item_personnaliser({ item_id: test_ref:placo.item, code_interne_client: " A-BA13 ", libelle_personnalise: "Placo maison" }).data.{ code_interne_client, libelle_personnalise, enabled, tenant_id }
    == { code_interne_client: "A-BA13", libelle_personnalise: "Placo maison", enabled: true, tenant_id: "alpha" };

-- test: un locataire désactive un article maître pour lui seul
-- en tant que: alpha
RETURN fn::catalogue_item_personnaliser({ item_id: test_ref:placo.item, enabled: false }).data.{ libelle_personnalise, enabled } == { libelle_personnalise: "Placo maison", enabled: false };

-- test: le locataire lit sa personnalisation et l'article n'est plus disponible pour lui
-- en tant que: alpha
RETURN (fn::catalogue_item_get({ id: test_ref:placo.item }).data).{ libelle: item.libelle, enabled: item.enabled, personnalisation, disponible }
    == { libelle: "Plaque BA13", enabled: true, personnalisation: { libelle_personnalise: "Placo maison", code_interne_client: "A-BA13", enabled: false }, disponible: false };

-- test: un autre locataire n'en voit rien : libellé du référentiel, article disponible
-- en tant que: beta
RETURN (fn::catalogue_item_get({ id: test_ref:placo.item }).data).{ personnalisation, disponible } == { personnalisation: NONE, disponible: true };

-- test: liste filtrée par disponibilité, propre à chaque locataire
-- en tant que: alpha
RETURN fn::catalogue_item_list({ enabled: true, search: "plaque ba13" }).data == []
    AND fn::catalogue_item_list({ enabled: false, search: "plaque ba13" }).data.map(|$i| [$i.code, $i.disponible, $i.personnalisation.code_interne_client]) == [["PLACO-BA13", false, "A-BA13"]];

-- test: dans la liste d'un autre locataire, l'article reste disponible et non personnalisé
-- en tant que: beta
RETURN fn::catalogue_item_list({ enabled: true, search: "plaque ba13" }).data.map(|$i| [$i.code, $i.disponible, $i.personnalisation]) == [["PLACO-BA13", true, NONE]];

-- test: un autre locataire ne lit ni ne modifie la personnalisation d'Alpha
-- en tant que: beta
RETURN (SELECT * FROM catalogue_item_personnalisation) == []
    AND (UPDATE catalogue_item_personnalisation SET libelle_personnalise = "Piraté" RETURN AFTER) == []
    AND fn::catalogue_item_personnalisation_supprimer({ item_id: test_ref:placo.item }).error.code == "CATALOGUE_PERSONNALISATION_NOT_FOUND";

-- test: la personnalisation d'Alpha est intacte
RETURN (SELECT VALUE [tenant_id, libelle_personnalise, enabled] FROM catalogue_item_personnalisation) == [["alpha", "Placo maison", false]];

-- test: l'agent de synchronisation n'a aucun accès aux personnalisations
-- en tant que: sync
RETURN (SELECT * FROM catalogue_item_personnalisation) == []
    AND fn::catalogue_item_personnaliser({ item_id: test_ref:placo.item, enabled: true }).error.code == "CATALOGUE_ITEM_TENANT_REQUIRED";

-- test: un article privé ne se personnalise pas (il se modifie directement)
-- en tant que: alpha
RETURN fn::catalogue_item_personnaliser({ item_id: test_ref:alpha.item, libelle_personnalise: "Inutile" }).error.code == "CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER";

-- test: une personnalisation vide est refusée
-- en tant que: alpha
RETURN fn::catalogue_item_personnaliser({ item_id: test_ref:placo.item }).error.{ code, f: details.fields.enabled } == { code: "CATALOGUE_INVALID_PARAMETERS", f: ["CORE_VALIDATION_COMBINATION"] };

-- test: la synchronisation met à jour un champ maître
-- en tant que: sync
RETURN fn::catalogue_item_update({ id: test_ref:placo.item, description: "Plaque de plâtre 13 mm", statut_commercial: "ACTIF" }).data.description == "Plaque de plâtre 13 mm";

-- test: la synchronisation retire l'article du référentiel pour tous, puis le rétablit
-- en tant que: sync
RETURN fn::catalogue_item_update({ id: test_ref:placo.item, enabled: false }).data.enabled == false;

-- test: un article retiré par le référentiel est indisponible pour un locataire non personnalisé
-- en tant que: beta
RETURN fn::catalogue_item_get({ id: test_ref:placo.item }).data.disponible == false;

-- test: la synchronisation rétablit l'article sans toucher aux personnalisations
-- en tant que: sync
RETURN fn::catalogue_item_update({ id: test_ref:placo.item, enabled: true }).data.enabled == true;

-- test: après rétablissement, chaque locataire garde sa propre disponibilité
RETURN (SELECT VALUE [tenant_id, enabled] FROM catalogue_item_personnalisation) == [["alpha", false]];

-- test: le locataire supprime sa personnalisation et revient au référentiel
-- en tant que: alpha
RETURN fn::catalogue_item_personnalisation_supprimer({ item_id: test_ref:placo.item }).ok
    AND (fn::catalogue_item_get({ id: test_ref:placo.item }).data).{ personnalisation, disponible } == { personnalisation: NONE, disponible: true };

-- test: l'identifiant maître est immuable
-- en tant que: sync
RETURN fn::catalogue_item_update({ id: test_ref:placo.item, master_id: "M-AUTRE" }).error.code == "CATALOGUE_ITEM_MASTER_ID_IMMUTABLE";

-- test: la synchronisation ne touche pas aux articles privés
-- en tant que: sync
RETURN (UPDATE catalogue_item SET libelle = "Piraté" WHERE code = "ALPHA-1" RETURN AFTER) == [];

-- test: un article maître ne se supprime pas
-- en tant que: alpha
RETURN fn::catalogue_item_delete({ id: test_ref:placo.item }).error.code == "CATALOGUE_ITEM_MASTER_CANNOT_BE_DELETED";

-- test: Beta ne supprime pas directement l'article privé d'Alpha
-- en tant que: beta
RETURN (DELETE catalogue_item WHERE code = "ALPHA-1" RETURN BEFORE) == [];

-- test: Alpha supprime son article privé
-- en tant que: alpha
RETURN fn::catalogue_item_delete({ id: test_ref:alpha.item }).data.deleted == true;

-- test: l'article privé d'Alpha n'existe plus
RETURN (SELECT VALUE code FROM catalogue_item ORDER BY code) == ["BETA-1", "PLACO-BA13"];

-- test: un locataire ne modifie pas sa session
-- en tant que: alpha
RETURN (UPDATE catalogue_session:alpha SET role = "catalogue_sync_agent" RETURN AFTER) == [];

-- test: un locataire ne crée pas de session
-- en tant que: alpha
RETURN (CREATE catalogue_session:pirate CONTENT { role: "catalogue_sync_agent", scope: ["catalogue:sync:write"] } RETURN AFTER) == [];

-- test: recherche, filtre par type et pagination
-- en tant que: beta
RETURN [
    fn::catalogue_item_list({ search: "placo" }).data.code,
    fn::catalogue_item_list({ type: "catalogue_type:OUVRAGE" }).data,
    fn::catalogue_item_list({ limit: 1, start: 1 }).data.code
] == [["PLACO-BA13"], [], ["PLACO-BA13"]];
