-- lyxal-test: assertions
-- Socle : permissions déclarées auprès de lyxal_auth et attribuées aux rôles du socle, réglages
-- et mise en page de l'installation, parcours actifs de lyxal_auth avec gabarits fr et en.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["notification.installation.manage"] }

-- préparation: identité et session de l'administrateur de l'installation
{
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: cinq permissions du module, une portée chacune
RETURN array::len(SELECT * FROM auth_permission WHERE module = "lyxal_notification") == 5
    AND (SELECT VALUE code FROM auth_permission WHERE module = "lyxal_notification" AND scope = "installation" ORDER BY code)
        == ["notification.installation.manage", "notification.worker"];

-- test: permissions attribuées aux rôles du socle ; le worker n'est attribué à aucun rôle
RETURN (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:organization_admin).filter(|$c| string::starts_with($c, "notification.")).sort()
        == ["notification.manage", "notification.read", "notification.send"]
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:platform_admin).filter(|$c| string::starts_with($c, "notification.")) == ["notification.installation.manage"]
    AND array::len(SELECT * FROM auth_role_grants WHERE out = auth_permission:⟨notification.worker⟩) == 0;

-- test: réglages effectifs de l'installation
-- en tant que: plateforme
RETURN fn::notification_settings_get({}).data.effective == { from_name: NONE, reply_to: NONE, max_attempts: 8, retention_days_runs: 90, retention_days_log: 30 };

-- test: quatre parcours actifs et critiques pour lyxal_auth : trois messages sensibles déclenchés par leur événement, l'alerte de sécurité déclenchée par sa clé
-- en tant que: plateforme
RETURN fn::notification_workflow_list({ status: "active" }).data.map(|$w| [$w.key, $w.trigger_event, $w.critical, $w.sensitive]) == [
    ["auth_invitation", "auth.invitation.created", true, true],
    ["auth_recovery", "auth.recovery.requested", true, true],
    ["auth_security_alert", NONE, true, false],
    ["auth_verification", "auth.verification.requested", true, true]
];

-- test: chaque parcours a un seul gabarit e-mail, avec la mise en page par défaut et ses clés de traduction
-- en tant que: plateforme
RETURN fn::notification_workflow_get({ workflow: "notification_workflow:auth_invitation" }).data.templates.map(|$t| [$t.step_key, $t.layout, $t.keys])
    == [["email", notification_layout:default, ["notification.common.greeting", "notification.common.greeting_named", "notification.auth_invitation.subject", "notification.auth_invitation.intro", "notification.auth_invitation.intro_by", "notification.auth_invitation.action", "notification.auth_invitation.ignore"]]];

-- test: toutes les clés des gabarits du système sont déclarées, avec un texte français (source) et un texte anglais
RETURN array::len(SELECT VALUE id FROM i18n_key WHERE namespace = i18n_namespace:notification) == 29
    AND array::len(SELECT VALUE id FROM i18n_translation WHERE key.namespace = i18n_namespace:notification AND locale = i18n_locale:⟨fr⟩ AND is_source) == 29
    AND array::len(SELECT VALUE id FROM i18n_translation WHERE key.namespace = i18n_namespace:notification AND locale = i18n_locale:⟨en⟩) == 29
    AND array::distinct(array::flatten(SELECT VALUE keys FROM notification_template)).all(|$k| record::exists(type::record("i18n_key", $k)))
    AND array::len(array::distinct(array::flatten(SELECT VALUE keys FROM notification_template))) == 29;

-- test: l'alerte de sécurité a son gabarit et ses clés ; sa charge utile est contrôlée
-- en tant que: plateforme
RETURN fn::notification_workflow_get({ workflow: "notification_workflow:auth_security_alert" }).data.templates.map(|$t| [$t.step_key, array::len($t.keys)])
    == [["email", 16]]
    AND fn::notification_trigger({ workflow_key: "auth_security_alert", idempotency_key: "alerte-invalide", recipient: { email: "a@exemple.fr" }, payload: { alert: "inconnue" } }).error.code == "NOTIFICATION_PAYLOAD_INVALID";

-- test: la mise en page par défaut contient l'emplacement du contenu
-- en tant que: plateforme
RETURN fn::notification_layout_list({}).data.key == ["default"]
    AND string::contains(fn::notification_layout_get({ layout: "notification_layout:default" }).data.html, "{{ content }}");
