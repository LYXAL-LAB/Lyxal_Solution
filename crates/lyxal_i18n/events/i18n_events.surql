-- ============================================================================
-- EVENTS : lyxal_i18n
-- MODULE : lyxal_i18n
-- RÔLE   : Garde des langues des réglages, publication des événements i18n.*
-- ============================================================================
-- Publiés par la base dans la transaction de la mutation (.agents/AGENTS.md §5.6.1) ; une
-- publication refusée fait échouer la mutation.

-- Une langue des réglages (défaut ou source) reste active
DEFINE EVENT OVERWRITE i18n_locale_settings_guard ON TABLE i18n_locale
WHEN $event = "UPDATE" AND $before.active = true AND $after.active = false
THEN {
    LET $settings = (SELECT default_locale, source_locale FROM ONLY i18n_settings:installation);
    IF $settings IS NOT NONE AND ($settings.default_locale = $after.id OR $settings.source_locale = $after.id) {
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
