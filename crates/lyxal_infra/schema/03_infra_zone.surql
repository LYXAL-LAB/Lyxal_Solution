-- ============================================================================
-- TABLE  : infra_zone
-- MODULE : lyxal_infra
-- RÔLE   : Zones DNS confiées à Lyxal, une par une, par l'administrateur de la plateforme
-- ============================================================================
-- Clé opaque infra_zone:<UUID v7 en 32 chiffres hexadécimaux, sans tiret> : c'est elle qui figure dans les événements et les journaux,
-- jamais le nom de la zone. Une zone commence en mode observe (plan calculé et montré, rien
-- n'écrit) ; l'administrateur la passe en managed. Une passe de réconciliation la réserve
-- (claim, locked_until) : toute écriture du worker exige ce jeton.

DEFINE TABLE OVERWRITE infra_zone
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::infra_can({ action: "read" }) OR fn::infra_can({ action: "declare" }) OR fn::infra_can({ action: "worker" })
        FOR create, delete WHERE fn::infra_can({ action: "manage" })
        FOR update WHERE fn::infra_can({ action: "manage" }) OR fn::infra_can({ action: "worker" })
    COMMENT "Zones DNS rattachées : compte, nom, mode, organisations acceptées, état, réservation et dernier plan";

DEFINE FIELD OVERWRITE account ON TABLE infra_zone
    TYPE record<infra_account>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT "Compte d'hébergeur qui porte la zone";

DEFINE FIELD OVERWRITE name ON TABLE infra_zone
    TYPE string
    READONLY
    ASSERT fn::validation_dns_name($value, false, false, NONE).value == $value
    COMMENT "Nom de la zone (A-label, minuscules, sans point final), unique ; lu sous les permissions de la table, jamais publié dans un événement";

DEFINE FIELD OVERWRITE provider_ref ON TABLE infra_zone
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 255
    COMMENT "Nom de la zone chez le fournisseur";

DEFINE FIELD OVERWRITE mode ON TABLE infra_zone
    TYPE string
    DEFAULT "observe"
    ASSERT $value IN ["observe", "managed"]
    COMMENT "observe : plan calculé et montré, rien n'est écrit ; managed : plan appliqué chez l'hébergeur";

DEFINE FIELD OVERWRITE tenants ON TABLE infra_zone
    TYPE array<record<auth_organization>>
    DEFAULT []
    ASSERT array::len($value) <= 1000
    COMMENT "Organisations dont les déclarations sont acceptées (vide : enregistrements de l'installation seulement)";

DEFINE FIELD OVERWRITE state ON TABLE infra_zone
    TYPE string
    DEFAULT "ok"
    ASSERT $value IN ["ok", "blocked", "not_delegated", "failing", "pending_provider"]
    COMMENT "ok ; blocked (plan au-delà des seuils, en attente d'approbation) ; not_delegated (serveurs de noms de la zone parente différents) ; failing (erreur permanente de l'hébergeur) ; pending_provider (zone pas encore active chez l'hébergeur)";

DEFINE FIELD OVERWRITE nameservers ON TABLE infra_zone
    TYPE array<string>
    DEFAULT []
    ASSERT array::len($value) <= 20
    COMMENT "Serveurs de noms observés chez l'hébergeur";

DEFINE FIELD OVERWRITE delegated ON TABLE infra_zone
    TYPE option<bool>
    COMMENT "Rattachement vérifié auprès de la zone parente (NONE : pas encore vérifié)";

DEFINE FIELD OVERWRITE claim ON TABLE infra_zone
    TYPE option<string>
    COMMENT "Jeton de la passe qui réserve la zone";

DEFINE FIELD OVERWRITE claimed_at ON TABLE infra_zone
    TYPE option<datetime>
    COMMENT "Début de la réservation en cours";

DEFINE FIELD OVERWRITE locked_until ON TABLE infra_zone
    TYPE option<datetime>
    COMMENT "Fin de la réservation (renouvelée par fn::infra_zone_renew)";

DEFINE FIELD OVERWRITE last_plan ON TABLE infra_zone
    TYPE option<object>
    COMMENT "Dernier plan calculé : { hash, at, changes, conflicts, deletions, owned }";

DEFINE FIELD OVERWRITE last_plan.hash ON TABLE infra_zone TYPE string COMMENT "Empreinte SHA-256 du plan (fn::security_hash_object)";
DEFINE FIELD OVERWRITE last_plan.at ON TABLE infra_zone TYPE datetime COMMENT "Date du calcul";
DEFINE FIELD OVERWRITE last_plan.changes ON TABLE infra_zone TYPE array<object> FLEXIBLE COMMENT "Changements : { action, record, provider_id, fqdn, type, value, ttl }";
DEFINE FIELD OVERWRITE last_plan.conflicts ON TABLE infra_zone TYPE array<object> FLEXIBLE COMMENT "Conflits : { record, reason, observed }";
DEFINE FIELD OVERWRITE last_plan.deletions ON TABLE infra_zone TYPE int COMMENT "Nombre de suppressions";
DEFINE FIELD OVERWRITE last_plan.owned ON TABLE infra_zone TYPE int COMMENT "Enregistrements de Lyxal observés dans la zone";

DEFINE FIELD OVERWRITE approved_plan_hash ON TABLE infra_zone
    TYPE option<string>
    COMMENT "Empreinte du plan bloqué approuvé (appliqué une fois)";

DEFINE FIELD OVERWRITE reconcile_requested_at ON TABLE infra_zone
    TYPE option<datetime>
    COMMENT "Passe demandée à partir de cette date (NONE : aucune demande)";

DEFINE FIELD OVERWRITE reconciled_at ON TABLE infra_zone
    TYPE option<datetime>
    COMMENT "Fin de la dernière passe réussie";

DEFINE FIELD OVERWRITE next_reconcile_at ON TABLE infra_zone
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Prochaine passe périodique";

DEFINE FIELD OVERWRITE last_error ON TABLE infra_zone
    TYPE option<object>
    COMMENT "Dernière erreur : { code, at }";

DEFINE FIELD OVERWRITE last_error.code ON TABLE infra_zone TYPE string COMMENT "Code INFRA_*";
DEFINE FIELD OVERWRITE last_error.at ON TABLE infra_zone TYPE datetime COMMENT "Date";

DEFINE FIELD OVERWRITE observed_hash ON TABLE infra_zone
    TYPE option<string>
    COMMENT "Empreinte de la dernière photo de la zone";

DEFINE FIELD OVERWRITE created_at ON TABLE infra_zone
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Rattachement";

DEFINE FIELD OVERWRITE updated_at ON TABLE infra_zone
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE infra_zone_name ON TABLE infra_zone FIELDS name UNIQUE;
DEFINE INDEX OVERWRITE infra_zone_next ON TABLE infra_zone FIELDS next_reconcile_at;
DEFINE INDEX OVERWRITE infra_zone_account ON TABLE infra_zone FIELDS account;

-- Garde de la réservation : tant qu'une réservation court, son jeton ne peut être remplacé que
-- par lui-même (renouvellement) ou retiré ; une autre passe ne la vole pas.
DEFINE EVENT OVERWRITE infra_zone_claim_guard ON TABLE infra_zone
WHEN $event = "UPDATE" AND $before.claim IS NOT NONE AND $after.claim IS NOT NONE AND $before.claim != $after.claim
THEN {
    IF $before.locked_until IS NOT NONE AND $before.locked_until > time::now() { THROW "INFRA_ZONE_CLAIM_LOST"; };
};
