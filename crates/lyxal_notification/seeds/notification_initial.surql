-- ============================================================================
-- SEEDS : socle de lyxal_notification
-- MODULE : lyxal_notification
-- ============================================================================
-- Rejouable et non destructif : chaque élément est créé seulement s'il n'existe pas ; rien n'est
-- modifié. `scope_key` est écrit explicitement (l'import des seeds ne calcule pas les champs
-- VALUE). Les parcours de lyxal_auth sont critiques (seuls un rejet définitif ou un blocage
-- manuel les arrêtent) et sensibles (aucun objet conservé). La permission notification.worker
-- n'est attribuée à aucun rôle : elle est réservée au compte de service du worker.

-- ----------------------------------------------------------------------------
-- Permissions et attribution aux rôles du socle de lyxal_auth
-- ----------------------------------------------------------------------------

IF !record::exists(auth_permission:⟨notification.read⟩) THEN (
    CREATE auth_permission:⟨notification.read⟩ CONTENT { code: "notification.read", module: "lyxal_notification", scope: "organization", description: { fr: "Voir les parcours, gabarits, réglages et l'activité des notifications de son organisation", en: "See one's organization notification workflows, templates, settings and activity" } }
) END;
IF !record::exists(auth_permission:⟨notification.manage⟩) THEN (
    CREATE auth_permission:⟨notification.manage⟩ CONTENT { code: "notification.manage", module: "lyxal_notification", scope: "organization", description: { fr: "Gérer les parcours, gabarits, mises en page, réglages et la liste de suppression de son organisation", en: "Manage one's organization notification workflows, templates, layouts, settings and suppression list" } }
) END;
IF !record::exists(auth_permission:⟨notification.send⟩) THEN (
    CREATE auth_permission:⟨notification.send⟩ CONTENT { code: "notification.send", module: "lyxal_notification", scope: "organization", description: { fr: "Déclencher les parcours de notification de son organisation", en: "Trigger one's organization notification workflows" } }
) END;
IF !record::exists(auth_permission:⟨notification.installation.manage⟩) THEN (
    CREATE auth_permission:⟨notification.installation.manage⟩ CONTENT { code: "notification.installation.manage", module: "lyxal_notification", scope: "installation", description: { fr: "Gérer les notifications de l'installation (parcours, gabarits, réglages, activité)", en: "Manage installation notifications (workflows, templates, settings, activity)" } }
) END;
IF !record::exists(auth_permission:⟨notification.worker⟩) THEN (
    CREATE auth_permission:⟨notification.worker⟩ CONTENT { code: "notification.worker", module: "lyxal_notification", scope: "installation", description: { fr: "Compte de service du worker d'envoi : file d'envoi de toutes les portées", en: "Delivery worker service account: delivery queue of every scope" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨notification.read⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨notification.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨notification.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨notification.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨notification.send⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨notification.send⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨notification.installation.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨notification.installation.manage⟩
) END;

-- ----------------------------------------------------------------------------
-- Réglages et mise en page de l'installation
-- ----------------------------------------------------------------------------

IF !record::exists(notification_settings:installation) THEN (
    CREATE notification_settings:installation CONTENT {
        scope_key: "installation",
        max_attempts: 8,
        retention_days_runs: 90,
        retention_days_log: 30
    }
) END;

IF !record::exists(notification_layout:default) THEN (
    CREATE notification_layout:default CONTENT {
        scope_key: "installation",
        key: "default",
        name: "Mise en page par défaut",
        html: "<!DOCTYPE html>\n<html>\n<head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"></head>\n<body style=\"margin:0;padding:24px;background:#f4f4f5;font-family:Arial,Helvetica,sans-serif;color:#18181b;\">\n<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\"><tr><td align=\"center\">\n<table role=\"presentation\" width=\"560\" cellpadding=\"0\" cellspacing=\"0\" style=\"max-width:560px;background:#ffffff;border-radius:8px;padding:32px;\"><tr><td>\n{{ content }}\n</td></tr></table>\n</td></tr></table>\n</body>\n</html>\n",
        text: "{{ content }}\n"
    }
) END;

-- ----------------------------------------------------------------------------
-- Parcours de lyxal_auth (installation) ; textes : notification_texts.surql
-- ----------------------------------------------------------------------------

IF !record::exists(notification_workflow:auth_verification) THEN (
    CREATE notification_workflow:auth_verification CONTENT {
        scope_key: "installation",
        key: "auth_verification",
        name: "Vérification d'adresse e-mail",
        trigger_event: "auth.verification.requested",
        status: "active",
        critical: true,
        sensitive: true,
        payload_schema: { fields: { identity_id: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] } }, unknown_keys: "reject" },
        steps: [{ key: "email", channel: "email" }],
        tags: ["auth"]
    }
) END;
IF !record::exists(notification_template:auth_verification_email) THEN (
    CREATE notification_template:auth_verification_email CONTENT {
        workflow: notification_workflow:auth_verification, step_key: "email", layout: notification_layout:default,
        subject: "{{ t(\"notification.auth_verification.subject\") }}",
        html_body: "<p>{% if recipient.name %}{{ t(\"notification.common.greeting_named\", name=recipient.name) }}{% else %}{{ t(\"notification.common.greeting\") }}{% endif %}</p>\n<p>{{ t(\"notification.auth_verification.intro\") }}</p>\n<p><strong>{{ secret.code }}</strong></p>\n<p><a href=\"{{ secret.action_url }}\">{{ t(\"notification.auth_verification.action\") }}</a></p>\n<p>{{ t(\"notification.auth_verification.ignore\") }}</p>",
        text_body: "{% if recipient.name %}{{ t(\"notification.common.greeting_named\", name=recipient.name) }}{% else %}{{ t(\"notification.common.greeting\") }}{% endif %}\n\n{{ t(\"notification.auth_verification.intro\") }}\n\n{{ secret.code }}\n{{ secret.action_url }}\n\n{{ t(\"notification.auth_verification.ignore\") }}\n",
        keys: ["notification.common.greeting", "notification.common.greeting_named", "notification.auth_verification.subject", "notification.auth_verification.intro", "notification.auth_verification.action", "notification.auth_verification.ignore"]
    }
) END;
IF !record::exists(notification_workflow:auth_recovery) THEN (
    CREATE notification_workflow:auth_recovery CONTENT {
        scope_key: "installation",
        key: "auth_recovery",
        name: "Récupération de compte",
        trigger_event: "auth.recovery.requested",
        status: "active",
        critical: true,
        sensitive: true,
        payload_schema: { fields: { identity_id: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] } }, unknown_keys: "reject" },
        steps: [{ key: "email", channel: "email" }],
        tags: ["auth"]
    }
) END;
IF !record::exists(notification_template:auth_recovery_email) THEN (
    CREATE notification_template:auth_recovery_email CONTENT {
        workflow: notification_workflow:auth_recovery, step_key: "email", layout: notification_layout:default,
        subject: "{{ t(\"notification.auth_recovery.subject\") }}",
        html_body: "<p>{% if recipient.name %}{{ t(\"notification.common.greeting_named\", name=recipient.name) }}{% else %}{{ t(\"notification.common.greeting\") }}{% endif %}</p>\n<p>{{ t(\"notification.auth_recovery.intro\") }}</p>\n<p><strong>{{ secret.code }}</strong></p>\n<p><a href=\"{{ secret.action_url }}\">{{ t(\"notification.auth_recovery.action\") }}</a></p>\n<p>{{ t(\"notification.auth_recovery.ignore\") }}</p>",
        text_body: "{% if recipient.name %}{{ t(\"notification.common.greeting_named\", name=recipient.name) }}{% else %}{{ t(\"notification.common.greeting\") }}{% endif %}\n\n{{ t(\"notification.auth_recovery.intro\") }}\n\n{{ secret.code }}\n{{ secret.action_url }}\n\n{{ t(\"notification.auth_recovery.ignore\") }}\n",
        keys: ["notification.common.greeting", "notification.common.greeting_named", "notification.auth_recovery.subject", "notification.auth_recovery.intro", "notification.auth_recovery.action", "notification.auth_recovery.ignore"]
    }
) END;
IF !record::exists(notification_workflow:auth_invitation) THEN (
    CREATE notification_workflow:auth_invitation CONTENT {
        scope_key: "installation",
        key: "auth_invitation",
        name: "Invitation dans une organisation",
        trigger_event: "auth.invitation.created",
        status: "active",
        critical: true,
        sensitive: true,
        payload_schema: { fields: { invitation_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true }, organization_name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true }, inviter_name: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] } }, unknown_keys: "reject" },
        steps: [{ key: "email", channel: "email" }],
        tags: ["auth"]
    }
) END;
IF !record::exists(notification_template:auth_invitation_email) THEN (
    CREATE notification_template:auth_invitation_email CONTENT {
        workflow: notification_workflow:auth_invitation, step_key: "email", layout: notification_layout:default,
        subject: "{{ t(\"notification.auth_invitation.subject\", organization=payload.organization_name) }}",
        html_body: "<p>{% if recipient.name %}{{ t(\"notification.common.greeting_named\", name=recipient.name) }}{% else %}{{ t(\"notification.common.greeting\") }}{% endif %}</p>\n<p>{% if payload.inviter_name %}{{ t(\"notification.auth_invitation.intro_by\", inviter=payload.inviter_name, organization=payload.organization_name) }}{% else %}{{ t(\"notification.auth_invitation.intro\", organization=payload.organization_name) }}{% endif %}</p>\n<p><a href=\"{{ secret.action_url }}\">{{ t(\"notification.auth_invitation.action\") }}</a></p>\n<p>{{ t(\"notification.auth_invitation.ignore\") }}</p>",
        text_body: "{% if recipient.name %}{{ t(\"notification.common.greeting_named\", name=recipient.name) }}{% else %}{{ t(\"notification.common.greeting\") }}{% endif %}\n\n{% if payload.inviter_name %}{{ t(\"notification.auth_invitation.intro_by\", inviter=payload.inviter_name, organization=payload.organization_name) }}{% else %}{{ t(\"notification.auth_invitation.intro\", organization=payload.organization_name) }}{% endif %}\n\n{{ t(\"notification.auth_invitation.action\") }} : {{ secret.action_url }}\n\n{{ t(\"notification.auth_invitation.ignore\") }}\n",
        keys: ["notification.common.greeting", "notification.common.greeting_named", "notification.auth_invitation.subject", "notification.auth_invitation.intro", "notification.auth_invitation.intro_by", "notification.auth_invitation.action", "notification.auth_invitation.ignore"]
    }
) END;

-- ----------------------------------------------------------------------------
-- Alertes de sécurité de lyxal_auth (double facteur, mot de passe), sans secret
-- ----------------------------------------------------------------------------

IF !record::exists(notification_workflow:auth_security_alert) THEN (
    CREATE notification_workflow:auth_security_alert CONTENT {
        scope_key: "installation",
        key: "auth_security_alert",
        name: "Alerte de sécurité",
        status: "active",
        critical: true,
        sensitive: false,
        payload_schema: { fields: {
            alert: { pipeline: [{ rule: "enum", options: { allowed: ["mfa_enrolled", "mfa_removed", "recovery_codes_generated", "recovery_code_used", "password_changed", "passkey_clone_detected"], case_sensitive: true } }], required: true },
            method: { pipeline: [{ rule: "optional_string", options: { max_length: 32 } }] },
            label: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            reason: { pipeline: [{ rule: "optional_string", options: { max_length: 32 } }] },
            remaining: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 20 } }] }
        }, unknown_keys: "reject" },
        steps: [{ key: "email", channel: "email" }],
        tags: ["auth", "security"]
    }
) END;
IF !record::exists(notification_template:auth_security_alert_email) THEN (
    CREATE notification_template:auth_security_alert_email CONTENT {
        workflow: notification_workflow:auth_security_alert, step_key: "email", layout: notification_layout:default,
        subject: "{{ t(\"notification.auth_security_alert.subject\") }}",
        html_body: "<p>{% if recipient.name %}{{ t(\"notification.common.greeting_named\", name=recipient.name) }}{% else %}{{ t(\"notification.common.greeting\") }}{% endif %}</p>\n<p>{% if payload.alert == \"mfa_enrolled\" %}{% if payload.method == \"totp\" %}{{ t(\"notification.auth_security_alert.mfa_enrolled_totp\") }}{% else %}{% if payload.label %}{{ t(\"notification.auth_security_alert.mfa_enrolled_passkey_named\", label=payload.label) }}{% else %}{{ t(\"notification.auth_security_alert.mfa_enrolled_passkey\") }}{% endif %}{% endif %}{% elif payload.alert == \"mfa_removed\" %}{% if payload.reason == \"admin_reset\" %}{{ t(\"notification.auth_security_alert.mfa_removed_admin\") }}{% else %}{% if payload.method == \"totp\" %}{{ t(\"notification.auth_security_alert.mfa_removed_totp\") }}{% else %}{% if payload.label %}{{ t(\"notification.auth_security_alert.mfa_removed_passkey_named\", label=payload.label) }}{% else %}{{ t(\"notification.auth_security_alert.mfa_removed_passkey\") }}{% endif %}{% endif %}{% endif %}{% elif payload.alert == \"recovery_codes_generated\" %}{{ t(\"notification.auth_security_alert.recovery_codes_generated\") }}{% elif payload.alert == \"recovery_code_used\" %}{{ t(\"notification.auth_security_alert.recovery_code_used\", remaining=payload.remaining) }}{% elif payload.alert == \"password_changed\" %}{{ t(\"notification.auth_security_alert.password_changed\") }}{% else %}{% if payload.label %}{{ t(\"notification.auth_security_alert.passkey_clone_detected_named\", label=payload.label) }}{% else %}{{ t(\"notification.auth_security_alert.passkey_clone_detected\") }}{% endif %}{% endif %}</p>\n<p>{{ t(\"notification.auth_security_alert.advice\") }}</p>",
        text_body: "{% if recipient.name %}{{ t(\"notification.common.greeting_named\", name=recipient.name) }}{% else %}{{ t(\"notification.common.greeting\") }}{% endif %}\n\n{% if payload.alert == \"mfa_enrolled\" %}{% if payload.method == \"totp\" %}{{ t(\"notification.auth_security_alert.mfa_enrolled_totp\") }}{% else %}{% if payload.label %}{{ t(\"notification.auth_security_alert.mfa_enrolled_passkey_named\", label=payload.label) }}{% else %}{{ t(\"notification.auth_security_alert.mfa_enrolled_passkey\") }}{% endif %}{% endif %}{% elif payload.alert == \"mfa_removed\" %}{% if payload.reason == \"admin_reset\" %}{{ t(\"notification.auth_security_alert.mfa_removed_admin\") }}{% else %}{% if payload.method == \"totp\" %}{{ t(\"notification.auth_security_alert.mfa_removed_totp\") }}{% else %}{% if payload.label %}{{ t(\"notification.auth_security_alert.mfa_removed_passkey_named\", label=payload.label) }}{% else %}{{ t(\"notification.auth_security_alert.mfa_removed_passkey\") }}{% endif %}{% endif %}{% endif %}{% elif payload.alert == \"recovery_codes_generated\" %}{{ t(\"notification.auth_security_alert.recovery_codes_generated\") }}{% elif payload.alert == \"recovery_code_used\" %}{{ t(\"notification.auth_security_alert.recovery_code_used\", remaining=payload.remaining) }}{% elif payload.alert == \"password_changed\" %}{{ t(\"notification.auth_security_alert.password_changed\") }}{% else %}{% if payload.label %}{{ t(\"notification.auth_security_alert.passkey_clone_detected_named\", label=payload.label) }}{% else %}{{ t(\"notification.auth_security_alert.passkey_clone_detected\") }}{% endif %}{% endif %}\n\n{{ t(\"notification.auth_security_alert.advice\") }}\n",
        keys: ["notification.common.greeting", "notification.common.greeting_named", "notification.auth_security_alert.subject", "notification.auth_security_alert.mfa_enrolled_totp", "notification.auth_security_alert.mfa_enrolled_passkey", "notification.auth_security_alert.mfa_enrolled_passkey_named", "notification.auth_security_alert.mfa_removed_admin", "notification.auth_security_alert.mfa_removed_totp", "notification.auth_security_alert.mfa_removed_passkey", "notification.auth_security_alert.mfa_removed_passkey_named", "notification.auth_security_alert.recovery_codes_generated", "notification.auth_security_alert.recovery_code_used", "notification.auth_security_alert.password_changed", "notification.auth_security_alert.passkey_clone_detected", "notification.auth_security_alert.passkey_clone_detected_named", "notification.auth_security_alert.advice"]
    }
) END;
