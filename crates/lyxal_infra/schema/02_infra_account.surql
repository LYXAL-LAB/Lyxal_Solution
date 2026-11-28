-- ============================================================================
-- TABLE  : infra_account
-- MODULE : lyxal_infra
-- RÔLE   : Comptes d'hébergeur (clé d'API rangée dans lyxal_secrets, jamais ici)
-- ============================================================================
-- Un compte porte le chemin de sa clé dans le coffre-fort (credentials_path, sous infra/), jamais
-- sa valeur. Il est créé par l'administrateur de la plateforme (infra.manage) ; le worker
-- (infra.worker ou session système) y note le résultat des essais et les zones visibles.
-- Clé de l'enregistrement : infra_account:⟨<key>⟩.

DEFINE TABLE OVERWRITE infra_account
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::infra_can({ action: "read" }) OR fn::infra_can({ action: "worker" })
        FOR create, delete WHERE fn::infra_can({ action: "manage" })
        FOR update WHERE fn::infra_can({ action: "manage" }) OR fn::infra_can({ action: "worker" })
    COMMENT "Comptes d'hébergeur : fournisseur, chemin de la clé dans lyxal_secrets, réglages, état et dernier essai";

DEFINE FIELD OVERWRITE key ON TABLE infra_account
    TYPE string
    READONLY
    ASSERT fn::validation_snake_case_name($value, 1, 64).value == $value
    COMMENT "Clé du compte (snake_case, 64 caractères au plus), égale à la clé de l'enregistrement";

DEFINE FIELD OVERWRITE name ON TABLE infra_account
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Nom lisible";

DEFINE FIELD OVERWRITE provider ON TABLE infra_account
    TYPE string
    READONLY
    ASSERT $value IN ["scaleway"]
    COMMENT "Fournisseur (scaleway ; plus tard ovhcloud, bunny)";

DEFINE FIELD OVERWRITE credentials_path ON TABLE infra_account
    TYPE string
    ASSERT string::starts_with($value, "infra/") AND string::len($value) <= 256
    COMMENT "Chemin de la clé d'API dans lyxal_secrets (installation, sous infra/) ; jamais une valeur";

DEFINE FIELD OVERWRITE settings ON TABLE infra_account
    TYPE object
    DEFAULT {}
    COMMENT "Réglages propres au fournisseur (Scaleway : project_id, organization_id, default_zone, default_region)";

DEFINE FIELD OVERWRITE settings.project_id ON TABLE infra_account TYPE option<uuid> COMMENT "Scaleway : projet qui porte les zones (UUID)";
DEFINE FIELD OVERWRITE settings.organization_id ON TABLE infra_account TYPE option<uuid> COMMENT "Scaleway : organisation (UUID, facultatif)";
DEFINE FIELD OVERWRITE settings.default_zone ON TABLE infra_account TYPE option<string> COMMENT "Scaleway : zone de disponibilité par défaut (fr-par-1)";
DEFINE FIELD OVERWRITE settings.default_region ON TABLE infra_account TYPE option<string> COMMENT "Scaleway : région par défaut (fr-par)";

DEFINE FIELD OVERWRITE state ON TABLE infra_account
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "disabled", "failing"]
    COMMENT "État : active, disabled (aucun appel), failing (clé refusée au dernier essai ou à la dernière passe)";

DEFINE FIELD OVERWRITE last_test ON TABLE infra_account
    TYPE option<object>
    COMMENT "Dernier essai : { at, ok, code }";

DEFINE FIELD OVERWRITE last_test.at ON TABLE infra_account TYPE datetime COMMENT "Date de l'essai";
DEFINE FIELD OVERWRITE last_test.ok ON TABLE infra_account TYPE bool COMMENT "Clé acceptée et zones lues";
DEFINE FIELD OVERWRITE last_test.code ON TABLE infra_account TYPE option<string> COMMENT "Code INFRA_* de l'échec";

DEFINE FIELD OVERWRITE test_requested_at ON TABLE infra_account
    TYPE option<datetime>
    COMMENT "Essai demandé (exécuté par le worker), NONE quand il a été fait";

DEFINE FIELD OVERWRITE discovered_zones ON TABLE infra_account
    TYPE array<object>
    DEFAULT []
    ASSERT array::len($value) <= 1000
    COMMENT "Zones visibles du compte au dernier essai réussi (1 000 au plus) : { name, status }";

DEFINE FIELD OVERWRITE discovered_zones[*].name ON TABLE infra_account TYPE string COMMENT "Nom de la zone (A-label, minuscules)";
DEFINE FIELD OVERWRITE discovered_zones[*].status ON TABLE infra_account TYPE string COMMENT "Statut rendu par le fournisseur (active, pending…)";

DEFINE FIELD OVERWRITE created_at ON TABLE infra_account
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE infra_account
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE infra_account_test ON TABLE infra_account FIELDS test_requested_at;

-- Garde : une écriture directe qui change le chemin de la clé subit les mêmes contrôles que
-- fn::infra_account_create (secret sous infra/, existant, lisible par l'appelant). Clé de
-- l'enregistrement égale à key.
DEFINE EVENT OVERWRITE infra_account_guard ON TABLE infra_account
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    IF $event = "CREATE" AND record::id($after.id) != $after.key { THROW "INFRA_INVALID_PARAMETERS"; };
    IF $event = "CREATE" OR $before.credentials_path != $after.credentials_path {
        LET $refusal = fn::infra__account_secret_refusal($after.credentials_path);
        IF $refusal IS NOT NONE { THROW $refusal; };
    };
};
