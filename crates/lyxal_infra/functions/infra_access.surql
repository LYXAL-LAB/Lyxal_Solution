-- ============================================================================
-- FONCTIONS : droits, auteur, réglages effectifs, aides communes
-- MODULE    : lyxal_infra
-- ============================================================================
-- Contrôle unique des droits, utilisé par les PERMISSIONS des tables et par les fonctions
-- publiques. Toutes les permissions de lyxal_infra portent sur l'installation (aucun droit
-- d'organisation en V1, décision I11).

-- ----------------------------------------------------------------------------
-- fn::infra_can
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_can($params: object) -> bool {
    IF fn::auth_session_valid({}).system { RETURN true; };
    IF $params.action = "read" {
        RETURN fn::auth_has_permission({ permission: "infra.read" }) OR fn::auth_has_permission({ permission: "infra.manage" });
    };
    LET $permission = { manage: "infra.manage", declare: "infra.records.declare", worker: "infra.worker" }[$params.action];
    IF $permission IS NONE { RETURN false; };
    RETURN fn::auth_has_permission({ permission: $permission });
} COMMENT "Vrai si l'appelant peut effectuer l'action ({ action : read (infra.read ou infra.manage), manage (infra.manage), declare (infra.records.declare), worker (infra.worker) }) ; session système : tout. Jamais d'erreur";

-- ----------------------------------------------------------------------------
-- fn::infra__actor (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__actor() -> string {
    LET $context = fn::auth_context({});
    IF !$context.ok { RETURN "unknown"; };
    IF $context.data.system { RETURN "system"; };
    IF $context.data.identity IS NOT NONE { RETURN <string> $context.data.identity; };
    IF $context.data.application IS NOT NONE { RETURN <string> $context.data.application; };
    RETURN "unknown";
} COMMENT "Interne : auteur noté au journal (contrat public fn::auth_context) : system, identité (auth_identity:…), application d'un compte de service (auth_application:…), sinon unknown";

-- ----------------------------------------------------------------------------
-- fn::infra__language (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__language($params: any) -> option<string> {
    RETURN IF type::is_object($params) AND fn::validation_language_code($params.language, false, NONE).valid { $params.language } ELSE { NONE };
} COMMENT "Interne : langue d'une réponse d'erreur quand les paramètres sont refusés (la langue demandée si elle est valide, sinon celle de l'erreur)";

-- ----------------------------------------------------------------------------
-- fn::infra__invalid (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__invalid($params: any, $fields: any) -> object {
    RETURN fn::error_result("INFRA_INVALID_PARAMETERS", fn::infra__language($params), { fields: $fields ?? {} });
} COMMENT "Interne : erreur INFRA_INVALID_PARAMETERS avec le détail par champ du rapport de lyxal_core";

-- ----------------------------------------------------------------------------
-- fn::infra__clean (interne)
-- ----------------------------------------------------------------------------
-- Une valeur NONE disparaît d'un objet enregistré : l'empreinte d'une entrée du journal serait
-- calculée sur un objet différent de celui relu. Les NONE deviennent NULL, conservé tel quel.

DEFINE FUNCTION OVERWRITE fn::infra__clean($item: any) -> any {
    IF $item IS NONE { RETURN NULL; };
    IF type::is_record($item) { RETURN <string> $item; };
    IF type::is_object($item) { RETURN object::from_entries(array::map(object::entries($item), |$e| [$e[0], fn::infra__clean($e[1])])); };
    IF type::is_array($item) { RETURN array::map($item, |$v| fn::infra__clean($v)); };
    RETURN $item;
} COMMENT "Interne : remplace récursivement NONE par NULL et un identifiant d'enregistrement par son texte (contenu du journal identique avant et après enregistrement)";

-- ----------------------------------------------------------------------------
-- fn::infra__settings (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__settings() -> object {
    LET $row = (SELECT * FROM ONLY infra_settings:installation) ?? {};
    RETURN {
        reconcile_minutes: $row.reconcile_minutes ?? 15,
        default_ttl: $row.default_ttl ?? 3600,
        min_ttl: $row.min_ttl ?? 60,
        max_deletions: $row.max_deletions ?? 10,
        max_deletion_percent: $row.max_deletion_percent ?? 30,
        verify_timeout_hours: $row.verify_timeout_hours ?? 24,
        requests_per_second: $row.requests_per_second ?? 5,
        change_retention_days: $row.change_retention_days ?? 400,
        released_retention_days: $row.released_retention_days ?? 30
    };
} COMMENT "Interne : réglages effectifs (fiche infra_settings:installation, sinon valeurs par défaut : passe toutes les 15 min, ttl 3 600 s (60 au moins), 10 suppressions ou 30 %, 24 h de vérification, 5 requêtes par seconde, journal 400 jours, retraits 30 jours)";

-- ----------------------------------------------------------------------------
-- fn::infra__covering_zone (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__covering_zone($fqdn: string) -> option<object> {
    -- Zones candidates : le nom lui-même et chacun de ses suffixes (index unique sur name)
    LET $labels = string::split($fqdn, ".");
    LET $candidates = array::map(<array>(0..(array::len($labels) - 1)), |$i| array::join(array::slice($labels, $i), "."));
    LET $zones = (SELECT id, name, tenants, mode, state FROM infra_zone WHERE name IN $candidates);
    -- Plus long nom d'abord (zones emboîtées refusées au rattachement : une seule en pratique)
    RETURN array::first(fn::utils_collection_sort_by(array::map($zones, |$z| object::extend($z, { length: string::len($z.name) })), "length", "desc"));
} COMMENT "Interne : zone rattachée qui couvre le nom ($fqdn égal à la zone ou sous-nom), { id, name, tenants, mode, state, length } ; NONE si aucune";
