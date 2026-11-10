-- lyxal-test: assertions
-- Traductions : écriture, relecture, suppression, surcharges par organisation, obsolescence
-- après changement du texte source, droits, champs posés par la base.
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

-- préparation: espace de noms et clé
RETURN fn::i18n_namespace_create({ key: "base", module: "lyxal_base" }).ok
    AND fn::i18n_key_create({ namespace: "base", name: "salut", source_text: "Bonjour {name}", params: [{ name: "name", type: "string" }] }).ok;

-- test: écriture d'une traduction de l'installation ; empreinte du texte source posée par la base
-- en tant que: plateforme
RETURN fn::i18n_translation_set({ key: "base.salut", locale: "en", text: "Hello {name}" }).data.{ t: translation.{ text, syntax, state, outdated, is_source, scope_key, revision, updated_by, hash: source_hash }, warnings }
    == { t: { text: "Hello {name}", syntax: "icu_mf1", state: "translated", outdated: false, is_source: false, scope_key: "installation", revision: 1, updated_by: auth_identity:plateforme, hash: crypto::blake3("Bonjour {name}") }, warnings: [] };

-- test: paramètres invalides, clé ou langue inconnue, texte refusé par le contrôle
-- en tant que: plateforme
RETURN fn::i18n_translation_set({ key: "base.salut", locale: "en" }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_translation_set({ key: "base.salut", locale: "en", text: "Hi", reviewed: true }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_translation_set({ key: "base.inconnue", locale: "en", text: "Hi" }).error.code == "I18N_KEY_NOT_FOUND"
    AND fn::i18n_translation_set({ key: "base.salut", locale: "tlh", text: "nuqneH" }).error.code == "I18N_LOCALE_NOT_FOUND"
    AND fn::i18n_translation_set({ key: "base.salut", locale: "en", text: "Hello {nom}" }).error.{ code, problems: details.problems }
        == { code: "I18N_TRANSLATION_INVALID", problems: [{ code: "unknown_argument", argument: "nom" }] };

-- test: un membre n'écrit aucun texte, ni par les fonctions ni directement
-- en tant que: membre
RETURN fn::i18n_translation_set({ key: "base.salut", locale: "en", text: "Yo {name}" }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_translation_set({ key: "base.salut", locale: "fr", text: "Salut {name}", tenant: "auth_organization:alpha" }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_translation_review({ key: "base.salut", locale: "en", reviewed: true }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_translation_delete({ key: "base.salut", locale: "en" }).error.code == "I18N_PERMISSION_DENIED"
    AND (UPDATE ONLY i18n_translation:["base.salut", "en", "installation"] SET text = "Yo") == NONE
    AND (DELETE ONLY i18n_translation:["base.salut", "en", "installation"] RETURN BEFORE) == NONE;

-- test: l'administrateur d'alpha surcharge un texte pour son organisation seulement
-- en tant que: alpha
RETURN fn::i18n_translation_set({ key: "base.salut", locale: "fr", text: "Salut {name}", tenant: "auth_organization:alpha" }).data.translation.{ text, tenant, scope_key, is_source }
        == { text: "Salut {name}", tenant: auth_organization:alpha, scope_key: "alpha", is_source: false }
    AND fn::i18n_translation_set({ key: "base.salut", locale: "fr", text: "Coucou {name}" }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_translation_set({ key: "base.salut", locale: "fr", text: "Coucou {name}", tenant: "auth_organization:beta" }).error.code == "I18N_PERMISSION_DENIED";

-- test: beta ne voit ni ne modifie la surcharge d'alpha
-- en tant que: beta
RETURN (SELECT VALUE id FROM i18n_translation WHERE tenant IS NOT NONE) == []
    AND fn::i18n_translation_list({ locale: "fr", tenant: "auth_organization:alpha" }).error.code == "I18N_PERMISSION_DENIED"
    AND (UPDATE ONLY i18n_translation:["base.salut", "fr", "alpha"] SET text = "Piraté") == NONE
    AND fn::i18n_translation_delete({ key: "base.salut", locale: "fr", tenant: "auth_organization:alpha" }).error.code == "I18N_PERMISSION_DENIED";

-- test: un membre d'alpha lit la surcharge de son organisation
-- en tant que: membre
RETURN (SELECT VALUE text FROM i18n_translation WHERE tenant IS NOT NONE) == ["Salut {name}"];

-- test: état des traductions d'une langue ; avec tenant, la surcharge remplace le texte de l'installation
-- en tant que: alpha
RETURN fn::i18n_translation_list({ locale: "fr" }).data.items == [{ key: "base.salut", source_text: "Bonjour {name}", text: "Bonjour {name}", state: "translated", outdated: false, overridden: false }]
    AND fn::i18n_translation_list({ locale: "fr", tenant: "auth_organization:alpha" }).data.items.{ text, overridden } == [{ text: "Salut {name}", overridden: true }]
    AND fn::i18n_translation_list({ locale: "de" }).data.items.{ text, state } == [{ text: NONE, state: "untranslated" }]
    AND fn::i18n_translation_list({ locale: "de", state: "translated" }).data.total == 0
    AND fn::i18n_translation_list({ locale: "en", namespace: "base", search: "SALUT", state: "translated", outdated: false }).data.total == 1
    AND fn::i18n_translation_list({ locale: "tlh" }).error.code == "I18N_LOCALE_NOT_FOUND"
    AND fn::i18n_translation_list({}).error.code == "I18N_INVALID_PARAMETERS";

-- test: relecture d'une traduction
-- en tant que: plateforme
RETURN fn::i18n_translation_review({ key: "base.salut", locale: "en", reviewed: true }).data.state == "reviewed"
    AND fn::i18n_translation_review({ key: "base.salut", locale: "de", reviewed: true }).error.code == "I18N_TRANSLATION_NOT_FOUND"
    AND fn::i18n_translation_review({ key: "base.salut", locale: "en" }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_translation_review({ key: "base.salut", locale: "en", reviewed: true, text: "x" }).error.code == "I18N_INVALID_PARAMETERS";

-- test: les champs posés par la base ne se modifient pas
-- en tant que: plateforme
RETURN (UPDATE ONLY i18n_translation:["base.salut", "en", "installation"] SET outdated = true, source_hash = "faux").{ outdated, hash: source_hash }
    == { outdated: false, hash: crypto::blake3("Bonjour {name}") };

-- test: le texte source change : les autres textes de la clé deviennent obsolètes et non relus
-- en tant que: plateforme
RETURN fn::i18n_translation_set({ key: "base.salut", locale: "fr", text: "Bienvenue {name}" }).data.translation.{ revision, outdated, hash: source_hash }
        == { revision: 2, outdated: false, hash: crypto::blake3("Bienvenue {name}") }
    AND (SELECT VALUE [scope_key, <string> record::id(locale), outdated, state] FROM i18n_translation WHERE !is_source ORDER BY scope_key)
        == [["alpha", "fr", true, "translated"], ["installation", "en", true, "translated"]];

-- test: un événement i18n.translation.outdated par changement, avec le nombre de textes
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "i18n.translation.outdated") == [{ key: "base.salut", count: 2 }]
    AND array::len(SELECT VALUE id FROM event_outbox WHERE event_type = "i18n.translation.updated") == 4;

-- test: un texte obsolète ne se marque pas relu ; la liste le signale
-- en tant que: plateforme
RETURN fn::i18n_translation_review({ key: "base.salut", locale: "en", reviewed: true }).error.code == "I18N_TRANSLATION_OUTDATED"
    AND fn::i18n_translation_list({ locale: "en", outdated: true }).data.items.key == ["base.salut"];

-- test: réécrire le texte, même identique, lève l'obsolescence ; il peut alors être relu puis remis à traduire
-- en tant que: plateforme
RETURN fn::i18n_translation_set({ key: "base.salut", locale: "en", text: "Hello {name}" }).data.translation.{ revision, outdated, hash: source_hash }
        == { revision: 2, outdated: false, hash: crypto::blake3("Bienvenue {name}") }
    AND fn::i18n_translation_review({ key: "base.salut", locale: "en", reviewed: true }).data.state == "reviewed"
    AND fn::i18n_translation_review({ key: "base.salut", locale: "en", reviewed: false }).data.state == "translated";

-- test: le même texte source réécrit ne rend rien obsolète
-- en tant que: plateforme
RETURN fn::i18n_translation_set({ key: "base.salut", locale: "fr", text: "Bienvenue {name}" }).ok
    AND i18n_translation:["base.salut", "en", "installation"].outdated == false
    AND i18n_translation:["base.salut", "fr", "alpha"].outdated == true;

-- test: le texte source ne se supprime pas
-- en tant que: plateforme
RETURN fn::i18n_translation_delete({ key: "base.salut", locale: "fr" }).error.code == "I18N_SOURCE_REQUIRED"
    AND fn::i18n_translation_delete({ key: "base.salut", locale: "en", text: "x" }).error.code == "I18N_INVALID_PARAMETERS";

-- test: garde de la base sur la suppression directe du texte source
-- attendu-erreur: I18N_SOURCE_REQUIRED
DELETE i18n_translation:["base.salut", "fr", "installation"];

-- test: suppression d'une traduction et d'une surcharge
-- en tant que: plateforme
RETURN fn::i18n_translation_delete({ key: "base.salut", locale: "en" }).data == { deleted: true }
    AND fn::i18n_translation_delete({ key: "base.salut", locale: "en" }).error.code == "I18N_TRANSLATION_NOT_FOUND"
    AND fn::i18n_translation_set({ key: "base.salut", locale: "en", text: "Hi {name}", tenant: "auth_organization:beta" }).ok;

-- préparation: suppression physique de l'organisation beta
DELETE auth_organization:beta;

-- test: les surcharges d'une organisation partent avec elle
RETURN (SELECT VALUE scope_key FROM i18n_translation ORDER BY scope_key) == ["alpha", "installation"];

-- test: cible d'une écriture : identifiant du texte, erreur de paramètres
RETURN fn::i18n_translation_target({ key: "base.salut", locale: "fr_ca", tenant: "auth_organization:alpha" }).{ error, id }
        == { error: NONE, id: i18n_translation:["base.salut", "fr-CA", "alpha"] }
    AND fn::i18n_translation_target({ key: "base.salut" }).error.error.code == "I18N_INVALID_PARAMETERS";

-- test: droits de lecture et d'écriture par portée
RETURN fn::i18n_can_read({}) AND fn::i18n_can_translate({});

-- test: droits d'un membre : lit son organisation, n'écrit rien, ne lit pas une autre
-- en tant que: membre
RETURN fn::i18n_can_read({ tenant: auth_organization:alpha }) AND !fn::i18n_can_read({ tenant: auth_organization:beta })
    AND !fn::i18n_can_translate({}) AND !fn::i18n_can_translate({ tenant: auth_organization:alpha });
