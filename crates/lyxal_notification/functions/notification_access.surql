-- ============================================================================
-- FONCTION : fn::notification_can
-- MODULE   : lyxal_notification
-- RÔLE     : Droits du module, par action et par portée (organisation ou installation)
-- ============================================================================
-- Permissions déclarées par le seed du module auprès de lyxal_auth :
--   organisation : notification.read, notification.manage, notification.send ;
--   installation : notification.installation.manage (parcours, gabarits et réglages de
--   l'installation, activité de l'installation), notification.worker (compte de service du
--   worker : file d'envoi, toutes portées).
-- Jamais d'erreur (utilisable dans une clause PERMISSIONS).

DEFINE FUNCTION OVERWRITE fn::notification_can($params: object) -> bool {
    IF fn::auth_session_valid({}).system { RETURN true; };
    LET $worker = fn::auth_has_permission({ permission: "notification.worker" });
    IF $params.action = "worker" { RETURN $worker; };
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
} COMMENT "Vrai si l'appelant peut effectuer l'action ({ action : read, manage, send, worker ; tenant : organisation ou NONE pour l'installation }). Jamais d'erreur";
