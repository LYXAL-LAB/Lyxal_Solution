-- lyxal-test: assertions
-- Export, import et parcours des textes : filtres, portée d'une organisation, rapport d'import
-- (créé, modifié, inchangé, ignoré, invalide), essai sans écriture, droits.
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

-- préparation: espaces de noms, clés et textes
RETURN fn::i18n_namespace_create({ key: "base", module: "lyxal_base" }).ok
    AND fn::i18n_namespace_create({ key: "console", module: "lyxal_server", source_locale: "en" }).ok
    AND fn::i18n_key_create({ namespace: "base", name: "oui", source_text: "Oui", syntax: "plain", description: "Réponse positive" }).ok
    AND fn::i18n_key_create({ namespace: "base", name: "salut", source_text: "Bonjour {name}", params: [{ name: "name", type: "string" }], max_length: 40 }).ok
    AND fn::i18n_key_create({ namespace: "console", name: "save", source_text: "Save", syntax: "plain" }).ok
    AND fn::i18n_translation_set({ key: "base.oui", locale: "en", text: "Yes" }).ok
    AND fn::i18n_translation_review({ key: "base.oui", locale: "en", reviewed: true }).ok
    AND fn::i18n_translation_set({ key: "base.oui", locale: "en", text: "Aye", tenant: "auth_organization:alpha" }).ok;

-- test: export d'une langue : une ligne par clé, texte source, état, clés non traduites comprises
-- en tant que: membre
RETURN fn::i18n_export({ locale: "en" }).data == { total: 3, items: [
    { key: "base.oui", namespace: "base", description: "Réponse positive", params: [], max_length: NONE, source_locale: "fr", source_text: "Oui", text: "Yes", syntax: "plain", state: "reviewed", outdated: false, overridden: false },
    { key: "base.salut", namespace: "base", description: NONE, params: [{ name: "name", type: "string" }], max_length: 40, source_locale: "fr", source_text: "Bonjour {name}", text: NONE, syntax: "icu_mf1", state: "untranslated", outdated: false, overridden: false },
    { key: "console.save", namespace: "console", description: NONE, params: [], max_length: NONE, source_locale: "en", source_text: "Save", text: "Save", syntax: "plain", state: "translated", outdated: false, overridden: false }
] };

-- test: export filtré par espace de noms, paginé ; surcharge de l'organisation avec tenant
-- en tant que: membre
RETURN fn::i18n_export({ locale: "en", namespace: "base", limit: 1, start: 1 }).data.{ keys: items.key, total } == { keys: ["base.salut"], total: 2 }
    AND fn::i18n_export({ locale: "en", namespace: "base", tenant: "auth_organization:alpha" }).data.items.{ text, state, overridden }
        == [{ text: "Aye", state: "translated", overridden: true }, { text: NONE, state: "untranslated", overridden: false }];

-- test: export refusé : autre organisation, langue ou espace de noms inconnu, paramètres
-- en tant que: membre
RETURN fn::i18n_export({ locale: "en", tenant: "auth_organization:beta" }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_export({ locale: "tlh" }).error.code == "I18N_LOCALE_NOT_FOUND"
    AND fn::i18n_export({ locale: "en", namespace: "inconnu" }).error.code == "I18N_NAMESPACE_NOT_FOUND"
    AND fn::i18n_export({}).error.code == "I18N_INVALID_PARAMETERS";

-- test: essai d'import : le rapport complet, rien n'est écrit
-- en tant que: plateforme
RETURN fn::i18n_import({ locale: "en", dry_run: true, entries: [
        { key: "base.salut", text: "Hello {name}" },
        { key: "console.save", text: "Save" },
        { key: "console.save.all", text: "Save all" },
        { key: "base.oui", text: "Yep" }
    ] }).data == { created: 1, updated: 0, unchanged: 1, skipped: [{ key: "console.save.all", reason: "key_not_found" }, { key: "base.oui", reason: "reviewed" }], invalid: [] }
    AND !record::exists(i18n_translation:["base.salut", "en", "installation"])
    AND i18n_translation:["base.oui", "en", "installation"].text == "Yes";

-- test: import : créé, inchangé, clé inconnue, texte relu protégé, texte invalide non écrit
-- en tant que: plateforme
RETURN fn::i18n_import({ locale: "en", entries: [
        { key: "base.salut", text: "Hello {name}" },
        { key: "console.save", text: "Save" },
        { key: "console.save.all", text: "Save all" },
        { key: "base.oui", text: "Yep" }
    ] }).data == { created: 1, updated: 0, unchanged: 1, skipped: [{ key: "console.save.all", reason: "key_not_found" }, { key: "base.oui", reason: "reviewed" }], invalid: [] }
    AND i18n_translation:["base.salut", "en", "installation"].{ text, syntax, state } == { text: "Hello {name}", syntax: "icu_mf1", state: "translated" }
    AND i18n_translation:["base.oui", "en", "installation"].{ text, state } == { text: "Yes", state: "reviewed" };

-- test: textes refusés par le contrôle : signalés, les autres entrées sont écrites
-- en tant que: plateforme
RETURN fn::i18n_import({ locale: "en", entries: [
        { key: "base.salut", text: "Hello {nom}" },
        { key: "console.save", text: "Save it" }
    ] }).data == { created: 0, updated: 1, unchanged: 0, skipped: [], invalid: [{ key: "base.salut", problems: [{ code: "unknown_argument", argument: "nom" }] }] }
    AND i18n_translation:["base.salut", "en", "installation"].text == "Hello {name}"
    AND i18n_translation:["console.save", "en", "installation"].text == "Save it"
    AND fn::i18n_import({ locale: "en", entries: [{ key: "base.salut", text: "Hello dear {name}, welcome back to the application" }] }).data.invalid
        == [{ key: "base.salut", problems: [{ code: "too_long", max_length: 40, length: 50 }] }];

-- test: un texte relu est écrasé sur demande et revient à l'état traduit
-- en tant que: plateforme
RETURN fn::i18n_import({ locale: "en", overwrite_reviewed: true, entries: [{ key: "base.oui", text: "Yep" }] }).data.{ updated, skipped } == { updated: 1, skipped: [] }
    AND i18n_translation:["base.oui", "en", "installation"].{ text, syntax, state } == { text: "Yep", syntax: "plain", state: "translated" };

-- test: syntaxe d'une entrée : celle demandée, sinon celle du texte existant ou du texte source
-- en tant que: plateforme
RETURN fn::i18n_import({ locale: "de", entries: [{ key: "base.oui", text: "Ja" }, { key: "base.salut", text: "{pas un argument}", syntax: "plain" }] }).data.created == 2
    AND i18n_translation:["base.oui", "de", "installation"].syntax == "plain"
    AND i18n_translation:["base.salut", "de", "installation"].syntax == "plain"
    AND fn::i18n_import({ locale: "de", entries: [{ key: "base.salut", text: "{pas un argument}", syntax: "icu_mf1" }] }).data.invalid[0].problems
        == [{ code: "invalid_argument", argument: "pas un argument" }];

-- test: l'administrateur d'alpha importe pour son organisation seulement
-- en tant que: alpha
RETURN fn::i18n_import({ locale: "fr", tenant: "auth_organization:alpha", entries: [{ key: "base.oui", text: "Oui chef" }] }).data.created == 1
    AND i18n_translation:["base.oui", "fr", "alpha"].{ text, scope_key } == { text: "Oui chef", scope_key: "alpha" }
    AND i18n_translation:["base.oui", "fr", "installation"].text == "Oui"
    AND fn::i18n_import({ locale: "fr", entries: [{ key: "base.oui", text: "Ouais" }] }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_import({ locale: "fr", tenant: "auth_organization:beta", entries: [{ key: "base.oui", text: "Ouais" }] }).error.code == "I18N_PERMISSION_DENIED";

-- test: un membre n'importe rien ; paramètres refusés : doublon, clé ou texte invalide, trop d'entrées, langue inconnue
-- en tant que: plateforme
RETURN fn::i18n_import({ locale: "en", entries: [{ key: "base.oui", text: "a" }, { key: "base.oui", text: "b" }] }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_import({ locale: "en", entries: [{ key: "Pas Valide", text: "a" }] }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_import({ locale: "en", entries: [{ key: "base.oui", text: "" }] }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_import({ locale: "en", entries: [{ key: "base.oui", text: "a", state: "reviewed" }] }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_import({ locale: "en", entries: array::map(<array> (0..501), |$i| { key: string::concat("base.k", <string> $i), text: "a" }) }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_import({ locale: "tlh", entries: [{ key: "base.oui", text: "a" }] }).error.code == "I18N_LOCALE_NOT_FOUND"
    AND fn::i18n_import({ locale: "en", entries: [] }).data == { created: 0, updated: 0, unchanged: 0, skipped: [], invalid: [] };

-- test: un membre n'importe rien
-- en tant que: membre
RETURN fn::i18n_import({ locale: "en", entries: [{ key: "base.oui", text: "Yo" }] }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_import({ locale: "fr", tenant: "auth_organization:alpha", entries: [{ key: "base.oui", text: "Yo" }] }).error.code == "I18N_PERMISSION_DENIED";

-- test: entrée d'import, directement : clé inconnue
RETURN fn::i18n_import_entry({ key: "base.absente", text: "x" }, { locale: "en", scope: "installation", tenant: NONE, overwrite_reviewed: false, dry_run: true, language: "fr" })
    == { key: "base.absente", outcome: "skipped", reason: "key_not_found" };

-- test: parcours de tous les textes, toutes portées, trié et paginé
-- en tant que: plateforme
RETURN fn::i18n_translation_scan({}).data.{ total, rows: items.map(|$r| [$r.key, $r.locale, $r.tenant]) } == { total: 9, rows: [
        ["base.oui", "de", NONE], ["base.oui", "en", "auth_organization:alpha"], ["base.oui", "en", NONE], ["base.oui", "fr", "auth_organization:alpha"], ["base.oui", "fr", NONE],
        ["base.salut", "de", NONE], ["base.salut", "en", NONE], ["base.salut", "fr", NONE],
        ["console.save", "en", NONE]
    ] }
    AND fn::i18n_translation_scan({ limit: 2, start: 7 }).data.items == [
        { key: "base.salut", locale: "fr", tenant: NONE, text: "Bonjour {name}", syntax: "icu_mf1" },
        { key: "console.save", locale: "en", tenant: NONE, text: "Save it", syntax: "plain" }
    ]
    AND fn::i18n_translation_scan({ limit: 0 }).error.code == "I18N_INVALID_PARAMETERS";

-- test: le parcours de tous les textes est réservé à i18n.translation.manage
-- en tant que: alpha
RETURN fn::i18n_translation_scan({}).error.code == "I18N_PERMISSION_DENIED";
