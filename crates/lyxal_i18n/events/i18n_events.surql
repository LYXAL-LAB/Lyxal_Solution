-- ============================================================================
-- EVENTS : lyxal_i18n
-- MODULE : lyxal_i18n
-- RÔLE   : Gardes (langues des réglages, texte source), obsolescence des traductions,
--          publication des événements i18n.*
-- ============================================================================
-- Publiés par la base dans la transaction de la mutation (.agents/AGENTS.md §5.6.1) ; une
-- publication refusée fait échouer la mutation.

-- Une langue des réglages (défaut ou source) ou source d'un espace de noms reste active
DEFINE EVENT OVERWRITE i18n_locale_settings_guard ON TABLE i18n_locale
WHEN $event = "UPDATE" AND $before.active = true AND $after.active = false
THEN {
    LET $settings = (SELECT default_locale, source_locale FROM ONLY i18n_settings:installation);
    IF $settings IS NOT NONE AND ($settings.default_locale = $after.id OR $settings.source_locale = $after.id) {
        THROW "I18N_LOCALE_DEFAULT_REQUIRED";
    };
    IF array::len(SELECT VALUE id FROM i18n_namespace WHERE source_locale = $after.id LIMIT 1) > 0 {
        THROW "I18N_LOCALE_DEFAULT_REQUIRED";
    };
};

DEFINE EVENT OVERWRITE i18n_locale_activation_event ON TABLE i18n_locale
WHEN $event = "UPDATE" AND $before.active != $after.active
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: IF $after.active { "i18n.locale.activated" } ELSE { "i18n.locale.deactivated" },
        producer: "lyxal_i18n",
        source: $after.id,
        payload: { locale: $after.tag },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- L'identifiant d'un espace de noms, d'une clé ou d'un texte est fixé par son contenu : une
-- écriture directe ne peut pas occuper l'emplacement d'une autre clé, langue ou portée
DEFINE EVENT OVERWRITE i18n_namespace_id_guard ON TABLE i18n_namespace
WHEN $event = "CREATE"
THEN {
    IF $after.id != type::record("i18n_namespace", $after.key) { THROW "I18N_WRITE_FORBIDDEN"; };
};

DEFINE EVENT OVERWRITE i18n_key_id_guard ON TABLE i18n_key
WHEN $event = "CREATE"
THEN {
    IF $after.id != type::record("i18n_key", $after.full_key) { THROW "I18N_WRITE_FORBIDDEN"; };
};

DEFINE EVENT OVERWRITE i18n_translation_id_guard ON TABLE i18n_translation
WHEN $event = "CREATE"
THEN {
    LET $expected = type::record("i18n_translation", [
        (SELECT VALUE full_key FROM ONLY $after.key),
        <string> record::id($after.locale),
        $after.scope_key
    ]);
    IF $after.id != $expected { THROW "I18N_WRITE_FORBIDDEN"; };
};

-- Une clé déclarée n'est plus manquante
DEFINE EVENT OVERWRITE i18n_key_declared ON TABLE i18n_key
WHEN $event = "CREATE"
THEN {
    DELETE i18n_missing_key WHERE full_key = $after.full_key;
};

-- Texte écrit (par la fonction ou directement) : empreinte du texte source, obsolescence des autres textes de la clé quand le
-- texte source change, événements i18n.translation.updated et i18n.translation.outdated
DEFINE EVENT OVERWRITE i18n_translation_written ON TABLE i18n_translation
WHEN $event = "CREATE" OR ($event = "UPDATE" AND ($before.revision != $after.revision OR $before.text != $after.text OR $before.syntax != $after.syntax))
THEN {
    LET $key = (SELECT full_key, namespace.source_locale AS source_locale FROM ONLY $after.key);
    LET $source_text = IF $after.is_source { $after.text } ELSE {
        (SELECT VALUE text FROM ONLY type::record("i18n_translation", [$key.full_key, <string> record::id($key.source_locale), "installation"]))
    };
    LET $hash = IF $source_text IS NONE { NONE } ELSE { crypto::blake3($source_text) };
    UPDATE $after.id SET source_hash = $hash, outdated = false;
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "i18n.translation.updated",
        producer: "lyxal_i18n",
        source: $after.id,
        payload: {
            key: $key.full_key,
            locale: <string> record::id($after.locale),
            tenant: IF $after.tenant IS NONE { NONE } ELSE { <string> $after.tenant }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    IF $after.is_source AND $event = "UPDATE" AND $before.text != $after.text {
        LET $stale = (UPDATE i18n_translation SET outdated = true, state = "translated"
            WHERE key = $after.key AND id != $after.id AND source_hash != $hash RETURN VALUE id);
        IF array::len($stale) > 0 {
            LET $outdated = fn::event_publish({
                event_id: rand::uuid::v7(),
                event_type: "i18n.translation.outdated",
                producer: "lyxal_i18n",
                source: $after.key,
                payload: { key: $key.full_key, count: array::len($stale) },
                metadata: {}
            });
            IF !$outdated.ok { THROW $outdated.error.code; };
        };
    };
};

-- Le texte source ne se supprime pas tant que sa clé existe (il part avec elle, en cascade)
DEFINE EVENT OVERWRITE i18n_translation_source_guard ON TABLE i18n_translation
WHEN $event = "DELETE" AND $before.is_source = true
THEN {
    IF record::exists($before.key) { THROW "I18N_SOURCE_REQUIRED"; };
};

DEFINE EVENT OVERWRITE i18n_missing_key_event ON TABLE i18n_missing_key
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "i18n.key.missing",
        producer: "lyxal_i18n",
        source: $after.id,
        payload: { key: $after.full_key, locale: $after.locale },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};
