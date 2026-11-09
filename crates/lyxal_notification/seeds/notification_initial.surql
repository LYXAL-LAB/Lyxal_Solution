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
        default_locale: "fr",
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
-- Parcours de lyxal_auth (installation), gabarits fr et en
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
        workflow: notification_workflow:auth_verification, step_key: "email", default_locale: "fr", layout: notification_layout:default
    }
) END;
IF !record::exists(notification_template_locale:auth_verification_email_fr) THEN (
    CREATE notification_template_locale:auth_verification_email_fr CONTENT {
        template: notification_template:auth_verification_email,
        locale: "fr",
        subject: "Confirmez votre adresse e-mail",
        html_body: "<p>Bonjour{% if recipient.name %} {{ recipient.name }}{% endif %},</p>\n<p>Pour confirmer votre adresse e-mail, utilisez le code <strong>{{ secret.code }}</strong> ou ouvrez le lien ci-dessous.</p>\n<p><a href=\"{{ secret.action_url }}\">Confirmer mon adresse</a></p>\n<p>Si vous n'êtes pas à l'origine de cette demande, ignorez ce message.</p>",
        text_body: "Bonjour{% if recipient.name %} {{ recipient.name }}{% endif %},\n\nPour confirmer votre adresse e-mail, utilisez le code {{ secret.code }} ou ouvrez ce lien :\n{{ secret.action_url }}\n\nSi vous n'êtes pas à l'origine de cette demande, ignorez ce message.\n"
    }
) END;
IF !record::exists(notification_template_locale:auth_verification_email_en) THEN (
    CREATE notification_template_locale:auth_verification_email_en CONTENT {
        template: notification_template:auth_verification_email,
        locale: "en",
        subject: "Confirm your email address",
        html_body: "<p>Hello{% if recipient.name %} {{ recipient.name }}{% endif %},</p>\n<p>To confirm your email address, use the code <strong>{{ secret.code }}</strong> or open the link below.</p>\n<p><a href=\"{{ secret.action_url }}\">Confirm my address</a></p>\n<p>If you did not request this, ignore this message.</p>",
        text_body: "Hello{% if recipient.name %} {{ recipient.name }}{% endif %},\n\nTo confirm your email address, use the code {{ secret.code }} or open this link:\n{{ secret.action_url }}\n\nIf you did not request this, ignore this message.\n"
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
        workflow: notification_workflow:auth_recovery, step_key: "email", default_locale: "fr", layout: notification_layout:default
    }
) END;
IF !record::exists(notification_template_locale:auth_recovery_email_fr) THEN (
    CREATE notification_template_locale:auth_recovery_email_fr CONTENT {
        template: notification_template:auth_recovery_email,
        locale: "fr",
        subject: "Récupération de votre compte",
        html_body: "<p>Bonjour{% if recipient.name %} {{ recipient.name }}{% endif %},</p>\n<p>Pour récupérer l'accès à votre compte, utilisez le code <strong>{{ secret.code }}</strong> ou ouvrez le lien ci-dessous.</p>\n<p><a href=\"{{ secret.action_url }}\">Récupérer mon compte</a></p>\n<p>Si vous n'êtes pas à l'origine de cette demande, ignorez ce message : votre mot de passe reste inchangé.</p>",
        text_body: "Bonjour{% if recipient.name %} {{ recipient.name }}{% endif %},\n\nPour récupérer l'accès à votre compte, utilisez le code {{ secret.code }} ou ouvrez ce lien :\n{{ secret.action_url }}\n\nSi vous n'êtes pas à l'origine de cette demande, ignorez ce message : votre mot de passe reste inchangé.\n"
    }
) END;
IF !record::exists(notification_template_locale:auth_recovery_email_en) THEN (
    CREATE notification_template_locale:auth_recovery_email_en CONTENT {
        template: notification_template:auth_recovery_email,
        locale: "en",
        subject: "Recover your account",
        html_body: "<p>Hello{% if recipient.name %} {{ recipient.name }}{% endif %},</p>\n<p>To recover access to your account, use the code <strong>{{ secret.code }}</strong> or open the link below.</p>\n<p><a href=\"{{ secret.action_url }}\">Recover my account</a></p>\n<p>If you did not request this, ignore this message: your password is unchanged.</p>",
        text_body: "Hello{% if recipient.name %} {{ recipient.name }}{% endif %},\n\nTo recover access to your account, use the code {{ secret.code }} or open this link:\n{{ secret.action_url }}\n\nIf you did not request this, ignore this message: your password is unchanged.\n"
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
        workflow: notification_workflow:auth_invitation, step_key: "email", default_locale: "fr", layout: notification_layout:default
    }
) END;
IF !record::exists(notification_template_locale:auth_invitation_email_fr) THEN (
    CREATE notification_template_locale:auth_invitation_email_fr CONTENT {
        template: notification_template:auth_invitation_email,
        locale: "fr",
        subject: "Invitation à rejoindre {{ payload.organization_name }}",
        html_body: "<p>Bonjour{% if recipient.name %} {{ recipient.name }}{% endif %},</p>\n<p>{% if payload.inviter_name %}{{ payload.inviter_name }} vous invite{% else %}Vous êtes invité{% endif %} à rejoindre l'organisation <strong>{{ payload.organization_name }}</strong>.</p>\n<p><a href=\"{{ secret.action_url }}\">Accepter l'invitation</a></p>\n<p>Si vous ne vous attendiez pas à cette invitation, ignorez ce message.</p>",
        text_body: "Bonjour{% if recipient.name %} {{ recipient.name }}{% endif %},\n\n{% if payload.inviter_name %}{{ payload.inviter_name }} vous invite{% else %}Vous êtes invité{% endif %} à rejoindre l'organisation {{ payload.organization_name }}.\n\nAccepter l'invitation : {{ secret.action_url }}\n\nSi vous ne vous attendiez pas à cette invitation, ignorez ce message.\n"
    }
) END;
IF !record::exists(notification_template_locale:auth_invitation_email_en) THEN (
    CREATE notification_template_locale:auth_invitation_email_en CONTENT {
        template: notification_template:auth_invitation_email,
        locale: "en",
        subject: "Invitation to join {{ payload.organization_name }}",
        html_body: "<p>Hello{% if recipient.name %} {{ recipient.name }}{% endif %},</p>\n<p>{% if payload.inviter_name %}{{ payload.inviter_name }} invites you{% else %}You are invited{% endif %} to join the organization <strong>{{ payload.organization_name }}</strong>.</p>\n<p><a href=\"{{ secret.action_url }}\">Accept the invitation</a></p>\n<p>If you were not expecting this invitation, ignore this message.</p>",
        text_body: "Hello{% if recipient.name %} {{ recipient.name }}{% endif %},\n\n{% if payload.inviter_name %}{{ payload.inviter_name }} invites you{% else %}You are invited{% endif %} to join the organization {{ payload.organization_name }}.\n\nAccept the invitation: {{ secret.action_url }}\n\nIf you were not expecting this invitation, ignore this message.\n"
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
        workflow: notification_workflow:auth_security_alert, step_key: "email", default_locale: "fr", layout: notification_layout:default
    }
) END;
IF !record::exists(notification_template_locale:auth_security_alert_email_fr) THEN (
    CREATE notification_template_locale:auth_security_alert_email_fr CONTENT {
        template: notification_template:auth_security_alert_email,
        locale: "fr",
        subject: "Alerte de sécurité sur votre compte",
        html_body: "<p>Bonjour{% if recipient.name %} {{ recipient.name }}{% endif %},</p>\n<p>{% if payload.alert == \"mfa_enrolled\" %}Un second facteur a été ajouté à votre compte : {% if payload.method == \"totp\" %}application d'authentification{% else %}passkey{% if payload.label %} « {{ payload.label }} »{% endif %}{% endif %}.{% elif payload.alert == \"mfa_removed\" %}{% if payload.reason == \"admin_reset\" %}Un administrateur a retiré tous les seconds facteurs de votre compte ; vos sessions ont été fermées.{% else %}Un second facteur a été retiré de votre compte : {% if payload.method == \"totp\" %}application d'authentification{% else %}passkey{% if payload.label %} « {{ payload.label }} »{% endif %}{% endif %}.{% endif %}{% elif payload.alert == \"recovery_codes_generated\" %}De nouveaux codes de secours ont été générés ; les précédents ne fonctionnent plus.{% elif payload.alert == \"recovery_code_used\" %}Un code de secours a été utilisé pour vous connecter. Il vous en reste {{ payload.remaining }}.{% elif payload.alert == \"password_changed\" %}Le mot de passe de votre compte a été changé.{% else %}Une passkey de votre compte{% if payload.label %} (« {{ payload.label }} »){% endif %} a été refusée : elle semble avoir été copiée. Retirez-la et enregistrez-en une nouvelle.{% endif %}</p>\n<p>Si vous n'êtes pas à l'origine de cette action, changez votre mot de passe et prévenez votre administrateur.</p>",
        text_body: "Bonjour{% if recipient.name %} {{ recipient.name }}{% endif %},\n\n{% if payload.alert == \"mfa_enrolled\" %}Un second facteur a été ajouté à votre compte : {% if payload.method == \"totp\" %}application d'authentification{% else %}passkey{% if payload.label %} « {{ payload.label }} »{% endif %}{% endif %}.{% elif payload.alert == \"mfa_removed\" %}{% if payload.reason == \"admin_reset\" %}Un administrateur a retiré tous les seconds facteurs de votre compte ; vos sessions ont été fermées.{% else %}Un second facteur a été retiré de votre compte : {% if payload.method == \"totp\" %}application d'authentification{% else %}passkey{% if payload.label %} « {{ payload.label }} »{% endif %}{% endif %}.{% endif %}{% elif payload.alert == \"recovery_codes_generated\" %}De nouveaux codes de secours ont été générés ; les précédents ne fonctionnent plus.{% elif payload.alert == \"recovery_code_used\" %}Un code de secours a été utilisé pour vous connecter. Il vous en reste {{ payload.remaining }}.{% elif payload.alert == \"password_changed\" %}Le mot de passe de votre compte a été changé.{% else %}Une passkey de votre compte{% if payload.label %} (« {{ payload.label }} »){% endif %} a été refusée : elle semble avoir été copiée. Retirez-la et enregistrez-en une nouvelle.{% endif %}\n\nSi vous n'êtes pas à l'origine de cette action, changez votre mot de passe et prévenez votre administrateur.\n"
    }
) END;
IF !record::exists(notification_template_locale:auth_security_alert_email_en) THEN (
    CREATE notification_template_locale:auth_security_alert_email_en CONTENT {
        template: notification_template:auth_security_alert_email,
        locale: "en",
        subject: "Security alert on your account",
        html_body: "<p>Hello{% if recipient.name %} {{ recipient.name }}{% endif %},</p>\n<p>{% if payload.alert == \"mfa_enrolled\" %}A second factor was added to your account: {% if payload.method == \"totp\" %}authenticator app{% else %}passkey{% if payload.label %} “{{ payload.label }}”{% endif %}{% endif %}.{% elif payload.alert == \"mfa_removed\" %}{% if payload.reason == \"admin_reset\" %}An administrator removed all second factors from your account; your sessions were closed.{% else %}A second factor was removed from your account: {% if payload.method == \"totp\" %}authenticator app{% else %}passkey{% if payload.label %} “{{ payload.label }}”{% endif %}{% endif %}.{% endif %}{% elif payload.alert == \"recovery_codes_generated\" %}New recovery codes were generated; the previous ones no longer work.{% elif payload.alert == \"recovery_code_used\" %}A recovery code was used to sign in. You have {{ payload.remaining }} left.{% elif payload.alert == \"password_changed\" %}Your account password was changed.{% else %}A passkey on your account{% if payload.label %} (“{{ payload.label }}”){% endif %} was refused: it appears to have been copied. Remove it and register a new one.{% endif %}</p>\n<p>If you did not do this, change your password and tell your administrator.</p>",
        text_body: "Hello{% if recipient.name %} {{ recipient.name }}{% endif %},\n\n{% if payload.alert == \"mfa_enrolled\" %}A second factor was added to your account: {% if payload.method == \"totp\" %}authenticator app{% else %}passkey{% if payload.label %} “{{ payload.label }}”{% endif %}{% endif %}.{% elif payload.alert == \"mfa_removed\" %}{% if payload.reason == \"admin_reset\" %}An administrator removed all second factors from your account; your sessions were closed.{% else %}A second factor was removed from your account: {% if payload.method == \"totp\" %}authenticator app{% else %}passkey{% if payload.label %} “{{ payload.label }}”{% endif %}{% endif %}.{% endif %}{% elif payload.alert == \"recovery_codes_generated\" %}New recovery codes were generated; the previous ones no longer work.{% elif payload.alert == \"recovery_code_used\" %}A recovery code was used to sign in. You have {{ payload.remaining }} left.{% elif payload.alert == \"password_changed\" %}Your account password was changed.{% else %}A passkey on your account{% if payload.label %} (“{{ payload.label }}”){% endif %} was refused: it appears to have been copied. Remove it and register a new one.{% endif %}\n\nIf you did not do this, change your password and tell your administrator.\n"
    }
) END;
