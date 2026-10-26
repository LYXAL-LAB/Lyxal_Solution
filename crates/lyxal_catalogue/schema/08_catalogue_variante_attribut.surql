-- ============================================================================
-- TABLE  : catalogue_variante_attribut
-- MODULE : lyxal_catalogue
-- RÔLE   : Matrice d'affectation universelle des attributs (Item statique & Variante)
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_variante_attribut
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND (
                ($token.role = "catalogue_sync_agent" AND item.is_custom = false)
                OR ($token.role = "tenant_user" AND (item.is_custom = false OR (item.is_custom = true AND item.tenant_id != NONE AND $token.tenant_id != NONE AND item.tenant_id = $token.tenant_id)))
            ))
            OR ($token == NONE AND $auth != NONE AND (
                ($auth.role = "catalogue_sync_agent" AND item.is_custom = false)
                OR ($auth.role = "tenant_user" AND (item.is_custom = false OR (item.is_custom = true AND item.tenant_id != NONE AND $auth.tenant_id != NONE AND item.tenant_id = $auth.tenant_id)))
            ))
        )
        FOR create, update, delete WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND (
                ($token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $token.scope AND item.is_custom = false)
                OR ($token.role = "tenant_user" AND item.is_custom = true AND item.tenant_id != NONE AND $token.tenant_id != NONE AND item.tenant_id = $token.tenant_id)
            ))
            OR ($token == NONE AND $auth != NONE AND (
                ($auth.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $auth.permissions AND item.is_custom = false)
                OR ($auth.role = "tenant_user" AND item.is_custom = true AND item.tenant_id != NONE AND $auth.tenant_id != NONE AND item.tenant_id = $auth.tenant_id)
            ))
        )
    COMMENT "Affectations des attributs statiques (Item) et différentiateurs (Variante)";

DEFINE FIELD OVERWRITE item ON TABLE catalogue_variante_attribut
    TYPE record<catalogue_item>
    REFERENCE
    COMMENT "Élément parent";

DEFINE FIELD OVERWRITE variante ON TABLE catalogue_variante_attribut
    TYPE option<record<catalogue_variante>>
    REFERENCE
    COMMENT "Variante rattachée (NONE s'il s'agit d'un attribut commun de l'item parent)";

DEFINE FIELD OVERWRITE attribut ON TABLE catalogue_variante_attribut
    TYPE record<catalogue_attribut>
    REFERENCE
    COMMENT "Attribut assigné";

DEFINE FIELD OVERWRITE attribut_valeur ON TABLE catalogue_variante_attribut
    TYPE record<catalogue_attribut_valeur>
    REFERENCE
    COMMENT "Valeur affectée";

-- Scope cible dérivé exclusivement de la variante (si présente) ou de l'item (recalcul forcé sans valeur arbitraire)
DEFINE FIELD OVERWRITE target_scope ON TABLE catalogue_variante_attribut
    VALUE IF variante != NONE { <string> variante } ELSE { <string> item }
    COMMENT "Scope calculé garantissant l'unicité stricte par entité cible";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_variante_attribut
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date d'affectation";

-- Unicité absolue : une cible (item ou variante) ne peut avoir qu'une seule valeur pour un attribut donné
DEFINE INDEX OVERWRITE idx_scope_attr ON TABLE catalogue_variante_attribut 
    FIELDS target_scope, attribut UNIQUE;

-- Index de recherche inversée pour filtrage catalogue par valeur d'attribut
DEFINE INDEX OVERWRITE idx_attr_val_lookup ON TABLE catalogue_variante_attribut 
    FIELDS attribut, attribut_valeur;

-- ----------------------------------------------------------------------------
-- VERROU MOTEUR : Recalcul automatique et garanti de l'empreinte de la variante
-- Déclenché à chaque CREATE, UPDATE ou DELETE d'attribut de variante
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_cva_recalc_fingerprint ON TABLE catalogue_variante_attribut
WHEN ($event = "CREATE" OR $event = "UPDATE" OR $event = "DELETE")
THEN {
    -- 1. Recalcul pour la variante cible ($after sur CREATE/UPDATE, $before sur DELETE)
    LET $target_var = IF $event = "DELETE" { $before.variante } ELSE { $after.variante };
    IF $target_var != NONE {
        -- Calcule déterministement la nouvelle empreinte canonique à partir de l'état réel en base
        LET $attrs = (SELECT attribut, attribut_valeur FROM catalogue_variante_attribut WHERE variante = $target_var);
        LET $pairs = array::sort(array::map($attrs, |$a| string::concat(<string> $a.attribut, ":", <string> $a.attribut_valeur)));
        LET $fingerprint = crypto::sha256(array::join($pairs, "|"));
        
        -- Met à jour atomiquement l'empreinte sur la variante parente
        UPDATE ONLY $target_var SET empreinte_attributs = $fingerprint;
    };

    -- 2. Recalcul pour la variante source si déplacement ($event = "UPDATE" avec changement de variante)
    IF $event = "UPDATE" AND $before.variante != NONE AND $before.variante != $after.variante {
        LET $src_attrs = (SELECT attribut, attribut_valeur FROM catalogue_variante_attribut WHERE variante = $before.variante);
        LET $src_pairs = array::sort(array::map($src_attrs, |$a| string::concat(<string> $a.attribut, ":", <string> $a.attribut_valeur)));
        LET $src_fingerprint = crypto::sha256(array::join($src_pairs, "|"));
        UPDATE ONLY $before.variante SET empreinte_attributs = $src_fingerprint;
    };
};
