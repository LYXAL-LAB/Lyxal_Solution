-- ============================================================================
-- FONCTION : fn::notification_can
-- MODULE   : lyxal_notification
-- RÔLE     : Droits du module, par action et par portée (organisation ou installation)
-- ============================================================================
-- Permissions déclarées par le seed du module auprès de lyxal_auth :
--   organisation : notification.read, notification.manage, notification.send ;
--   (action read_config : la configuration de l'installation est lisible par tout détenteur d'une
--   permission d'organisation, car elle sert de repli) ;
--   installation : notification.installation.manage (parcours, gabarits et réglages de
--   l'installation, activité de l'installation), notification.worker (compte de service du
--   worker : file d'envoi, toutes portées).
-- Jamais d'erreur (utilisable dans une clause PERMISSIONS).

DEFINE FUNCTION OVERWRITE fn::notification_can($params: object) -> bool {
    IF fn::auth_session_valid({}).system { RETURN true; };
    LET $worker = fn::auth_has_permission({ permission: "notification.worker" });
    IF $params.action = "worker" { RETURN $worker; };
    -- Configuration (réglages, parcours, mises en page, gabarits) : lue par qui déclenche, lit
    -- ou gère dans l'organisation ; celle de l'installation sert de repli à toute organisation
    IF $params.action = "read_config" {
        IF $worker { RETURN true; };
        LET $org = IF $params.tenant IS NONE { fn::auth_context({}).data.organization } ELSE { $params.tenant };
        IF $params.tenant IS NONE AND fn::auth_has_permission({ permission: "notification.installation.manage" }) { RETURN true; };
        RETURN $org IS NOT NONE AND array::any(["notification.read", "notification.manage", "notification.send"],
            |$code| fn::auth_has_permission({ permission: $code, tenant: $org }));
    };
    IF $params.tenant IS NONE {
        RETURN fn::auth_has_permission({ permission: "notification.installation.manage" })
            OR ($worker AND $params.action IN ["read", "send"]);
    };
    IF $params.action = "read" {
        RETURN $worker OR fn::auth_has_permission({ permission: "notification.read", tenant: $params.tenant });
    };
    IF $params.action = "send" {
        RETURN $worker OR fn::auth_has_permission({ permission: "notification.send", tenant: $params.tenant });
    };
    IF $params.action = "manage" {
        RETURN fn::auth_has_permission({ permission: "notification.manage", tenant: $params.tenant });
    };
    RETURN false;
} COMMENT "Vrai si l'appelant peut effectuer l'action ({ action : read, read_config, manage, send, worker ; tenant : organisation ou NONE pour l'installation }). Jamais d'erreur";
