-- ============================================================================
-- FONCTIONS : inscription, adresses, rattachement par domaine, premier administrateur
-- MODULE    : lyxal_auth
-- ============================================================================
-- Pas d'inscription libre (D9) : une identité naît d'une invitation, d'une création par un
-- administrateur, ou du lien d'installation du premier administrateur. Session système.

-- ----------------------------------------------------------------------------
-- fn::auth_domain_auto_join : adhésion par domaine vérifié (adresse vérifiée exigée)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_domain_auto_join($params: object) -> array {
    LET $addresses = (SELECT VALUE value FROM auth_address WHERE identity = $params.identity AND channel = "email" AND verified_at IS NOT NONE);
    LET $domains = array::distinct(array::map($addresses, |$a| string::split($a, "@")[1]));
    LET $matches = (SELECT organization, default_roles FROM auth_organization_domain
        WHERE domain IN $domains AND state = "verified" AND auto_join = true AND organization.state = "active");
    LET $joined = array::filter(array::map($matches, |$m| {
        IF array::len(SELECT VALUE id FROM auth_member_of WHERE in = $params.identity AND out = $m.organization LIMIT 1) > 0 { RETURN NONE; };
        LET $result = fn::auth_membership_create({ identity: $params.identity, organization: $m.organization, roles: $m.default_roles ?? [], by: NONE });
        RETURN IF $result.code IS NONE { $m.organization } ELSE { NONE };
    }), |$o| $o IS NOT NONE);
    RETURN $joined;
} COMMENT "Rattache une identité ({ identity }) aux organisations dont un domaine vérifié à rattachement automatique correspond à l'une de ses adresses vérifiées ; organisations rejointes";

-- ----------------------------------------------------------------------------
-- fn::auth_address_verify : adresse vérifiée par code ou lien
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_address_verify($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            address: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $value = fn::sanitize_pipeline_execute($p.address, [{ rule: "email" }], 5);
    LET $verified = (UPDATE auth_address SET verified_at = time::now() WHERE identity = $p.identity AND channel = "email" AND value = $value RETURN id);
    IF array::len($verified) = 0 { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    DELETE auth_required_action WHERE identity = $p.identity AND action = "verify_email";
    RETURN fn::result_ok({ addresses: $verified, organizations_joined: fn::auth_domain_auto_join({ identity: $p.identity }) });
} COMMENT "Marque une adresse vérifiée ({ identity, address }), lève l'action verify_email et rattache par domaine. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_registration_start : inscription par jeton d'invitation ou lien d'installation
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_registration_start($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            invitation_token_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }] },
            setup_link_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }] },
            client: { pipeline: [{ rule: "is_object" }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR (($report.value.invitation_token_hash IS NONE) = ($report.value.setup_link_hash IS NONE)) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    IF $p.setup_link_hash IS NOT NONE {
        LET $verified = fn::auth_code_verify({ purpose: "setup", link_hash: $p.setup_link_hash, language: $p.language });
        IF !$verified.ok { RETURN fn::error_result("AUTH_SETUP_TOKEN_INVALID", $p.language, {}); };
        RETURN fn::result_ok({ flow: $verified.data.flow, email: $verified.data.address, organization: NONE, kind: "setup" });
    };
    LET $invitation = (SELECT * FROM ONLY auth_organization_invitation WHERE token_hash = string::lowercase($p.invitation_token_hash) LIMIT 1);
    IF $invitation == NONE OR $invitation.state != "pending" { RETURN fn::error_result("AUTH_INVITATION_INVALID", $p.language, {}); };
    IF $invitation.expires_at <= time::now() { RETURN fn::error_result("AUTH_INVITATION_EXPIRED", $p.language, {}); };
    -- Adresse déjà inscrite : la personne se connecte puis accepte l'invitation (lot 2)
    IF array::len(SELECT VALUE id FROM auth_credential_identifier WHERE type = "email" AND value = $invitation.email LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_IDENTIFIER_TAKEN", $p.language, { type: "email" });
    };
    LET $flow = fn::auth_flow_start({ type: "registration", organization: <string> $invitation.organization, invitation: <string> $invitation.id, address: $invitation.email, client: $p.client });
    IF !$flow.ok { RETURN $flow; };
    RETURN fn::result_ok({ flow: $flow.data.id, email: $invitation.email, organization: $invitation.organization, kind: "invitation" });
} COMMENT "Démarre une inscription ({ invitation_token_hash } ou { setup_link_hash }) : invitation en attente ou lien d'installation valide ; { flow, email, organization, kind }. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_registration_complete : identité créée, adresse vérifiée, invitation acceptée
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_registration_complete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }], required: true },
            traits: { pipeline: [{ rule: "is_object" }], default: {} },
            secret: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 16384 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $loaded = fn::auth_flow_load({ flow: $p.flow, type: "registration", states: ["started"] });
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, {}); };
    LET $flow = $loaded.flow;
    LET $invitation = IF $flow.invitation IS NONE { NONE } ELSE { (SELECT * FROM ONLY $flow.invitation) };
    IF $flow.invitation IS NOT NONE AND ($invitation == NONE OR $invitation.state != "pending" OR $invitation.expires_at <= time::now()) {
        RETURN fn::error_result("AUTH_INVITATION_INVALID", $p.language, {});
    };
    -- Le premier administrateur n'est créé qu'une fois
    IF $invitation == NONE AND array::len(SELECT VALUE id FROM auth_has_role WHERE out = auth_role:platform_admin LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_SETUP_DONE", $p.language, {});
    };
    -- L'adresse vient de l'invitation ou du lien, jamais de l'appelant
    LET $traits = object::extend($p.traits, { email: $flow.address });
    LET $created = fn::auth_identity_create({
        traits: $traits,
        organization: IF $invitation == NONE { NONE } ELSE { <string> $invitation.organization },
        roles: array::map($invitation.roles ?? [], |$r| <string> $r),
        language: $p.language
    });
    IF !$created.ok { RETURN $created; };
    LET $identity = $created.data.id;
    IF $invitation == NONE {
        LET $granted = (RELATE ONLY $identity->auth_has_role->auth_role:platform_admin);
        IF $granted == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    } ELSE {
        UPDATE $invitation.id SET state = "accepted", accepted_by = $identity, accepted_at = time::now();
    };
    LET $password = fn::auth_password_set({ identity: <string> $identity, secret: $p.secret, language: $p.language });
    IF !$password.ok { THROW $password.error.code; };
    -- L'invitation ou le lien reçu à cette adresse en prouve la possession
    UPDATE auth_address SET verified_at = time::now() WHERE identity = $identity AND channel = "email" AND value = $flow.address;
    LET $joined = fn::auth_domain_auto_join({ identity: $identity });
    UPDATE $flow.id SET state = "completed", identity = $identity;
    RETURN fn::result_ok({ identity: $identity, organization: $invitation.organization, organizations_joined: $joined });
} COMMENT "Termine une inscription ({ flow, traits, secret enc:v2 }) : identité créée avec l'adresse de l'invitation ou du lien, mot de passe, adresse vérifiée, invitation acceptée (ou rôle platform_admin pour le lien d'installation), rattachement par domaine. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_setup_start : lien d'installation du premier administrateur
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_setup_start($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            link_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    IF array::len(SELECT VALUE id FROM auth_has_role WHERE out = auth_role:platform_admin LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_SETUP_DONE", $p.language, {});
    };
    LET $flow = fn::auth_flow_start({ type: "registration", address: $p.email });
    IF !$flow.ok { RETURN $flow; };
    -- Lien valable 1 h, affiché une fois par la commande de l'hôte (aucun message envoyé)
    UPDATE $flow.data.id SET expires_at = time::now() + 1h;
    LET $code = (CREATE ONLY auth_one_time_code CONTENT {
        flow: $flow.data.id, purpose: "setup", address: $flow.data.address, link_hash: string::lowercase($p.link_hash),
        max_attempts: 1, expires_at: time::now() + 1h
    });
    IF $code == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_one_time_code" }); };
    RETURN fn::result_ok({ flow: $flow.data.id, expires_at: $code.expires_at });
} COMMENT "Prépare le lien d'installation du premier administrateur ({ email, link_hash }) ; refusé s'il existe déjà un platform_admin. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_address_change_request / fn::auth_address_change_confirm
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_address_change_request($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            new_address: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            client: { pipeline: [{ rule: "is_object" }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $value = fn::sanitize_pipeline_execute($p.new_address, [{ rule: "email" }], 5);
    IF array::len(SELECT VALUE id FROM auth_credential_identifier WHERE type = "email" AND value = $value LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_IDENTIFIER_TAKEN", $p.language, { type: "email" });
    };
    -- Une seule demande en attente : la précédente est remplacée
    DELETE auth_pending_address_change WHERE identity = $p.identity;
    LET $flow = fn::auth_flow_start({ type: "address_change", identity: <string> $p.identity, address: $value, client: $p.client });
    IF !$flow.ok { RETURN $flow; };
    LET $pending = (CREATE ONLY auth_pending_address_change CONTENT { identity: $p.identity, new_address: $value, flow: $flow.data.id, expires_at: $flow.data.expires_at });
    IF $pending == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_pending_address_change" }); };
    RETURN fn::result_ok({ flow: $flow.data.id, address: $value });
} COMMENT "Demande un changement d'adresse ({ identity, new_address }) : adresse libre, parcours address_change, demande en attente (une par identité). Mot de passe actuel vérifié par l'hôte. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_address_change_confirm($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $loaded = fn::auth_flow_load({ flow: $p.flow, type: "address_change", states: ["code_verified"] });
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, {}); };
    LET $pending = (SELECT * FROM ONLY auth_pending_address_change WHERE flow = $p.flow LIMIT 1);
    IF $pending == NONE { RETURN fn::error_result("AUTH_FLOW_INVALID_STATE", $p.language, {}); };
    LET $identity = $pending.identity;
    LET $old = (SELECT VALUE value FROM ONLY auth_credential_identifier WHERE identity = $identity AND type = "email" LIMIT 1);
    -- L'index unique protège d'une adresse prise entre la demande et la confirmation
    LET $updated = (UPDATE auth_credential_identifier SET value = $pending.new_address WHERE identity = $identity AND type = "email" RETURN id);
    IF array::len($updated) = 0 { THROW "AUTH_WRITE_FORBIDDEN"; };
    UPDATE auth_address SET value = $pending.new_address, verified_at = time::now() WHERE identity = $identity AND channel = "email" AND value = $old;
    UPDATE $identity SET traits.email = $pending.new_address;
    DELETE $pending.id;
    UPDATE $p.flow SET state = "completed";
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.address.changed",
        producer: "lyxal_auth",
        source: $identity,
        payload: { identity_id: <string> $identity, previous_address: $old, address: $pending.new_address },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    RETURN fn::result_ok({ identity: $identity, address: $pending.new_address, organizations_joined: fn::auth_domain_auto_join({ identity: $identity }) });
} COMMENT "Confirme un changement d'adresse ({ flow } après vérification du code envoyé à la nouvelle adresse) : identifiant, adresse et trait remplacés, événement auth.address.changed vers l'ancienne adresse. Session système";
