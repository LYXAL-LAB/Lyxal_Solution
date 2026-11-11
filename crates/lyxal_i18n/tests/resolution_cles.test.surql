-- lyxal-test: assertions
-- Résolution du texte d'une clé : repli de langue, langue par défaut, langue source, surcharge
-- de l'organisation, clé non déclarée, plusieurs clés.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["i18n.translation.manage", "i18n.locale.manage"] }
-- identité alpha: { "id": "auth_session:alpha", "pv": 1, "permissions": ["i18n.organization.translation.manage"] }
-- identité beta: { "id": "auth_session:beta", "pv": 1, "permissions": ["i18n.organization.translation.manage"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["i18n.translation.read"] }

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
    CREATE auth_identity:lecteur CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "lecteur@lyxal.test" } };
    CREATE auth_session:lecteur CONTENT { identity: auth_identity:lecteur, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- préparation: espaces de noms, clés et textes
RETURN fn::i18n_namespace_create({ key: "base", module: "lyxal_base" }).ok
    AND fn::i18n_namespace_create({ key: "console", module: "lyxal_server", source_locale: "en" }).ok
    AND fn::i18n_key_create({ namespace: "base", name: "oui", source_text: "Oui", syntax: "plain" }).ok
    AND fn::i18n_key_create({ namespace: "base", name: "non", source_text: "Non", syntax: "plain" }).ok
    AND fn::i18n_key_create({ namespace: "console", name: "save", source_text: "Save", syntax: "plain" }).ok
    AND fn::i18n_translation_set({ key: "base.oui", locale: "en", text: "Yes" }).ok
    AND fn::i18n_translation_set({ key: "base.oui", locale: "fr-CA", text: "Ouais" }).ok
    AND fn::i18n_translation_set({ key: "base.oui", locale: "fr", text: "Oui chef", tenant: "auth_organization:alpha" }).ok
    AND fn::i18n_translation_set({ key: "base.oui", locale: "en", text: "Aye", tenant: "auth_organization:beta" }).ok;

-- test: langue exacte, puis repli fr-CA → fr
RETURN fn::i18n_resolve({ key: "base.oui", locale: "fr-CA" }).data == { key: "base.oui", text: "Ouais", syntax: "plain", locale: "fr-CA", overridden: false, missing: false }
    AND fn::i18n_resolve({ key: "base.non", locale: "fr_ca" }).data.{ text, locale } == { text: "Non", locale: "fr" }
    AND fn::i18n_resolve({ key: "base.oui", locale: "en-GB" }).data.{ text, locale } == { text: "Yes", locale: "en" };

-- test: langue sans texte → langue par défaut ; sinon langue source de l'espace de noms
RETURN fn::i18n_resolve({ key: "base.oui", locale: "de" }).data.{ text, locale } == { text: "Oui", locale: "fr" }
    AND fn::i18n_resolve({ key: "console.save", locale: "de" }).data.{ text, locale } == { text: "Save", locale: "en" }
    AND fn::i18n_resolve({ key: "console.save", locale: "fr" }).data.{ text, locale } == { text: "Save", locale: "en" };

-- test: session anonyme ou sans organisation : textes de l'installation
-- en tant que: plateforme
RETURN fn::i18n_resolve({ key: "base.oui", locale: "fr" }).data.{ text, overridden } == { text: "Oui", overridden: false };

-- test: un membre d'alpha reçoit la surcharge de son organisation ; la langue plus précise passe avant
-- en tant que: membre
RETURN fn::i18n_resolve({ key: "base.oui", locale: "fr" }).data.{ text, overridden } == { text: "Oui chef", overridden: true }
    AND fn::i18n_resolve({ key: "base.oui", locale: "fr-CA" }).data.{ text, overridden } == { text: "Ouais", overridden: false }
    AND fn::i18n_resolve({ key: "base.oui", locale: "en" }).data.text == "Yes"
    AND fn::i18n_resolve({ key: "base.oui", locale: "fr", tenant: "auth_organization:alpha" }).data.text == "Oui chef";

-- test: un membre d'alpha ne résout pas pour beta
-- en tant que: membre
RETURN fn::i18n_resolve({ key: "base.oui", locale: "en", tenant: "auth_organization:beta" }).error.code == "I18N_PERMISSION_DENIED"
    AND fn::i18n_resolve_many({ keys: ["base.oui"], locale: "en", tenant: "auth_organization:beta" }).error.code == "I18N_PERMISSION_DENIED";

-- test: un compte de service (i18n.translation.read) résout pour toute organisation, lit ses surcharges, n'écrit rien
-- en tant que: lecteur
RETURN fn::i18n_resolve({ key: "base.oui", locale: "en", tenant: "auth_organization:beta" }).data.{ text, overridden } == { text: "Aye", overridden: true }
    AND fn::i18n_resolve_many({ keys: ["base.oui"], locale: "fr", tenant: "auth_organization:alpha" }).data.text == ["Oui chef"]
    AND fn::i18n_resolve({ key: "base.oui", locale: "en" }).data.overridden == false
    AND fn::i18n_can_read({ tenant: auth_organization:beta })
    AND !fn::i18n_can_translate({ tenant: auth_organization:beta })
    AND fn::i18n_translation_set({ key: "base.oui", locale: "en", text: "Yo", tenant: "auth_organization:beta" }).error.code == "I18N_PERMISSION_DENIED";

-- test: la session système résout pour une organisation donnée
RETURN fn::i18n_resolve({ key: "base.oui", locale: "en", tenant: "auth_organization:beta" }).data.{ text, overridden } == { text: "Aye", overridden: true }
    AND fn::i18n_resolve_scope(auth_organization:beta).{ allowed, system, scope, default_chain } == { allowed: true, system: true, scope: "beta", default_chain: ["fr"] };

-- test: plusieurs clés dans l'ordre demandé, clé non déclarée comprise
-- en tant que: membre
RETURN fn::i18n_resolve_many({ keys: ["base.non", "base.absente", "base.oui"], locale: "fr" }).data.{ key, text, missing }
    == [{ key: "base.non", text: "Non", missing: false }, { key: "base.absente", text: "base.absente", missing: true }, { key: "base.oui", text: "Oui chef", missing: false }];

-- test: une session utilisateur ne note aucune clé manquante
RETURN array::len(SELECT VALUE id FROM i18n_missing_key) == 0;

-- test: paramètres invalides
RETURN fn::i18n_resolve({ key: "sans_espace", locale: "fr" }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_resolve({ key: "base.oui", locale: "français" }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_resolve_many({ keys: [], locale: "fr" }).data == []
    AND fn::i18n_resolve_many({ keys: ["Pas Valide"], locale: "fr" }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_resolve_many({ keys: array::map(<array> (0..501), |$i| "base.oui"), locale: "fr" }).error.code == "I18N_INVALID_PARAMETERS";

-- test: clé non déclarée demandée par la session système : la clé elle-même, notée une fois
RETURN fn::i18n_resolve({ key: "base.absente", locale: "fr-CA" }).data == { key: "base.absente", text: "base.absente", syntax: "plain", locale: NONE, overridden: false, missing: true }
    AND fn::i18n_resolve({ key: "base.absente", locale: "fr-CA" }).data.missing
    AND fn::i18n_resolve_text("base.absente", "en", { system: true, scope: NONE, default_chain: ["fr"] }).missing
    AND (SELECT VALUE [full_key, locale] FROM i18n_missing_key ORDER BY locale) == [["base.absente", "en"], ["base.absente", "fr-CA"]];

-- test: un événement i18n.key.missing par clé et par langue
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "i18n.key.missing" ORDER BY payload.locale)
    == [{ key: "base.absente", locale: "en" }, { key: "base.absente", locale: "fr-CA" }];

-- test: liste des clés manquantes réservée à i18n.translation.manage
-- en tant que: membre
RETURN fn::i18n_missing_key_list({}).error.code == "I18N_PERMISSION_DENIED" AND (SELECT VALUE id FROM i18n_missing_key) == [];

-- test: l'administrateur liste les clés manquantes
-- en tant que: plateforme
RETURN fn::i18n_missing_key_list({}).data.{ items: items.{ key, locale }, total }
    == { items: [{ key: "base.absente", locale: "en" }, { key: "base.absente", locale: "fr-CA" }], total: 2 };

-- test: une clé déclarée n'est plus manquante
-- en tant que: plateforme
RETURN fn::i18n_key_create({ namespace: "base", name: "absente", source_text: "Présente", syntax: "plain" }).ok
    AND fn::i18n_missing_key_list({}).data.total == 0
    AND fn::i18n_resolve({ key: "base.absente", locale: "en" }).data.{ text, missing } == { text: "Présente", missing: false };
