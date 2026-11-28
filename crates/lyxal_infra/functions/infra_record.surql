-- ============================================================================
-- FONCTIONS : enregistrements voulus (contrat public des modules, administration)
-- MODULE    : lyxal_infra
-- ============================================================================
-- Contrat public stable (README.md) : fn::infra_records_declare, fn::infra_records_release,
-- fn::infra_records_status, fn::infra_records_subjects. Appelées souvent (worker du courrier) :
-- entrées contrôlées par fn::validation_fields_execute (contrôles par fermetures). Les valeurs
-- sont mises en forme canonique et contrôlées type par type (fn::infra__record_value).

-- ----------------------------------------------------------------------------
-- fn::infra__record_key (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__record_key($owner: string, $subject: string, $fqdn: string, $type: string) -> record<infra_record> {
    RETURN type::record("infra_record", string::slice(fn::security_hash_string(string::join("\n", $owner, $subject, $fqdn, $type), "blake3"), 0, 32));
} COMMENT "Interne : clé d'un enregistrement voulu, 32 premiers chiffres hexadécimaux du BLAKE3 de owner, subject, fqdn et type (sans nom en clair dans l'identifiant)";

-- ----------------------------------------------------------------------------
-- fn::infra__number (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__number($text: string, $min: int, $max: int) -> object {
    IF !string::is_numeric($text) OR string::len($text) > 10 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "integer" } }; };
    RETURN fn::validation_integer(<int> $text, $min, $max);
} COMMENT "Interne : champ numérique d'une valeur DNS (priorité, poids, port, drapeaux) : chiffres seulement, puis bornes par fn::validation_integer";

-- ----------------------------------------------------------------------------
-- fn::infra__record_value (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__record_value($type: string, $raw: string) -> object {
    LET $bad = { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { type: $type } };
    IF $type = "A" { RETURN fn::validation_ip($raw, "ipv4"); };
    IF $type = "AAAA" {
        LET $ip = fn::validation_ip($raw, "ipv6");
        RETURN IF $ip.valid { object::extend($ip, { value: fn::sanitize_lowercase($ip.value) }) } ELSE { $ip };
    };
    IF $type = "CNAME" { RETURN fn::validation_dns_name($raw, true, false, NONE); };
    IF $type = "TXT" {
        LET $length = fn::validation_required_string($raw, 1, 4096);
        IF !$length.valid { RETURN $length; };
        LET $ascii = fn::validation_ascii($raw, false, false);
        IF !$ascii.valid { RETURN $ascii; };
        IF fn::security_detect_header_injection($raw).detected { RETURN object::extend($bad, { code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "line_break" } }); };
        RETURN { valid: true, value: $raw, code: NONE, details: {} };
    };
    LET $parts = string::split(string::trim($raw), " ");
    IF $type = "MX" {
        IF array::len($parts) != 2 { RETURN $bad; };
        LET $priority = fn::infra__number($parts[0], 0, 65535);
        IF !$priority.valid { RETURN $priority; };
        LET $target = fn::validation_dns_name($parts[1], false, false, NONE);
        IF !$target.valid { RETURN $target; };
        RETURN { valid: true, value: string::join(" ", <string> $priority.value, $target.value), code: NONE, details: {} };
    };
    IF $type = "SRV" {
        IF array::len($parts) != 4 { RETURN $bad; };
        LET $numbers = array::map(array::slice($parts, 0, 3), |$n| fn::infra__number($n, 0, 65535));
        LET $wrong = array::first(array::filter($numbers, |$n| !$n.valid));
        IF $wrong IS NOT NONE { RETURN $wrong; };
        LET $target = fn::validation_dns_name($parts[3], false, false, NONE);
        IF !$target.valid { RETURN $target; };
        RETURN { valid: true, value: array::join(array::concat(array::map($numbers, |$n| <string> $n.value), [$target.value]), " "), code: NONE, details: {} };
    };
    IF $type = "CAA" {
        IF array::len($parts) < 3 { RETURN $bad; };
        LET $flags = fn::infra__number($parts[0], 0, 255);
        IF !$flags.valid { RETURN $flags; };
        LET $tag = fn::validation_enum($parts[1], ["issue", "issuewild", "iodef"], true);
        IF !$tag.valid { RETURN $tag; };
        -- Valeur entre guillemets, sans guillemet intérieur
        LET $quoted = array::join(array::slice($parts, 2), " ");
        IF string::len($quoted) < 2 OR !string::starts_with($quoted, "\"") OR !string::ends_with($quoted, "\"") { RETURN $bad; };
        LET $inner = string::slice($quoted, 1, string::len($quoted) - 1);
        IF string::contains($inner, "\"") { RETURN $bad; };
        LET $ascii = fn::validation_ascii($inner, false, true);
        IF !$ascii.valid { RETURN $ascii; };
        LET $length = fn::validation_required_string($quoted, 2, 255);
        IF !$length.valid { RETURN $length; };
        RETURN { valid: true, value: string::concat(<string> $flags.value, " ", $tag.value, " ", $quoted), code: NONE, details: {} };
    };
    RETURN object::extend($bad, { code: "CORE_VALIDATION_NOT_ALLOWED" });
} COMMENT "Interne : valeur d'un enregistrement contrôlée et mise en forme canonique selon son type (A : IPv4 ; AAAA : IPv6 en minuscules ; CNAME : nom DNS ; MX : « <priorité 0-65535> <cible> » ; TXT : ASCII, 4 096 octets au plus, sans retour de ligne ; SRV : « <priorité> <poids> <port> <cible> » ; CAA : « <drapeaux 0-255> <issue|issuewild|iodef> \"<valeur>\" ») ; rend { valid, value, code, details } de lyxal_core";

-- ----------------------------------------------------------------------------
-- fn::infra__declared_item (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__declared_item($item: any, $index: int, $settings: object) -> object {
    LET $path = "records[" + <string> $index + "]";
    LET $report = fn::validation_fields_execute($item, {
        fqdn: { checks: [|$v: any| fn::validation_dns_name($v, true, false, NONE)], required: true },
        type: { checks: [|$v: any| fn::validation_enum($v, ["A", "AAAA", "CNAME", "MX", "TXT", "SRV", "CAA"], false)], required: true },
        values: { checks: [|$v: any| fn::validation_array_of_strings($v, false, 1, 4096), |$v: any| fn::validation_array_length($v, 1, 20)], required: true },
        ttl: { checks: [|$v: any| fn::validation_integer($v, $settings.min_ttl, 86400)], default: $settings.default_ttl },
        mode: { checks: [|$v: any| fn::validation_enum($v, ["exclusive", "shared"], true)], required: true },
        singleton_prefix: { checks: [|$v: any| fn::validation_ascii($v, true, false), |$v: any| fn::validation_required_string($v, 1, 32)] }
    }, "reject");
    IF !$report.valid {
        RETURN { valid: false, value: NONE, errors: object::from_entries(array::map(object::entries($report.by_field), |$e| [$path + "." + $e[0], $e[1]])) };
    };
    LET $r = object::extend($report.value, { type: fn::sanitize_uppercase($report.value.type) });
    LET $checked = array::map($r.values, |$raw| fn::infra__record_value($r.type, $raw));
    LET $wrong = array::filter(array::map($checked, |$c, $i| [$path + ".values[" + <string> $i + "]", $c]), |$e| !$e[1].valid);
    IF array::len($wrong) > 0 {
        RETURN { valid: false, value: NONE, errors: object::from_entries(array::map($wrong, |$e| [$e[0], [$e[1].code]])) };
    };
    LET $values = array::sort(array::distinct($checked.value));
    -- Règles du type : un CNAME a une seule valeur et ne cohabite avec rien (exclusif) ; un préfixe
    -- unique ne vaut que pour un TXT partagé
    IF $r.type = "CNAME" AND (array::len($values) != 1 OR $r.mode != "exclusive") {
        RETURN { valid: false, value: NONE, errors: object::from_entries([[$path, ["CORE_VALIDATION_NOT_ALLOWED"]]]) };
    };
    IF $r.singleton_prefix IS NOT NONE AND ($r.type != "TXT" OR $r.mode != "shared"
        OR !array::all($values, |$v| string::starts_with($v, $r.singleton_prefix))) {
        RETURN { valid: false, value: NONE, errors: object::from_entries([[$path + ".singleton_prefix", ["CORE_VALIDATION_NOT_ALLOWED"]]]) };
    };
    RETURN { valid: true, value: object::extend($r, { values: $values }), errors: {} };
} COMMENT "Interne : enregistrement d'une déclaration ($item, rang $index) contrôlé par fn::validation_fields_execute (fqdn, type, values 1 à 20, ttl entre min_ttl et 86 400, défaut default_ttl, mode, singleton_prefix) puis valeur par valeur (fn::infra__record_value), valeurs dédoublonnées et triées ; CNAME : une valeur, exclusif ; préfixe unique : TXT partagé dont toutes les valeurs le portent. Rend { valid, value, errors (par chemin) }";

-- ----------------------------------------------------------------------------
-- fn::infra__contract_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__contract_refusal($owner: string) -> option<string> {
    IF $owner = "manual" {
        RETURN IF fn::infra_can({ action: "manage" }) { NONE } ELSE { "INFRA_PERMISSION_DENIED" };
    };
    RETURN IF fn::infra_can({ action: "declare" }) { NONE } ELSE { "INFRA_PERMISSION_DENIED" };
} COMMENT "Interne : NONE si l'appelant peut user du contrat public pour ce propriétaire (manual : infra.manage ; module : infra.records.declare ; session système : tout), sinon INFRA_PERMISSION_DENIED";

-- ----------------------------------------------------------------------------
-- fn::infra__declare_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__declare_refusal($p: object, $items: array) -> option<object> {
    -- Doublons (nom, type) dans la déclaration
    LET $keys = array::map($items, |$r| $r.fqdn + " " + $r.type);
    LET $unique = fn::validation_array_unique($keys);
    IF !$unique.valid { RETURN { code: "INFRA_INVALID_PARAMETERS", details: { fields: { records: [$unique.code] } } }; };
    -- Autres déclarations actives (autre propriétaire ou autre sujet) des mêmes noms
    LET $fqdns = array::distinct($items.fqdn);
    LET $others = (SELECT owner, subject, fqdn, type, mode, values, singleton_prefix, state FROM infra_record
        WHERE fqdn IN $fqdns AND state != "released" AND (owner != $p.owner OR subject != $p.subject));
    LET $all = array::concat($items, $others);
    -- Un CNAME ne cohabite avec rien
    LET $cname = array::first(array::filter($items, |$r| array::any($all, |$o| $o.fqdn = $r.fqdn AND $o.type != $r.type AND ($o.type = "CNAME" OR $r.type = "CNAME"))));
    IF $cname IS NOT NONE { RETURN { code: "INFRA_RECORD_CNAME_CONFLICT", details: { index: array::find_index($items, $cname) } }; };
    -- Même (nom, type) chez un autre propriétaire : refusé si l'un des deux le veut en entier
    LET $owned = array::first(array::filter($items, |$r| array::any($others, |$o| $o.fqdn = $r.fqdn AND $o.type = $r.type AND ($o.mode = "exclusive" OR $r.mode = "exclusive"))));
    IF $owned IS NOT NONE { RETURN { code: "INFRA_RECORD_OWNED", details: { index: array::find_index($items, $owned) } }; };
    -- Préfixe unique d'un TXT partagé (un seul SPF) : un seul déclarant par nom et préfixe, que le
    -- préfixe soit déclaré par l'un ou porté par les valeurs de l'autre. Une déclaration en cours de
    -- retrait (releasing) ne compte plus : sa valeur encore publiée est un conflit au plan jusqu'à sa suppression
    LET $txt = array::filter($others, |$o| $o.type = "TXT" AND $o.state != "releasing");
    LET $taken = array::first(array::filter($items, |$r| $r.type = "TXT" AND array::any($txt, |$o| $o.fqdn = $r.fqdn
        AND (($r.singleton_prefix IS NOT NONE AND array::any($o.values, |$v| string::starts_with($v, $r.singleton_prefix)))
            OR ($o.singleton_prefix IS NOT NONE AND array::any($r.values, |$v| string::starts_with($v, $o.singleton_prefix)))))));
    IF $taken IS NOT NONE {
        LET $prefix = $taken.singleton_prefix ?? array::first(array::filter($txt, |$o| $o.fqdn = $taken.fqdn AND $o.singleton_prefix IS NOT NONE
            AND array::any($taken.values, |$v| string::starts_with($v, $o.singleton_prefix)))).singleton_prefix;
        RETURN { code: "INFRA_RECORD_SINGLETON_TAKEN", details: { index: array::find_index($items, $taken), prefix: $prefix } };
    };
    RETURN NONE;
} COMMENT "Interne : { code, details } si la déclaration ($p : owner, subject ; $items contrôlés) répète un (nom, type), met un CNAME à côté d'un autre enregistrement (INFRA_RECORD_CNAME_CONFLICT), veut un (nom, type) déjà déclaré par un autre propriétaire alors que l'un des deux est exclusif (INFRA_RECORD_OWNED), ou un TXT dont le préfixe unique est déjà tenu au même nom par une autre déclaration active (INFRA_RECORD_SINGLETON_TAKEN : { index, prefix }) ; NONE sinon";

-- ----------------------------------------------------------------------------
-- fn::infra__declare_write (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__declare_write($p: object, $items: array) -> object {
    LET $existing = (SELECT * FROM infra_record WHERE owner = $p.owner AND subject = $p.subject);
    LET $outcomes = array::map($items, |$r| {
        LET $id = fn::infra__record_key($p.owner, $p.subject, $r.fqdn, $r.type);
        LET $state = IF $r.zone IS NONE { "unmanaged" } ELSE { "pending" };
        LET $current = array::first(array::filter($existing, |$e| $e.id = $id));
        IF $current IS NONE {
            LET $created = (CREATE $id CONTENT {
                owner: $p.owner, subject: $p.subject, tenant: $p.tenant, zone: $r.zone, fqdn: $r.fqdn, type: $r.type,
                values: $r.values, ttl: $r.ttl, mode: $r.mode, singleton_prefix: $r.singleton_prefix, state: $state
            });
            RETURN IF array::len($created) = 0 { { id: $id, written: false } } ELSE { { id: $id, written: true, changed: true, row: $created[0] } };
        };
        IF $current.state NOT IN ["releasing", "released"] AND $current.tenant = $p.tenant AND $current.zone = $r.zone
            AND $current.values = $r.values AND $current.ttl = $r.ttl AND $current.mode = $r.mode AND $current.singleton_prefix = $r.singleton_prefix {
            RETURN { id: $id, written: true, changed: false, row: $current };
        };
        LET $updated = (UPDATE ONLY $id SET tenant = $p.tenant, zone = $r.zone, values = $r.values, ttl = $r.ttl, mode = $r.mode,
            singleton_prefix = $r.singleton_prefix, state = $state, conflict = NONE, resolution = NONE, error = NONE,
            next_verify_at = NONE, declared_at = time::now());
        RETURN IF $updated == NONE { { id: $id, written: false } } ELSE { { id: $id, written: true, changed: true, row: $updated } };
    });
    -- Enregistrements du sujet absents de la déclaration : retirés de chez l'hébergeur s'ils y ont été écrits
    LET $kept = $outcomes.id;
    LET $gone = array::filter($existing, |$e| $e.id NOT IN $kept AND $e.state NOT IN ["releasing", "released"]);
    LET $removed = array::map($gone, |$e| {
        LET $next = IF array::len($e.provider_ids) > 0 AND $e.zone IS NOT NONE { "releasing" } ELSE { "released" };
        LET $updated = (UPDATE ONLY $e.id SET state = $next, conflict = NONE, next_verify_at = NONE, declared_at = time::now());
        RETURN { id: $e.id, written: $updated != NONE, zone: IF $next = "releasing" { $e.zone } ELSE { NONE } };
    });
    RETURN { outcomes: $outcomes, removed: $removed };
} COMMENT "Interne : écrit la déclaration ($p : owner, subject, tenant ; $items avec leur zone) : création, remise à pending (ou unmanaged sans zone) d'un enregistrement changé, aucune écriture pour un enregistrement identique ; ceux du sujet qui n'y figurent plus passent en releasing (écrits chez l'hébergeur) ou released. Rend { outcomes, removed } (written faux : écriture filtrée par les permissions)";

-- ----------------------------------------------------------------------------
-- fn::infra_records_declare
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_records_declare($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        owner: { checks: [|$v: any| fn::validation_snake_case_name($v, 1, 64)], required: true },
        subject: { checks: [|$v: any| fn::validation_required_string($v, 1, 128)], required: true },
        tenant: { checks: [|$v: any| fn::validation_record($v, "auth_organization")] },
        records: { checks: [|$v: any| fn::validation_array_objects($v, false)], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF array::len($p.records) > 50 { RETURN fn::error_result("INFRA_RECORD_LIMIT", $p.language, { max: 50, given: array::len($p.records) }); };
    LET $refused = fn::infra__contract_refusal($p.owner);
    IF $refused IS NOT NONE { RETURN fn::error_result($refused, $p.language, {}); };
    LET $settings = fn::infra__settings();
    LET $checked = array::map($p.records, |$item, $index| fn::infra__declared_item($item, $index, $settings));
    LET $errors = array::fold(array::filter($checked, |$c| !$c.valid), {}, |$acc, $c| object::extend($acc, $c.errors));
    IF !object::is_empty($errors) { RETURN fn::infra__invalid($params, $errors); };
    LET $items = $checked.value;
    LET $refusal = fn::infra__declare_refusal($p, $items);
    IF $refusal IS NOT NONE { RETURN fn::error_result($refusal.code, $p.language, $refusal.details); };
    -- Zone qui couvre chaque nom ; une organisation n'écrit que dans une zone qui la nomme
    LET $zoned = array::map($items, |$r| object::extend($r, { zone: fn::infra__covering_zone($r.fqdn) }));
    LET $tenant_refused = array::find_index($zoned, |$r| $r.zone IS NOT NONE AND $p.tenant IS NOT NONE AND !($r.zone.tenants CONTAINS $p.tenant));
    IF $tenant_refused IS NOT NONE { RETURN fn::error_result("INFRA_RECORD_TENANT_REFUSED", $p.language, { index: $tenant_refused }); };
    LET $written = fn::infra__declare_write($p, array::map($zoned, |$r| object::extend($r, { zone: $r.zone.id })));
    IF array::any(array::concat($written.outcomes, $written.removed), |$o| !$o.written) { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $touched = array::concat(
        array::filter($written.outcomes, |$o| $o.changed AND $o.row.zone IS NOT NONE).row.zone,
        array::filter($written.removed, |$o| $o.zone IS NOT NONE).zone
    );
    LET $queued = fn::infra__reconcile_enqueue(array::distinct($touched));
    RETURN fn::result_ok({
        items: array::map($written.outcomes, |$o| { record: $o.id, fqdn: $o.row.fqdn, type: $o.row.type, state: $o.row.state, managed: $o.row.zone IS NOT NONE }),
        changed: array::any($written.outcomes, |$o| $o.changed) OR array::len($written.removed) > 0,
        queued: $queued.queued
    });
} COMMENT "Contrat public : déclare tout l'ensemble des enregistrements voulus d'un couple (propriétaire, sujet) ({ owner : identifiant de module ou manual, subject : clé opaque, sans nom de domaine ni adresse, tenant : organisation, records : 0 à 50 × { fqdn, type : A, AAAA, CNAME, MX, TXT, SRV, CAA, values : 1 à 20 en forme canonique, ttl, mode : exclusive ou shared, singleton_prefix }, language }) : ce qui n'y figure plus est retiré (liste vide : tout) ; une déclaration identique n'écrit rien (changed faux). Refus : nom couvert par une zone qui n'accepte pas l'organisation (INFRA_RECORD_TENANT_REFUSED), (nom, type) exclusif d'un autre propriétaire (INFRA_RECORD_OWNED), CNAME avec autre chose (INFRA_RECORD_CNAME_CONFLICT), TXT dont le préfixe unique (singleton_prefix, ou préfixe d'une autre déclaration porté par ses valeurs) est déjà tenu au même nom par une autre déclaration active (INFRA_RECORD_SINGLETON_TAKEN), plus de 50 (INFRA_RECORD_LIMIT). Nom sans zone rattachée : unmanaged. Un changement demande une passe de la zone (queued). Rend { items : [{ record, fqdn, type, state, managed }], changed, queued }. Droit infra.records.declare (manual : infra.manage), session système";

-- ----------------------------------------------------------------------------
-- fn::infra_records_release
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_records_release($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        owner: { checks: [|$v: any| fn::validation_snake_case_name($v, 1, 64)], required: true },
        subject: { checks: [|$v: any| fn::validation_required_string($v, 1, 128)], required: true },
        keep_at_provider: { checks: [|$v: any| fn::validation_boolean($v)], default: false },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $refused = fn::infra__contract_refusal($p.owner);
    IF $refused IS NOT NONE { RETURN fn::error_result($refused, $p.language, {}); };
    LET $rows = (SELECT id, zone, provider_ids, state FROM infra_record WHERE owner = $p.owner AND subject = $p.subject AND state NOT IN ["releasing", "released"]);
    LET $outcomes = array::map($rows, |$r| {
        LET $remove = !$p.keep_at_provider AND array::len($r.provider_ids) > 0 AND $r.zone IS NOT NONE;
        LET $updated = IF $remove {
            (UPDATE ONLY $r.id SET state = "releasing", conflict = NONE, next_verify_at = NONE, declared_at = time::now())
        } ELSE {
            (UPDATE ONLY $r.id SET state = "released", provider_ids = [], applied_values = [], conflict = NONE, next_verify_at = NONE, declared_at = time::now())
        };
        RETURN { written: $updated != NONE, releasing: $remove, zone: $r.zone };
    });
    IF array::any($outcomes, |$o| !$o.written) { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $queued = fn::infra__reconcile_enqueue(array::distinct(array::filter($outcomes, |$o| $o.releasing).zone));
    RETURN fn::result_ok({
        released: array::len(array::filter($outcomes, |$o| !$o.releasing)),
        releasing: array::len(array::filter($outcomes, |$o| $o.releasing)),
        queued: $queued.queued
    });
} COMMENT "Contrat public : retire tous les enregistrements d'un couple (propriétaire, sujet) ({ owner, subject, keep_at_provider : faux par défaut, language }) : ceux que Lyxal a écrits passent en releasing (supprimés chez l'hébergeur à la passe suivante, seulement si la valeur y est encore celle écrite par Lyxal), les autres (ou tous avec keep_at_provider) sont oubliés (released). Rend { released, releasing, queued }. Droit infra.records.declare (manual : infra.manage), session système";

-- ----------------------------------------------------------------------------
-- fn::infra_records_status
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_records_status($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        owner: { checks: [|$v: any| fn::validation_snake_case_name($v, 1, 64)], required: true },
        subjects: { checks: [|$v: any| fn::validation_array_of_strings($v, false, 1, 128), |$v: any| fn::validation_array_length($v, 1, 500)], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $refused = fn::infra__contract_refusal($p.owner);
    IF $refused IS NOT NONE { RETURN fn::error_result($refused, $p.language, {}); };
    LET $rows = (SELECT subject, id, fqdn, type, state, conflict, published_at, error, zone FROM infra_record
        WHERE owner = $p.owner AND subject IN $p.subjects ORDER BY subject ASC, fqdn ASC, type ASC);
    RETURN fn::result_ok({
        items: array::map($rows, |$r| {
            subject: $r.subject, record: $r.id, fqdn: $r.fqdn, type: $r.type, state: $r.state, managed: $r.zone IS NOT NONE,
            conflict_reason: $r.conflict.reason, published_at: $r.published_at, error_code: $r.error.code
        })
    });
} COMMENT "Contrat public : état des enregistrements d'un propriétaire pour des sujets ({ owner, subjects : 1 à 500, language }) : { items : [{ subject, record, fqdn, type, state, managed, conflict_reason, published_at, error_code }] }. Droit infra.records.declare (manual : infra.manage), session système";

-- ----------------------------------------------------------------------------
-- fn::infra_records_subjects
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_records_subjects($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        owner: { checks: [|$v: any| fn::validation_snake_case_name($v, 1, 64)], required: true },
        after: { checks: [|$v: any| fn::validation_required_string($v, 1, 128)] },
        limit: { checks: [|$v: any| fn::validation_integer($v, 1, 1000)], default: 100 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $refused = fn::infra__contract_refusal($p.owner);
    IF $refused IS NOT NONE { RETURN fn::error_result($refused, $p.language, {}); };
    LET $subjects = array::sort(array::distinct(SELECT VALUE subject FROM infra_record
        WHERE owner = $p.owner AND state != "released" AND ($p.after IS NONE OR subject > $p.after)));
    LET $page = array::slice($subjects, 0, $p.limit);
    RETURN fn::result_ok({ subjects: $page, next: IF array::len($subjects) > $p.limit { array::last($page) } ELSE { NONE } });
} COMMENT "Contrat public : sujets d'un propriétaire qui ont encore des enregistrements ({ owner, after, limit : 1 à 1 000, language }), par ordre croissant, après after : { subjects, next } (next : valeur de after de la page suivante, NONE à la fin). Sert au propriétaire à retirer les sujets disparus. Droit infra.records.declare (manual : infra.manage), session système";

-- ----------------------------------------------------------------------------
-- fn::infra__record_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__record_view($row: object) -> object {
    RETURN $row.{ id, owner, subject, tenant, zone, fqdn, type, values, ttl, mode, singleton_prefix, state, conflict, resolution, applied_values, written_at, published_at, verify_attempts, next_verify_at, error, declared_at, updated_at };
} COMMENT "Interne : vue d'un enregistrement voulu pour l'administration (identifiants du fournisseur exclus)";

-- ----------------------------------------------------------------------------
-- fn::infra_record_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_record_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            zone: { pipeline: [{ rule: "record", options: { expected_table: "infra_zone" } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["unmanaged", "pending", "written", "published", "conflict", "yielded", "failed", "releasing", "released"], case_sensitive: true } }] },
            owner: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT * FROM infra_record
        WHERE ($p.zone IS NONE OR zone = $p.zone) AND ($p.state IS NONE OR state = $p.state) AND ($p.owner IS NONE OR owner = $p.owner)
        ORDER BY fqdn ASC, type ASC, id ASC);
    RETURN fn::result_ok({ items: array::map(array::slice($rows, $p.start, $p.start + $p.limit), |$r| fn::infra__record_view($r)), total: array::len($rows) });
} COMMENT "Enregistrements voulus ({ zone, state, owner, limit (500 au plus), start }), par nom, type et clé : { items, total }. Droit infra.read";

-- ----------------------------------------------------------------------------
-- fn::infra_record_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_record_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            record: { pipeline: [{ rule: "record", options: { expected_table: "infra_record" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $row = (SELECT * FROM ONLY $p.record);
    IF $row == NONE { RETURN fn::error_result("INFRA_RECORD_NOT_FOUND", $p.language, { record: <string> $p.record }); };
    LET $observed = IF $row.zone IS NONE { [] } ELSE {
        (SELECT provider_id, value, ttl, record FROM infra_zone_record WHERE zone = $row.zone AND fqdn = $row.fqdn AND type = $row.type ORDER BY value ASC, provider_id ASC)
    };
    RETURN fn::result_ok(object::extend(fn::infra__record_view($row), {
        observed: array::map($observed, |$o| { provider_id: $o.provider_id, value: $o.value, ttl: $o.ttl, lyxal: $o.record = $row.id })
    }));
} COMMENT "Enregistrement voulu ({ record }) et valeurs observées chez l'hébergeur pour son nom et son type (observed : { provider_id, value, ttl, lyxal }). Droit infra.read";

-- ----------------------------------------------------------------------------
-- fn::infra_record_conflict_resolve
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_record_conflict_resolve($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            record: { pipeline: [{ rule: "record", options: { expected_table: "infra_record" } }], required: true },
            action: { pipeline: [{ rule: "enum", options: { allowed: ["take_over", "yield"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $row = (SELECT * FROM ONLY $p.record);
    IF $row == NONE OR $row.state != "conflict" { RETURN fn::error_result("INFRA_RECORD_NOT_FOUND", $p.language, { record: <string> $p.record, state: $row.state }); };
    LET $resolution = { action: $p.action, actor: fn::infra__actor(), at: time::now(), applied_at: NONE };
    LET $updated = (UPDATE ONLY $row.id SET state = IF $p.action = "take_over" { "pending" } ELSE { "yielded" }, resolution = $resolution, next_verify_at = NONE);
    IF $updated == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_record" }); };
    LET $noted = fn::infra__change_write({ zone: $row.zone, record: $row.id, action: "resolve", before: { reason: $row.conflict.reason, observed: $row.conflict.observed }, after: { action: $p.action } });
    IF $noted IS NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $queued = IF $p.action = "take_over" AND $row.zone IS NOT NONE { fn::infra__reconcile_enqueue([$row.zone]).queued } ELSE { 0 };
    RETURN fn::result_ok(object::extend(fn::infra__record_view($updated), { queued: $queued }));
} COMMENT "Lève le conflit d'un enregistrement ({ record, action : take_over ou yield }) : take_over remplace la valeur étrangère à la passe suivante (une fois), yield laisse la valeur humaine et met l'enregistrement en sommeil (yielded, jusqu'à une nouvelle déclaration qui le change). Noté au journal avec son auteur. Enregistrement absent ou hors conflit : INFRA_RECORD_NOT_FOUND. Droit infra.manage";
