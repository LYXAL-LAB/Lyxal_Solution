-- ============================================================================
-- FONCTIONS : envois reprenables
-- MODULE    : lyxal_storage
-- ============================================================================
-- Un envoi reprenable est une fiche à l'état pending ouverte avec resumable (fn::storage_object_begin).
-- Ses octets arrivent en plusieurs requêtes : chaque partie écrite sur le support est inscrite
-- par fn::storage_upload_part_add. Quand toutes les parties sont là, l'assembleur (l'auteur de
-- l'envoi ou le worker) réserve l'assemblage (fn::storage_upload_claim, qui rend un jeton), relit les parties dans
-- l'ordre (fn::storage_upload_part_list), écrit le fichier et termine par fn::storage_object_commit.

-- ----------------------------------------------------------------------------
-- fn::storage_upload_offset (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_offset($object: record<storage_object>, $except: option<record<storage_upload_part>>) -> int {
    RETURN math::sum(SELECT VALUE size FROM storage_upload_part WHERE object = $object AND id != $except);
} COMMENT "Interne : position d'un envoi reprenable ($object) : somme des tailles de ses parties, hors la partie $except";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_claimed (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_claimed($object: object) -> bool {
    RETURN $object.upload_claimed_until IS NOT NONE AND $object.upload_claimed_until > time::now();
} COMMENT "Interne : vrai si l'assemblage de cet envoi ($object) est réservé et en cours";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_allowed (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_allowed($object: object) -> bool {
    RETURN fn::storage_can({ action: "worker" })
        OR (fn::storage_object_is_author($object) AND fn::storage_can({ action: "write", tenant: $object.tenant }));
} COMMENT "Interne : vrai si l'appelant peut poursuivre cet envoi ($object) : son auteur, s'il a toujours le droit d'écriture, ou le worker";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_view($object: object) -> object {
    LET $settings = fn::storage_settings_effective({ tenant: $object.tenant });
    LET $offset = IF $object.state = "pending" { fn::storage_upload_offset($object.id, NONE) } ELSE { $object.size };
    RETURN {
        id: $object.id, state: $object.state, backend: $object.backend, path: $object.path,
        declared_type: $object.declared_type, length: $object.declared_size, offset: $offset,
        complete: $offset = $object.declared_size,
        max_size: (SELECT VALUE max_object_size FROM ONLY $object.bucket) ?? $settings.max_object_size,
        expires_at: $object.pending_expires_at
    };
} COMMENT "Interne : état d'un envoi reprenable ($object) : { id, state, backend, path, declared_type, length, offset, complete, max_size, expires_at }";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_part_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_part_refusal($part: object) -> option<object> {
    LET $object = (SELECT * FROM ONLY $part.object);
    IF $object == NONE { RETURN { code: "STORAGE_OBJECT_NOT_FOUND", details: { object: <string> $part.object } }; };
    IF !fn::storage_upload_allowed($object) { RETURN { code: "STORAGE_PERMISSION_DENIED", details: {} }; };
    IF !$object.resumable OR $object.state != "pending" {
        RETURN { code: "STORAGE_OBJECT_STATE_INVALID", details: { state: $object.state, expected: "pending" } };
    };
    IF $object.pending_expires_at <= time::now() { RETURN { code: "STORAGE_UPLOAD_EXPIRED", details: {} }; };
    IF fn::storage_upload_claimed($object) { RETURN { code: "STORAGE_UPLOAD_BUSY", details: {} }; };
    LET $offset = fn::storage_upload_offset($object.id, $part.id);
    IF $part.offset != $offset { RETURN { code: "STORAGE_UPLOAD_OFFSET_MISMATCH", details: { offset: $offset } }; };
    IF $part.offset + $part.size > $object.declared_size {
        RETURN { code: "STORAGE_CONTENT_MISMATCH", details: { length: $object.declared_size } };
    };
    IF array::len(SELECT VALUE id FROM storage_upload_part WHERE object = $object.id AND id != $part.id) >= 10000 {
        RETURN { code: "STORAGE_UPLOAD_TOO_MANY_PARTS", details: { max_parts: 10000 } };
    };
    RETURN NONE;
} COMMENT "Interne : garde de l'inscription d'une partie ($part : { id, object, offset, size }), appelée par fn::storage_upload_part_add et par l'événement storage_upload_part_guard ; NONE, ou { code, details } du refus : envoi en cours et non expiré, appelant autorisé, position égale à la position courante, taille annoncée respectée, 10 000 parties au plus";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $object = (SELECT * FROM ONLY $p.object);
    -- Un envoi abandonné, expiré ou retiré n'existe plus pour le client
    IF $object == NONE OR !$object.resumable OR $object.state NOTINSIDE ["pending", "available"] {
        RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object });
    };
    IF !fn::storage_upload_allowed($object) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    IF $object.state = "pending" AND $object.pending_expires_at <= time::now() AND !fn::storage_upload_claimed($object) {
        RETURN fn::error_result("STORAGE_UPLOAD_EXPIRED", $p.language, {});
    };
    RETURN fn::result_ok(fn::storage_upload_view($object));
} COMMENT "État d'un envoi reprenable ({ object }) : { id, state (pending, ou available une fois assemblé), backend, path, declared_type, length, offset, complete, max_size, expires_at } ; un envoi abandonné ou retiré est introuvable, un envoi hors délai est refusé (STORAGE_UPLOAD_EXPIRED). Droit : auteur de l'envoi, ou worker";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_part_add
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_part_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            offset: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            size: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
            name: { pipeline: [{ rule: "uuid" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $refusal = fn::storage_upload_part_refusal({ id: NONE, object: $p.object, offset: $p.offset, size: $p.size });
    IF $refusal IS NOT NONE { RETURN fn::error_result($refusal.code, $p.language, $refusal.details); };
    -- Deux requêtes simultanées sur la même position : l'index unique n'en laisse passer qu'une
    LET $inserted = (INSERT IGNORE INTO storage_upload_part { object: $p.object, offset: $p.offset, size: $p.size, name: $p.name });
    IF array::len($inserted) = 0 {
        LET $offset = fn::storage_upload_offset($p.object, NONE);
        RETURN IF $offset != $p.offset {
            fn::error_result("STORAGE_UPLOAD_OFFSET_MISMATCH", $p.language, { offset: $offset })
        } ELSE {
            fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_upload_part" })
        };
    };
    RETURN fn::result_ok(fn::storage_upload_view(SELECT * FROM ONLY $p.object));
} COMMENT "Inscrit une partie écrite sur le support ({ object, offset, size, name }) et rend l'état de l'envoi (fn::storage_upload_get) ; refus si l'envoi n'est plus en cours, est hors délai (STORAGE_UPLOAD_EXPIRED) ou en cours d'assemblage (STORAGE_UPLOAD_BUSY), si la position n'est pas la position courante (STORAGE_UPLOAD_OFFSET_MISMATCH, details.offset), si la taille annoncée est dépassée ou au-delà de 10 000 parties. Droit : auteur de l'envoi, ou worker";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_part_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_part_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $object = (SELECT * FROM ONLY $p.object);
    IF $object == NONE OR !$object.resumable { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    IF !fn::storage_upload_allowed($object) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok({ items: (SELECT offset, size, name FROM storage_upload_part WHERE object = $object.id ORDER BY offset) });
} COMMENT "Parties d'un envoi reprenable ({ object }), dans l'ordre du fichier : { items: [{ offset, size, name }] }. Droit : auteur de l'envoi, ou worker";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_claim
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_claim($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            seconds: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 86400 } }], default: 1800 },
            claim: { pipeline: [{ rule: "uuid" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $object = (SELECT * FROM ONLY $p.object);
    IF $object == NONE OR !$object.resumable { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    IF !fn::storage_upload_allowed($object) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    IF $object.state != "pending" {
        RETURN fn::error_result("STORAGE_OBJECT_STATE_INVALID", $p.language, { state: $object.state, expected: "pending" });
    };
    LET $until = time::now() + duration::from_secs($p.seconds);
    IF $p.claim IS NOT NONE {
        -- Prolongation : seulement par le détenteur d'une réservation toujours en cours
        IF $p.claim != $object.upload_claim OR !fn::storage_upload_claimed($object) { RETURN fn::error_result("STORAGE_UPLOAD_BUSY", $p.language, {}); };
        LET $renewed = (UPDATE ONLY $object.id SET upload_claimed_until = $until);
        IF $renewed == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
        RETURN fn::result_ok(object::extend(fn::storage_upload_view($renewed), { claim: $renewed.upload_claim }));
    };
    IF fn::storage_upload_claimed($object) { RETURN fn::error_result("STORAGE_UPLOAD_BUSY", $p.language, {}); };
    IF $object.pending_expires_at <= time::now() { RETURN fn::error_result("STORAGE_UPLOAD_EXPIRED", $p.language, {}); };
    LET $offset = fn::storage_upload_offset($object.id, NONE);
    IF $offset != $object.declared_size {
        RETURN fn::error_result("STORAGE_UPLOAD_OFFSET_MISMATCH", $p.language, { offset: $offset });
    };
    LET $claimed = (UPDATE ONLY $object.id SET upload_claimed_until = $until, upload_claim = rand::uuid::v7());
    IF $claimed == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
    RETURN fn::result_ok(object::extend(fn::storage_upload_view($claimed), { claim: $claimed.upload_claim }));
} COMMENT "Réserve l'assemblage d'un envoi reprenable complet ({ object, seconds (1800) }) et rend son état avec le jeton de la réservation (claim) : un seul assembleur à la fois (STORAGE_UPLOAD_BUSY), aucune partie n'est plus acceptée et l'envoi n'expire pas pendant la réservation ; refus si des octets manquent (STORAGE_UPLOAD_OFFSET_MISMATCH). Avec claim : prolonge la réservation, si ce jeton est toujours celui en cours (sinon STORAGE_UPLOAD_BUSY : l'assemblage a été repris par un autre). Droit : auteur de l'envoi, ou worker";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_release
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_release($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            claim: { pipeline: [{ rule: "uuid" }], required: true },
            abandon: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $object = (SELECT * FROM ONLY $p.object);
    IF $object == NONE OR !$object.resumable { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    IF !fn::storage_upload_allowed($object) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    -- Seul le détenteur de la réservation en cours la rend ou abandonne l'envoi
    IF $object.state != "pending" OR $p.claim != $object.upload_claim { RETURN fn::error_result("STORAGE_UPLOAD_BUSY", $p.language, {}); };
    LET $updated = IF $p.abandon {
        (UPDATE ONLY $object.id SET state = "deleted", deleted_at = time::now(), purge_after = time::now(), pending_expires_at = NONE, upload_claimed_until = NONE, upload_claim = NONE)
    } ELSE {
        (UPDATE ONLY $object.id SET upload_claimed_until = NONE, upload_claim = NONE)
    };
    IF $updated == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
    RETURN fn::result_ok({ released: true, abandoned: $p.abandon });
} COMMENT "Rend la réservation d'assemblage d'un envoi reprenable ({ object, claim, abandon }) : après un échec passager, l'envoi reste complet et sera assemblé plus tard ; avec abandon (contenu refusé), l'envoi passe à l'état deleted. Refus si le jeton n'est plus celui de la réservation en cours (STORAGE_UPLOAD_BUSY) : rien n'est modifié. Droit : auteur de l'envoi, ou worker";

-- ----------------------------------------------------------------------------
-- fn::storage_upload_ready_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_upload_ready_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $ready = (SELECT VALUE id FROM storage_object
        WHERE state = "pending" AND resumable = true AND pending_expires_at > $now
            AND (upload_claimed_until IS NONE OR upload_claimed_until <= $now)
            AND fn::storage_upload_offset(id, NONE) = declared_size
        ORDER BY created_at LIMIT $p.limit);
    RETURN fn::result_ok({ items: $ready });
} COMMENT "Envois reprenables complets dont l'assemblage n'est ni fait ni en cours ({ limit }), du plus ancien au plus récent : { items: [identifiants] } ; le worker les assemble. Droit : worker";
