-- ============================================================================
-- FONCTIONS : identités, identifiants, adresses, schéma des traits
-- MODULE    : lyxal_auth
-- ============================================================================
-- Les traits sont validés par le schéma de l'identité (moteur lyxal_core). Les identifiants de
-- connexion et les adresses en sont déduits (normalisés par lyxal_core) ; un identifiant déjà
-- utilisé par une autre identité est refusé (un e-mail = une identité, D10).

-- ----------------------------------------------------------------------------
-- fn::auth_identity_schema_save : nouvelle version d'un schéma de traits
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_schema_save($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            traits: { pipeline: [{ rule: "is_object" }], required: true },
            identifiers: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }], default: [] },
            verifiable: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }], default: [] },
            is_default: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.identity.manage" }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage" });
    };
    -- Le schéma doit être accepté par le moteur lyxal_core (un schéma mal formé y lève CORE_INVALID_ARGUMENT)
    LET $probe = fn::validation_object_execute({}, $p.traits, 200);
    IF type::is_none($probe) OR !type::is_object($p.traits.fields ?? NONE) {
        RETURN fn::error_result("AUTH_SCHEMA_INVALID", $p.language, {});
    };
    LET $trait_names = object::keys($p.traits.fields);
    IF array::any($p.identifiers, |$i| !type::is_string($i.trait) OR $i.trait NOTINSIDE $trait_names OR $i.type NOTINSIDE ["email", "username", "phone"])
        OR array::any($p.verifiable, |$v| !type::is_string($v.trait) OR $v.trait NOTINSIDE $trait_names OR $v.channel NOTINSIDE ["email", "phone"] OR $v.usage NOTINSIDE ["verification", "recovery"]) {
        RETURN fn::error_result("AUTH_SCHEMA_INVALID", $p.language, { reason: "unknown_trait" });
    };
    LET $version = (math::max(SELECT VALUE version FROM auth_identity_schema WHERE key = $p.key) ?? 0) + 1;
    IF $p.is_default {
        UPDATE auth_identity_schema SET is_default = false WHERE is_default = true;
    };
    LET $created = (CREATE ONLY type::record("auth_identity_schema", string::concat($p.key, "_v", <string> $version)) CONTENT {
        key: $p.key,
        version: $version,
        traits: $p.traits,
        identifiers: array::map($p.identifiers, |$i| { trait: $i.trait, type: $i.type }),
        verifiable: array::map($p.verifiable, |$v| { trait: $v.trait, channel: $v.channel, usage: $v.usage }),
        is_default: $p.is_default
    });
    IF $created == NONE {
        RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_identity_schema" });
    };
    RETURN fn::result_ok($created);
} COMMENT "Enregistre une nouvelle version d'un schéma de traits ({ key, traits : schéma lyxal_core, identifiers, verifiable, is_default }). Permission auth.identity.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_identity_schema_get : schéma par clé (dernière version) ou schéma par défaut
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_schema_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            version: { pipeline: [{ rule: "integer", options: { min_value: 1 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $found = IF $p.key IS NONE {
        (SELECT * FROM ONLY auth_identity_schema WHERE is_default = true LIMIT 1)
    } ELSE IF $p.version IS NONE {
        (SELECT * FROM ONLY auth_identity_schema WHERE key = $p.key ORDER BY version DESC LIMIT 1)
    } ELSE {
        (SELECT * FROM ONLY auth_identity_schema WHERE key = $p.key AND version = $p.version LIMIT 1)
    };
    IF $found == NONE { RETURN fn::error_result("AUTH_SCHEMA_INVALID", $p.language, { reason: "not_found" }); };
    RETURN fn::result_ok($found);
} COMMENT "Lit un schéma de traits ({ key, version } ; sans clé : schéma par défaut ; sans version : la dernière)";

-- ----------------------------------------------------------------------------
-- fn::auth_identity_derive : traits validés, identifiants et adresses déduits d'un schéma
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_derive($params: object) -> object {
    LET $schema = $params.schema;
    LET $report = fn::validation_object_execute($params.traits, $schema.traits, 60);
    IF !$report.valid { RETURN { ok: false, code: "AUTH_TRAITS_INVALID", details: { fields: $report.by_field } }; };
    LET $traits = $report.value;
    LET $normalize = |$type: string, $value: any| IF $type = "email" {
        fn::sanitize_pipeline_execute($value, [{ rule: "email" }], 5)
    } ELSE IF $type = "username" {
        fn::sanitize_pipeline_execute($value, [{ rule: "trim" }, { rule: "lowercase" }], 5)
    } ELSE {
        fn::sanitize_pipeline_execute($value, [{ rule: "trim" }], 5)
    };
    LET $identifiers = array::filter(array::map($schema.identifiers, |$i| IF type::is_string($traits[$i.trait] ?? NONE) {
        { type: $i.type, value: $normalize($i.type, $traits[$i.trait]) }
    } ELSE { NONE }), |$x| $x IS NOT NONE);
    LET $addresses = array::filter(array::map($schema.verifiable, |$v| IF type::is_string($traits[$v.trait] ?? NONE) {
        { channel: $v.channel, usage: $v.usage, value: $normalize($v.channel, $traits[$v.trait]) }
    } ELSE { NONE }), |$x| $x IS NOT NONE);
    RETURN { ok: true, traits: $traits, identifiers: $identifiers, addresses: $addresses };
} COMMENT "Valide des traits ({ schema, traits }) et en déduit identifiants et adresses normalisés ; { ok, traits, identifiers, addresses } ou { ok: false, code, details }";

-- ----------------------------------------------------------------------------
-- fn::auth_identity_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schema_key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            traits: { pipeline: [{ rule: "is_object" }], required: true },
            external_id: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "inactive"], case_sensitive: true } }], default: "active" },
            public_metadata: { pipeline: [{ rule: "is_object" }], default: {} },
            admin_metadata: { pipeline: [{ rule: "is_object" }], default: {} },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            roles: { pipeline: [{ rule: "array" }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.identity.manage" })
        AND ($p.organization IS NONE OR !fn::auth_has_permission({ permission: "auth.member.manage", tenant: $p.organization })) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage" });
    };
    LET $schema = IF $p.schema_key IS NONE {
        (SELECT * FROM ONLY auth_identity_schema WHERE is_default = true LIMIT 1)
    } ELSE {
        (SELECT * FROM ONLY auth_identity_schema WHERE key = $p.schema_key ORDER BY version DESC LIMIT 1)
    };
    IF $schema == NONE { RETURN fn::error_result("AUTH_SCHEMA_INVALID", $p.language, { reason: "not_found" }); };
    LET $derived = fn::auth_identity_derive({ schema: $schema, traits: $p.traits });
    IF !$derived.ok { RETURN fn::error_result($derived.code, $p.language, $derived.details); };
    IF array::len($derived.identifiers) = 0 { RETURN fn::error_result("AUTH_TRAITS_INVALID", $p.language, { reason: "no_identifier" }); };
    FOR $identifier IN $derived.identifiers {
        IF array::len(SELECT VALUE id FROM auth_credential_identifier WHERE type = $identifier.type AND value = $identifier.value LIMIT 1) > 0 {
            RETURN fn::error_result("AUTH_IDENTIFIER_TAKEN", $p.language, { type: $identifier.type });
        };
    };
    IF $p.external_id IS NOT NONE AND array::len(SELECT VALUE id FROM auth_identity WHERE external_id = $p.external_id LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_IDENTIFIER_TAKEN", $p.language, { type: "external_id" });
    };
    IF $p.organization IS NOT NONE {
        LET $organization = (SELECT state FROM ONLY $p.organization);
        IF $organization == NONE { RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {}); };
        IF $organization.state != "active" { RETURN fn::error_result("AUTH_ORGANIZATION_INACTIVE", $p.language, { state: $organization.state }); };
        IF array::len($p.roles) > 0 AND !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: $p.organization }) {
            RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.role.manage" });
        };
        LET $roles = (SELECT id, scope, tenant FROM auth_role WHERE id IN $p.roles);
        IF array::len($roles) != array::len(array::distinct($p.roles)) { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
        IF array::any($roles, |$r| $r.scope != "organization" OR ($r.tenant IS NOT NONE AND $r.tenant != $p.organization)) {
            RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
        };
    };
    -- L'identité créée par un administrateur d'organisation ne lui est visible qu'une fois membre :
    -- l'écriture est donc vérifiée à la fin, par une relecture
    LET $iid = type::record("auth_identity", string::replace(<string> rand::uuid::v7(), "-", ""));
    CREATE $iid CONTENT {
        schema: $schema.id,
        traits: $derived.traits,
        state: $p.state,
        external_id: $p.external_id,
        public_metadata: $p.public_metadata,
        admin_metadata: $p.admin_metadata
    };
    LET $caller = IF $auth != NONE AND type::is_record($auth, "auth_session") { (SELECT VALUE identity FROM ONLY $auth) } ELSE { NONE };
    IF $p.organization IS NOT NONE {
        LET $joined = fn::auth_membership_create({ identity: $iid, organization: $p.organization, roles: $p.roles, by: $caller });
        IF $joined.code IS NOT NONE { THROW $joined.code; };
    };
    -- Un identifiant d'une identité invisible pour l'appelant (autre organisation) n'est détecté
    -- que par l'index unique : INSERT IGNORE n'insère rien, et la création entière est annulée
    -- avec le code de master data (aucune information sur l'autre identité n'est révélée)
    FOR $identifier IN $derived.identifiers {
        LET $inserted = (INSERT IGNORE INTO auth_credential_identifier { identity: $iid, type: $identifier.type, value: $identifier.value });
        IF array::len($inserted) = 0 { THROW "AUTH_IDENTIFIER_TAKEN"; };
    };
    FOR $address IN $derived.addresses {
        CREATE auth_address CONTENT { identity: $iid, channel: $address.channel, usage: $address.usage, value: $address.value, primary: true };
    };
    LET $created = (SELECT * FROM ONLY $iid);
    IF $created == NONE {
        RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_identity" });
    };
    IF array::len(SELECT VALUE id FROM auth_credential_identifier WHERE identity = $iid) != array::len($derived.identifiers)
        OR array::len(SELECT VALUE id FROM auth_address WHERE identity = $iid) != array::len($derived.addresses) {
        THROW "AUTH_WRITE_FORBIDDEN";
    };
    RETURN fn::result_ok($created);
} COMMENT "Crée une identité ({ schema_key, traits, external_id, state, public_metadata, admin_metadata, organization, roles }) avec ses identifiants et adresses ; membre de l'organisation si elle est donnée. Identifiant pris par une identité invisible : création annulée (AUTH_IDENTIFIER_TAKEN levé par l'index unique). Permission auth.identity.manage, ou auth.member.manage dans l'organisation";

-- ----------------------------------------------------------------------------
-- fn::auth_identity_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $identity = (SELECT * FROM ONLY $p.identity);
    IF $identity == NONE { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    LET $iid = $identity.id;
    LET $self = $auth != NONE AND type::is_record($auth, "auth_session") AND (SELECT VALUE identity FROM ONLY $auth) = $iid;
    LET $admin = fn::auth_has_permission({ permission: "auth.identity.read" });
    RETURN fn::result_ok(object::extend(IF $admin { $identity } ELSE { object::remove($identity, "admin_metadata") }, {
        identifiers: (SELECT type, value FROM auth_credential_identifier WHERE identity = $iid),
        addresses: (SELECT channel, usage, value, verified_at, primary FROM auth_address WHERE identity = $iid),
        memberships: IF $self OR $admin { (SELECT out AS organization, state FROM auth_member_of WHERE in = $iid) } ELSE { [] }
    }));
} COMMENT "Lit une identité visible par l'appelant ({ identity }) avec identifiants, adresses et, pour elle-même ou un administrateur, ses adhésions ; admin_metadata réservé à auth.identity.read";

-- ----------------------------------------------------------------------------
-- fn::auth_identity_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "inactive", "locked", "deleted"], case_sensitive: true } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.identity.read" }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.read" });
    };
    RETURN fn::result_ok(
        SELECT id, traits, state, external_id, created_at FROM auth_identity
        WHERE $p.state IS NONE OR state = $p.state ORDER BY created_at LIMIT $p.limit START $p.start
    );
} COMMENT "Liste les identités de l'installation ({ state, limit, start }). Permission auth.identity.read ; les membres d'une organisation se listent par fn::auth_organization_member_list";

-- ----------------------------------------------------------------------------
-- fn::auth_identity_update_traits
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_update_traits($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            traits: { pipeline: [{ rule: "is_object" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Administrateur d'organisation : membre de sa seule organisation, sans rôle d'installation
    LET $full = fn::auth_has_permission({ permission: "auth.identity.manage" });
    IF !$full AND !fn::auth_org_admin_can_manage({ identity: $p.identity }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage" });
    };
    LET $identity = (SELECT id, schema, state FROM ONLY $p.identity);
    IF $identity == NONE { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    IF $identity.state = "deleted" { RETURN fn::error_result("AUTH_IDENTITY_INACTIVE", $p.language, { state: $identity.state }); };
    LET $iid = $identity.id;
    LET $derived = fn::auth_identity_derive({ schema: (SELECT * FROM ONLY $identity.schema), traits: $p.traits });
    IF !$derived.ok { RETURN fn::error_result($derived.code, $p.language, $derived.details); };
    IF array::len($derived.identifiers) = 0 { RETURN fn::error_result("AUTH_TRAITS_INVALID", $p.language, { reason: "no_identifier" }); };
    -- Un administrateur d'organisation ne change ni identifiant ni adresse : la personne passe par
    -- le changement d'adresse vérifié, l'installation par auth.identity.manage
    IF !$full {
        LET $current_identifiers = (SELECT VALUE string::concat(type, ":", value) FROM auth_credential_identifier WHERE identity = $iid);
        LET $current_addresses = (SELECT VALUE string::concat(channel, ":", usage, ":", value) FROM auth_address WHERE identity = $iid);
        IF array::sort(array::map($derived.identifiers, |$i| string::concat($i.type, ":", $i.value))) != array::sort($current_identifiers)
            OR array::sort(array::map($derived.addresses, |$a| string::concat($a.channel, ":", $a.usage, ":", $a.value))) != array::sort($current_addresses) {
            RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage", reason: "identifier_change" });
        };
    };
    FOR $identifier IN $derived.identifiers {
        IF array::len(SELECT VALUE id FROM auth_credential_identifier WHERE type = $identifier.type AND value = $identifier.value AND identity != $iid LIMIT 1) > 0 {
            RETURN fn::error_result("AUTH_IDENTIFIER_TAKEN", $p.language, { type: $identifier.type });
        };
    };
    -- Identifiants : les nouveaux d'abord (INSERT IGNORE : un identifiant d'une identité invisible
    -- n'est détecté que par l'index unique) ; en cas de conflit, ceux déjà insérés sont retirés et
    -- rien d'autre n'est modifié
    LET $existing = (SELECT VALUE string::concat(type, ":", value) FROM auth_credential_identifier WHERE identity = $iid);
    LET $inserted = array::flatten(array::map(
        array::filter($derived.identifiers, |$i| string::concat($i.type, ":", $i.value) NOTINSIDE $existing),
        |$i| (INSERT IGNORE INTO auth_credential_identifier { identity: $iid, type: $i.type, value: $i.value })
    ));
    IF array::len($inserted) != array::len(array::filter($derived.identifiers, |$i| string::concat($i.type, ":", $i.value) NOTINSIDE $existing)) {
        FOR $row IN $inserted { DELETE $row.id; };
        RETURN fn::error_result("AUTH_IDENTIFIER_TAKEN", $p.language, {});
    };
    LET $updated = (UPDATE ONLY $iid SET traits = $derived.traits);
    IF $updated == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    LET $wanted = array::map($derived.identifiers, |$i| string::concat($i.type, ":", $i.value));
    DELETE auth_credential_identifier WHERE identity = $iid AND string::concat(type, ":", value) NOTINSIDE $wanted;
    -- Adresses : une adresse modifiée redevient non vérifiée
    LET $wanted_addresses = array::map($derived.addresses, |$a| string::concat($a.channel, ":", $a.usage, ":", $a.value));
    DELETE auth_address WHERE identity = $iid AND string::concat(channel, ":", usage, ":", value) NOTINSIDE $wanted_addresses;
    LET $existing_addresses = (SELECT VALUE string::concat(channel, ":", usage, ":", value) FROM auth_address WHERE identity = $iid);
    FOR $address IN array::filter($derived.addresses, |$a| string::concat($a.channel, ":", $a.usage, ":", $a.value) NOTINSIDE $existing_addresses) {
        LET $row = (CREATE ONLY auth_address CONTENT { identity: $iid, channel: $address.channel, usage: $address.usage, value: $address.value, primary: true });
        IF $row == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    };
    RETURN fn::result_ok($updated);
} COMMENT "Remplace les traits d'une identité ({ identity, traits }) ; identifiants et adresses mis à jour (adresse modifiée : à vérifier). Permission auth.identity.manage ; un administrateur d'organisation (auth.member.manage) ne modifie que les autres traits d'un membre de sa seule organisation sans rôle d'installation";

-- ----------------------------------------------------------------------------
-- fn::auth_identity_set_state
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_set_state($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "inactive", "locked", "deleted"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.identity.manage" }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage" });
    };
    LET $identity = (SELECT state FROM ONLY $p.identity);
    IF $identity == NONE { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    IF $identity.state = "deleted" { RETURN fn::error_result("AUTH_IDENTITY_INACTIVE", $p.language, { state: $identity.state }); };
    LET $updated = IF $p.state = "active" {
        (UPDATE ONLY $p.identity SET state = $p.state)
    } ELSE {
        (UPDATE ONLY $p.identity SET state = $p.state, not_before = time::now(), permissions_version += 1)
    };
    IF $updated == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_identity" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Change l'état d'une identité ({ identity, state }) ; hors état actif, toutes ses sessions sont révoquées (not_before). Une identité supprimée ne revient pas. Permission auth.identity.manage";
