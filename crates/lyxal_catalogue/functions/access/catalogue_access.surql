-- ============================================================================
-- FONCTIONS : droits du catalogue (sessions lyxal_auth)
-- MODULE    : lyxal_catalogue
-- ============================================================================
-- Le catalogue ne connaît que les permissions qu'il déclare (seed) et l'organisation active de
-- la session, fournies par lyxal_auth (fn::auth_has_permission, relu à chaque appel) :
--   catalogue.item.read   (organisation) : catalogue partagé et articles privés de l'organisation ;
--   catalogue.item.manage (organisation) : articles privés et personnalisations de l'organisation ;
--   catalogue.master.write (installation) : lecture et écriture des articles maîtres (compte de
--   service de synchronisation, sans organisation active, sans accès aux articles privés).

-- ----------------------------------------------------------------------------
-- fn::catalogue_caller : droits de l'appelant (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::catalogue_caller($params: object) -> object {
    -- Contrat public de lyxal_auth : session contrôlée et organisation active
    LET $context = fn::auth_context({});
    IF !$context.ok { RETURN { valid: false, system: false, sync: false, tenant: NONE, read: false, manage: false }; };
    IF $context.data.system { RETURN { valid: true, system: true, sync: true, tenant: NONE, read: true, manage: true }; };
    LET $tenant = $context.data.organization;
    RETURN {
        valid: true,
        system: false,
        sync: fn::auth_has_permission({ permission: "catalogue.master.write" }),
        tenant: $tenant,
        read: $tenant IS NOT NONE AND fn::auth_has_permission({ permission: "catalogue.item.read", tenant: $tenant }),
        manage: $tenant IS NOT NONE AND fn::auth_has_permission({ permission: "catalogue.item.manage", tenant: $tenant })
    };
} COMMENT "Droits de l'appelant sur le catalogue : { valid, system, sync (catalogue.master.write), tenant (organisation active), read (catalogue.item.read), manage (catalogue.item.manage) }";

-- ----------------------------------------------------------------------------
-- fn::catalogue_access : droit sur un article (clauses PERMISSIONS, jamais d'erreur)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::catalogue_access($params: object) -> bool {
    LET $c = fn::catalogue_caller({});
    IF !$c.valid { RETURN false; };
    IF $c.system { RETURN true; };
    -- Article maître : lecture par les membres (catalogue.item.read) et par le compte de
    -- synchronisation ; écriture par le seul compte de synchronisation ; jamais supprimé
    IF $params.is_custom == false {
        RETURN IF $params.action = "read" { $c.sync OR $c.read } ELSE IF $params.action = "write" { $c.sync } ELSE { false };
    };
    -- Article privé : organisation active propriétaire ; jamais le compte de synchronisation
    IF $c.sync OR $c.tenant IS NONE OR $params.tenant IS NONE OR $params.tenant != $c.tenant { RETURN false; };
    RETURN IF $params.action = "read" { $c.read } ELSE { $c.manage };
} COMMENT "Vrai si l'appelant peut agir sur un article ({ is_custom, tenant, action : read | write | delete }) : article maître lu par catalogue.item.read ou catalogue.master.write, écrit par catalogue.master.write, jamais supprimé ; article privé de l'organisation active lu par catalogue.item.read, écrit ou supprimé par catalogue.item.manage. Jamais d'erreur";
