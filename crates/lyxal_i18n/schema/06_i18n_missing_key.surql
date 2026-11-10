-- ============================================================================
-- TABLE  : i18n_missing_key
-- MODULE : lyxal_i18n
-- RÔLE   : Clés demandées par l'hôte ou un worker mais non déclarées
-- ============================================================================
-- Identifiant = [clé complète, étiquette de langue]. Écrite par la seule session système
-- (fn::i18n_resolve) : une session utilisateur ne peut pas remplir la table.

DEFINE TABLE OVERWRITE i18n_missing_key
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::auth_has_permission({ permission: "i18n.translation.manage" })
        FOR create, update, delete NONE
    COMMENT "Clés de traduction demandées mais non déclarées";

DEFINE FIELD OVERWRITE full_key ON TABLE i18n_missing_key
    TYPE string
    READONLY
    COMMENT "Clé complète demandée";

DEFINE FIELD OVERWRITE locale ON TABLE i18n_missing_key
    TYPE string
    READONLY
    COMMENT "Étiquette de la langue demandée";

DEFINE FIELD OVERWRITE first_seen_at ON TABLE i18n_missing_key
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Première demande";

DEFINE FIELD OVERWRITE last_seen_at ON TABLE i18n_missing_key
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Dernière demande";

DEFINE INDEX OVERWRITE i18n_missing_key_full_key ON TABLE i18n_missing_key FIELDS full_key;
