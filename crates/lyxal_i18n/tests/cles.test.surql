-- lyxal-test: assertions
-- Espaces de noms et clés : création, doublons, paramètres, modification, suppression en
-- cascade, droits.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["i18n.translation.manage", "i18n.locale.manage"] }
-- identité alpha: { "id": "auth_session:alpha", "pv": 1, "permissions": ["i18n.organization.translation.manage"] }
-- identité beta: { "id": "auth_session:beta", "pv": 1, "permissions": ["i18n.organization.translation.manage"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }

-- préparation: organisations, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:alpha CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "alpha@lyxal.test" } };
    RELATE auth_identity:alpha->auth_member_of->auth_organization:alpha;
    CREATE auth_session:alpha CONTENT { identity: auth_identity:alpha, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:beta CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "beta@lyxal.test" } };
    RELATE auth_identity:beta->auth_member_of->auth_organization:beta;
    CREATE auth_session:beta CONTENT { identity: auth_identity:beta, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:membre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "membre@lyxal.test" } };
    RELATE auth_identity:membre->auth_member_of->auth_organization:alpha;
    CREATE auth_session:membre CONTENT { identity: auth_identity:membre, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: permissions déclarées et accordées aux rôles du socle
RETURN (SELECT VALUE scope FROM ONLY auth_permission:⟨i18n.translation.manage⟩) == "installation"
    AND (SELECT VALUE scope FROM ONLY auth_permission:⟨i18n.organization.translation.manage⟩) == "organization"
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:platform_admin) CONTAINS "i18n.translation.manage"
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:organization_admin) CONTAINS "i18n.organization.translation.manage";

-- test: un administrateur d'organisation ne crée pas d'espace de noms
-- en tant que: alpha
RETURN fn::i18n_namespace_create({ key: "base", module: "lyxal_base" }).error.code == "I18N_PERMISSION_DENIED";

-- test: création d'un espace de noms, langue source des réglages par défaut
-- en tant que: plateforme
RETURN fn::i18n_namespace_create({ key: "base", module: "lyxal_base", description: "Référentiels" }).data.{ id, key, module, source_locale }
    == { id: i18n_namespace:base, key: "base", module: "lyxal_base", source_locale: i18n_locale:fr };

-- test: doublon, langue source inconnue ou inactive, clé invalide
-- en tant que: plateforme
RETURN fn::i18n_namespace_create({ key: "base", module: "lyxal_base" }).error.code == "I18N_NAMESPACE_EXISTS"
    AND fn::i18n_namespace_create({ key: "autre", module: "lyxal_base", source_locale: "tlh" }).error.code == "I18N_LOCALE_NOT_FOUND"
    AND fn::i18n_namespace_create({ key: "autre", module: "lyxal_base", source_locale: "de" }).error.code == "I18N_LOCALE_INACTIVE"
    AND fn::i18n_namespace_create({ key: "Pas Valide", module: "lyxal_base" }).error.code == "I18N_INVALID_PARAMETERS";

-- test: espace de noms en anglais, liste triée lisible par tous
-- en tant que: plateforme
RETURN fn::i18n_namespace_create({ key: "console", module: "lyxal_server", source_locale: "en" }).data.source_locale == i18n_locale:en
    AND fn::i18n_namespace_list({}).data.{ keys: items.key, total } == { keys: ["base", "console"], total: 2 };

-- test: la langue source d'un espace de noms ne se désactive pas
-- en tant que: plateforme
RETURN fn::i18n_locale_deactivate({ locale: "en" }).error.code == "I18N_LOCALE_DEFAULT_REQUIRED";

-- test: garde de la base sur la langue source d'un espace de noms
-- attendu-erreur: I18N_LOCALE_DEFAULT_REQUIRED
UPDATE i18n_locale:en SET active = false;

-- test: création d'une clé avec son texte source
-- en tant que: plateforme
RETURN fn::i18n_key_create({ namespace: "base", name: "unite.metre", source_text: "mètre", syntax: "plain", description: "Unité de longueur" }).data.key.{ id, full_key, name, params }
    == { id: i18n_key:⟨base.unite.metre⟩, full_key: "base.unite.metre", name: "unite.metre", params: [] };

-- test: le texte source est la traduction de l'installation dans la langue source
RETURN (SELECT text, syntax, state, is_source, outdated, scope_key FROM ONLY i18n_translation:["base.unite.metre", "fr", "installation"])
    == { text: "mètre", syntax: "plain", state: "translated", is_source: true, outdated: false, scope_key: "installation" };

-- test: clé avec paramètres ; avertissement pour un paramètre inutilisé
-- en tant que: plateforme
RETURN fn::i18n_key_create({ namespace: "base", name: "panier.articles", source_text: "{count, plural, one {# article} other {# articles}}",
        params: [{ name: "count", type: "number" }, { name: "shop", type: "string" }], max_length: 200 }).data.warnings
    == [{ code: "missing_category", argument: "count", category: "many" }, { code: "unused_parameter", argument: "shop" }];

-- test: doublon, espace inconnu, nom invalide, paramètres en double, texte source invalide
-- en tant que: plateforme
RETURN fn::i18n_key_create({ namespace: "base", name: "unite.metre", source_text: "mètre" }).error.code == "I18N_KEY_EXISTS"
    AND fn::i18n_key_create({ namespace: "inconnu", name: "a", source_text: "a" }).error.code == "I18N_NAMESPACE_NOT_FOUND"
    AND fn::i18n_key_create({ namespace: "base", name: "Unité Mètre", source_text: "a" }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_key_create({ namespace: "base", name: "double", source_text: "a", params: [{ name: "n", type: "number" }, { name: "n", type: "string" }] }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_key_create({ namespace: "base", name: "type", source_text: "a", params: [{ name: "n", type: "bool" }] }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_key_create({ namespace: "base", name: "invalide", source_text: "Bonjour {name}" }).error.{ code, problems: details.problems }
        == { code: "I18N_TRANSLATION_INVALID", problems: [{ code: "unknown_argument", argument: "name" }] };

-- test: une clé refusée ne laisse ni clé ni texte
RETURN !record::exists(i18n_key:⟨base.invalide⟩) AND array::len(SELECT VALUE id FROM i18n_translation WHERE key = i18n_key:⟨base.invalide⟩) == 0;

-- test: un membre ne crée, ne modifie ni ne supprime de clé
-- en tant que: membre
RETURN fn::i18n_key_create({ namespace: "base", name: "pirate", source_text: "a" }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_key_update({ key: "base.unite.metre", description: "x" }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_key_delete({ key: "base.unite.metre" }).error.code == "I18N_PERMISSION_DENIED"
    AND (CREATE i18n_key:⟨base.pirate⟩ CONTENT { namespace: i18n_namespace:base, name: "pirate" }) == []
    AND (DELETE ONLY i18n_key:⟨base.unite.metre⟩ RETURN BEFORE) == NONE;

-- test: liste des clés, filtre par espace de noms et recherche, lisible par tous
-- en tant que: membre
RETURN fn::i18n_key_list({}).data.{ keys: items.full_key, total } == { keys: ["base.panier.articles", "base.unite.metre"], total: 2 }
    AND fn::i18n_key_list({ namespace: "console" }).data.total == 0
    AND fn::i18n_key_list({ search: " UNITE " }).data.items.full_key == ["base.unite.metre"]
    AND fn::i18n_key_list({ limit: 1, start: 1 }).data.items.full_key == ["base.unite.metre"];

-- test: modification d'une clé : champ absent conservé, clear efface, paramètres remplacés
-- en tant que: plateforme
RETURN fn::i18n_key_update({ key: "base.panier.articles", description: "Nombre d'articles", params: [{ name: "count", type: "number" }], clear: ["max_length"] }).data.{ description, params, max_length }
        == { description: "Nombre d'articles", params: [{ name: "count", type: "number" }], max_length: NONE }
    AND fn::i18n_key_update({ key: "base.panier.articles", description: NONE, max_length: 300 }).data.{ description, max_length } == { description: "Nombre d'articles", max_length: 300 }
    AND fn::i18n_key_update({ key: "base.unite.metre", clear: ["description"] }).data.description == NONE
    AND fn::i18n_key_update({ key: "base.unite.metre", clear: ["name"] }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_key_update({ key: "base.inconnue", description: "x" }).error.code == "I18N_KEY_NOT_FOUND";

-- test: des paramètres ou une longueur que le texte source ne respecte plus sont refusés
-- en tant que: plateforme
RETURN fn::i18n_key_update({ key: "base.panier.articles", params: [] }).error.details.problems == [{ code: "unknown_argument", argument: "count" }]
    AND fn::i18n_key_update({ key: "base.panier.articles", params: [{ name: "count", type: "string" }] }).error.details.problems
        == [{ code: "type_mismatch", argument: "count", type: "plural", expected: "string" }]
    AND fn::i18n_key_update({ key: "base.unite.metre", max_length: 3 }).error.details.problems == [{ code: "too_long", max_length: 3, length: 5 }];

-- test: suppression d'une clé avec ses textes et ses surcharges
-- en tant que: plateforme
RETURN fn::i18n_translation_set({ key: "base.unite.metre", locale: "en", text: "metre", syntax: "plain" }).ok
    AND fn::i18n_translation_set({ key: "base.unite.metre", locale: "fr", text: "mètre linéaire", tenant: "auth_organization:alpha" }).ok
    AND fn::i18n_key_delete({ key: "base.unite.metre" }).data == { deleted: true, translations: 3 }
    AND fn::i18n_key_delete({ key: "base.unite.metre" }).error.code == "I18N_KEY_NOT_FOUND";

-- test: plus aucun texte de la clé supprimée
RETURN array::len(SELECT VALUE id FROM i18n_translation WHERE string::starts_with(<string> key, "i18n_key:⟨base.unite")) == 0
    AND array::len(SELECT VALUE id FROM i18n_translation) == 1;
