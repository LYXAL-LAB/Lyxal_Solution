-- ============================================================================
-- Socle installé (table runtime_foundation, enregistrement unique runtime_foundation:current).
-- Le socle (lyxal_core, lyxal_error, schéma du runtime) est installé sous le bail d'installation
-- de clé réservée « foundation » ; son empreinte est écrite ici par le nœud qui détient ce bail.
-- Les autres nœuds la lisent à chaque battement : une empreinte différente de celle de leur
-- binaire signifie qu'un autre binaire a remplacé le socle.
-- Entrées validées par le moteur de lyxal_core (fn::validation_object_execute).
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_foundation_record($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            checksum: { pipeline: [{ rule: "regex", options: { pattern: "^[0-9a-f]{64}$" } }], required: true },
            host: { pipeline: [{ rule: "regex", options: { pattern: "^[a-z][a-z0-9_]{0,63}$" } }], required: true },
            node_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            generation: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;

    -- Garde du bail d'installation du socle : seul le nœud qui le détient, dans cette génération,
    -- non expiré à l'heure de la base, écrit l'empreinte
    LET $now = time::unix(time::now());
    LET $guard = UPDATE type::record("runtime_lease", ["installation", "foundation"]) SET
        updated_at = time::now()
    WHERE owner_node_id = $p.node_id
      AND generation = $p.generation
      AND is_released = false
      AND expires_at > $now
    RETURN AFTER;
    IF array::len($guard) = 0 {
        RETURN fn::error_result("RUNTIME_LEASE_FENCED", $p.language, { lock_key: "foundation" });
    };

    LET $saved = UPSERT runtime_foundation:current CONTENT {
        checksum: $p.checksum,
        host: $p.host,
        node_id: $p.node_id,
        installed_at: time::now()
    } RETURN AFTER;
    -- Écriture filtrée (session sans droit sur la table) : jamais de succès annoncé
    IF array::len($saved) = 0 {
        RETURN fn::error_result("RUNTIME_WRITE_FORBIDDEN", $p.language, { table: "runtime_foundation" });
    };
    RETURN fn::result_ok($saved[0].{ checksum, host, node_id, installed_at });
} COMMENT "Enregistre le socle installé ({ checksum : empreinte SHA-256, host, node_id, generation }) sous le bail d'installation « foundation » (node_id, generation) : RUNTIME_LEASE_FENCED si le bail n'est pas détenu. Renvoie { checksum, host, node_id, installed_at }. Écriture refusée par les permissions : RUNTIME_WRITE_FORBIDDEN."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_foundation_clear($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            node_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            generation: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;

    -- Table en PERMISSIONS NONE : une session d'accès (utilisateur, jeton) verrait sa suppression
    -- filtrée sans erreur ; elle est refusée au lieu d'annoncer un succès
    IF $access != NONE {
        RETURN fn::error_result("RUNTIME_WRITE_FORBIDDEN", $p.language, { table: "runtime_foundation" });
    };

    -- Même garde que fn::runtime_foundation_record
    LET $now = time::unix(time::now());
    LET $guard = UPDATE type::record("runtime_lease", ["installation", "foundation"]) SET
        updated_at = time::now()
    WHERE owner_node_id = $p.node_id
      AND generation = $p.generation
      AND is_released = false
      AND expires_at > $now
    RETURN AFTER;
    IF array::len($guard) = 0 {
        RETURN fn::error_result("RUNTIME_LEASE_FENCED", $p.language, { lock_key: "foundation" });
    };

    LET $removed = DELETE runtime_foundation:current RETURN BEFORE;
    RETURN fn::result_ok({ cleared: array::len($removed) > 0 });
} COMMENT "Efface l'empreinte du socle installé ({ node_id, generation }) sous le bail d'installation « foundation », avant de remplacer le socle : une installation interrompue laisse ainsi la base sans empreinte, et le prochain démarrage réinstalle le socle. { cleared } : faux si aucune empreinte n'était enregistrée. RUNTIME_LEASE_FENCED si le bail n'est pas détenu ; appel hors de la session système : RUNTIME_WRITE_FORBIDDEN."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_foundation_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };

    RETURN fn::result_ok(SELECT checksum, host, node_id, installed_at FROM ONLY runtime_foundation:current);
} COMMENT "Socle installé dans la base : { checksum, host, node_id, installed_at }, ou NONE si aucun socle n'a été enregistré."
PERMISSIONS FULL;
