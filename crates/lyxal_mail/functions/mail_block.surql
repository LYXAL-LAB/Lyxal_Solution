-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : liste de blocage de l'installation
-- MODULE    : lyxal_mail
-- ============================================================================
-- Réseaux refusés à l'acceptation par tous les nœuds (décision S18). Entrées manuelles :
-- administrateur de la plateforme (mail.installation.manage). Bannissements automatiques (motif
-- errors, harvest ou smuggling) : service du courrier (session système, mail.worker), pour une
-- durée d'une heure doublée à chaque récidive jusqu'à vingt-quatre heures. Un réseau est une
-- plage CIDR validée par lyxal_core (règle cidr), rangée en minuscules telle qu'elle est donnée.

-- ----------------------------------------------------------------------------
-- fn::mail_block_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_block_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            network: { pipeline: [{ rule: "cidr", options: { allow_ipv4: true, allow_ipv6: true } }], required: true },
            reason: { pipeline: [{ rule: "enum", options: { allowed: ["manual", "errors", "harvest", "smuggling"], case_sensitive: true } }], default: "manual" },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $manual = $p.reason = "manual";
    IF !fn::mail_can({ action: IF $manual { "manage" } ELSE { "worker" } }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $existing = (SELECT * FROM ONLY mail_network_block WHERE network = $p.network LIMIT 1);
    IF $manual {
        IF $existing IS NOT NONE { RETURN fn::error_result("MAIL_BLOCK_EXISTS", $p.language, { network: $p.network }); };
        LET $context = fn::auth_context({});
        LET $created = (CREATE ONLY mail_network_block CONTENT {
            network: $p.network, reason: "manual", expires_at: $p.expires_at,
            created_by: IF $context.ok { $context.data.identity } ELSE { NONE }
        });
        IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_network_block" }); };
        RETURN fn::result_ok($created);
    };
    -- Une entrée manuelle n'est jamais changée par un bannissement automatique
    IF $existing IS NOT NONE AND $existing.reason = "manual" { RETURN fn::result_ok($existing); };
    -- Récidive : une heure doublée à chaque bannissement, vingt-quatre heures au plus
    LET $strikes = ($existing.strikes ?? 0) + 1;
    LET $until = $p.expires_at ?? (time::now() + duration::from_hours(math::min([24, math::pow(2, math::min([$strikes - 1, 5]))])));
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY mail_network_block CONTENT { network: $p.network, reason: $p.reason, strikes: 1, expires_at: $until })
    } ELSE {
        (UPDATE ONLY $existing.id SET strikes = $strikes, expires_at = $until)
    };
    IF $saved == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_network_block" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Bloque un réseau ({ network (plage CIDR IPv4 ou IPv6), reason (manual par défaut ; errors, harvest, smuggling), expires_at (fin, à venir) }). Entrée manuelle : sans fin si expires_at est absent ; réseau déjà dans la liste : MAIL_BLOCK_EXISTS ; droit : mail.installation.manage. Bannissement automatique (reason autre que manual) : réseau nouveau : 1 h (ou expires_at) ; réseau déjà banni : strikes incrémenté, durée doublée à chaque récidive (1 h, 2 h, 4 h… 24 h au plus) à compter de maintenant, motif d'origine gardé ; réseau bloqué par une entrée manuelle : inchangée ; droit : session système, compte de service. Rend l'entrée";

-- ----------------------------------------------------------------------------
-- fn::mail_block_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_block_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            after: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 200 } }], default: 50 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "manage" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT * FROM mail_network_block WHERE $p.after IS NONE OR network > $p.after ORDER BY network LIMIT $p.limit + 1);
    LET $items = array::slice($rows, 0, $p.limit);
    RETURN fn::result_ok({ items: $items, next: IF array::len($rows) > $p.limit { array::last($items).network } ELSE { NONE } });
} COMMENT "Liste de blocage ({ after (curseur : réseau), limit (50, 200 au plus) }), entrées échues comprises, triée par réseau (unique) ; { items, next } (next : curseur de la page suivante, NONE à la fin). Droit : mail.installation.manage";

-- ----------------------------------------------------------------------------
-- fn::mail_block_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_block_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            network: { pipeline: [{ rule: "cidr", options: { allow_ipv4: true, allow_ipv6: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "manage" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $existing = (SELECT VALUE id FROM ONLY mail_network_block WHERE network = $p.network LIMIT 1);
    IF $existing IS NONE { RETURN fn::error_result("MAIL_BLOCK_NOT_FOUND", $p.language, { network: $p.network }); };
    LET $deleted = (DELETE ONLY $existing RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_network_block" }); };
    RETURN fn::result_ok({ deleted: true });
} COMMENT "Retire un réseau de la liste de blocage ({ network }), entrée manuelle ou bannissement automatique ; MAIL_BLOCK_NOT_FOUND. Droit : mail.installation.manage";

-- ----------------------------------------------------------------------------
-- fn::mail_block_active
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_block_active($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok({ networks: (SELECT VALUE network FROM mail_network_block WHERE expires_at IS NONE OR expires_at > time::now() ORDER BY network LIMIT 100000) });
} COMMENT "Réseaux bloqués en vigueur (entrées sans fin ou non échues), triés, 100 000 au plus : { networks }. Lue par chaque nœud au démarrage puis toutes les 30 s. Droit : session système, compte de service";
