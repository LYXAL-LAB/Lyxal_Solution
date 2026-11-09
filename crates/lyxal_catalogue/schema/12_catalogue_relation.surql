-- ============================================================================
-- TABLE  : catalogue_relation
-- MODULE : lyxal_catalogue
-- RÔLE   : Graphe de relations inter-éléments
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_relation
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::catalogue_access({ is_custom: source.is_custom, tenant: source.tenant, action: "read" }) AND fn::catalogue_access({ is_custom: cible.is_custom, tenant: cible.tenant, action: "read" })
        FOR create, update, delete WHERE fn::catalogue_access({ is_custom: source.is_custom, tenant: source.tenant, action: "read" }) AND fn::catalogue_access({ is_custom: cible.is_custom, tenant: cible.tenant, action: "read" }) AND (
            (source.is_custom = false AND cible.is_custom = false AND fn::catalogue_access({ is_custom: source.is_custom, tenant: source.tenant, action: "write" }))
            OR (source.is_custom = true AND fn::catalogue_access({ is_custom: source.is_custom, tenant: source.tenant, action: "write" }))
            OR (cible.is_custom = true AND fn::catalogue_access({ is_custom: cible.is_custom, tenant: cible.tenant, action: "write" }))
        )
    COMMENT "Relations transversales entre éléments du catalogue";


DEFINE FIELD OVERWRITE source ON TABLE catalogue_relation
    TYPE record<catalogue_item>
    REFERENCE
    COMMENT "Élément source";

DEFINE FIELD OVERWRITE cible ON TABLE catalogue_relation
    TYPE record<catalogue_item>
    REFERENCE
    ASSERT $value != source
    COMMENT "Élément cible (l'auto-référence source == cible est interdite)";

DEFINE FIELD OVERWRITE relation_type ON TABLE catalogue_relation
    TYPE record<catalogue_relation_type>
    REFERENCE
    COMMENT "Type de qualification du lien";

DEFINE FIELD OVERWRITE ordre ON TABLE catalogue_relation
    TYPE int
    DEFAULT 0
    COMMENT "Ordre de présentation";

DEFINE FIELD OVERWRITE commentaire ON TABLE catalogue_relation
    TYPE option<string>
    COMMENT "Note explicative du lien";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_relation
    TYPE bool
    DEFAULT true
    COMMENT "Statut de la liaison";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_relation
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

-- Unicité absolue du triplet (source, cible, type)
DEFINE INDEX OVERWRITE idx_cat_rel_unique ON TABLE catalogue_relation FIELDS source, cible, relation_type UNIQUE;

-- Index de recherche inversée (rechercher les éléments qui pointent vers une cible)
DEFINE INDEX OVERWRITE idx_cat_rel_reverse ON TABLE catalogue_relation FIELDS cible, relation_type;

-- ============================================================================
-- VERROU MOTEUR : Gardien d'intégrité relationnelle universel
-- ============================================================================
DEFINE EVENT OVERWRITE evt_catalogue_relation_guard ON TABLE catalogue_relation
WHEN ($event = "CREATE" OR $event = "UPDATE" OR $event = "DELETE")
THEN {
    -- Droits de l'appelant (sessions lyxal_auth) ; la session système passe les contrôles
    LET $c = fn::catalogue_caller({});
    LET $is_sync_auth = $c.sync AND !$c.system;
    LET $is_member = !$c.system AND !$c.sync;
    LET $caller_tenant = $c.tenant;

    -- 1. Contrôle des anciennes extrémités ($before) lors d'un UPDATE ou DELETE
    IF $event = "UPDATE" OR $event = "DELETE" {
        LET $b_src = (SELECT is_custom, tenant FROM ONLY $before.source);
        LET $b_tgt = (SELECT is_custom, tenant FROM ONLY $before.cible);

        IF $is_sync_auth {
            IF ($b_src != NONE AND $b_src.is_custom = true) OR ($b_tgt != NONE AND $b_tgt.is_custom = true) {
                THROW "CATALOGUE_RELATION_SYNC_CANNOT_ACCESS_CUSTOM: Le compte de synchronisation ne doit pas modifier ou supprimer des relations impliquant des articles privés.";
            };
        } ELSE IF $is_member {
            -- Aucune des anciennes extrémités ne doit appartenir à un autre tenant
            IF $b_src != NONE AND $b_src.is_custom = true AND $b_src.tenant != $caller_tenant {
                THROW "CATALOGUE_RELATION_BEFORE_SOURCE_UNAUTHORIZED: L'article source d'origine appartient à un autre locataire.";
            };
            IF $b_tgt != NONE AND $b_tgt.is_custom = true AND $b_tgt.tenant != $caller_tenant {
                THROW "CATALOGUE_RELATION_BEFORE_TARGET_UNAUTHORIZED: L'article cible d'origine appartient à un autre locataire.";
            };
            -- Un locataire ne peut pas modifier ou supprimer une relation reliant deux articles maîtres
            IF ($b_src != NONE AND $b_src.is_custom = false) AND ($b_tgt != NONE AND $b_tgt.is_custom = false) {
                THROW "CATALOGUE_RELATION_CANNOT_ALTER_MASTER: Un locataire ne peut pas modifier ou supprimer une relation liant deux articles maîtres.";
            };
        };
    };

    -- 2. Contrôle des nouvelles extrémités ($after) lors d'un CREATE ou UPDATE
    IF $event = "CREATE" OR $event = "UPDATE" {
        LET $a_src = (SELECT is_custom, tenant FROM ONLY $after.source);
        LET $a_tgt = (SELECT is_custom, tenant FROM ONLY $after.cible);

        IF $is_sync_auth {
            IF ($a_src != NONE AND $a_src.is_custom = true) OR ($a_tgt != NONE AND $a_tgt.is_custom = true) {
                THROW "CATALOGUE_RELATION_SYNC_CANNOT_ACCESS_CUSTOM: Le compte de synchronisation ne peut lier que des articles maîtres.";
            };
        } ELSE IF $is_member {
            -- Aucune des nouvelles extrémités ne doit appartenir à un autre tenant
            IF $a_src != NONE AND $a_src.is_custom = true AND $a_src.tenant != $caller_tenant {
                THROW "CATALOGUE_RELATION_AFTER_SOURCE_UNAUTHORIZED: L'article source spécifié appartient à un autre locataire.";
            };
            IF $a_tgt != NONE AND $a_tgt.is_custom = true AND $a_tgt.tenant != $caller_tenant {
                THROW "CATALOGUE_RELATION_AFTER_TARGET_UNAUTHORIZED: L'article cible spécifié appartient à un autre locataire.";
            };
            -- Au moins une extrémité doit être un article privé du locataire
            IF ($a_src != NONE AND $a_src.is_custom = false) AND ($a_tgt != NONE AND $a_tgt.is_custom = false) {
                THROW "CATALOGUE_RELATION_CANNOT_LINK_MASTER: Un locataire ne peut pas créer ou modifier une relation liant exclusivement des articles maîtres.";
            };
        };

        -- 3. Contrôle strict de la relation COMMERCIAL_SPECIFICATION (Commerciale -> Générique)
        IF $after.relation_type = catalogue_relation_type:COMMERCIAL_SPECIFICATION {
            LET $src = (SELECT * FROM ONLY $after.source);
            LET $tgt = (SELECT * FROM ONLY $after.cible);
            IF $src.nature_reference != "COMMERCIALE" OR $tgt.nature_reference != "GENERIQUE" {
                THROW "CATALOGUE_RELATION_COMMERCIAL_SPEC_INVALID: La relation COMMERCIAL_SPECIFICATION exige une source commerciale et une cible générique.";
            };
        };

        -- 4. Contrôle de la relation REMPLACEMENT (Cible active, non obsolète et anti-cycle récursif)
        IF $after.relation_type = catalogue_relation_type:REMPLACEMENT {
            LET $tgt = (SELECT * FROM ONLY $after.cible);
            IF $tgt.enabled != true OR $tgt.statut_commercial = "OBSOLETE" {
                THROW "CATALOGUE_RELATION_REMPLACEMENT_TARGET_INVALID: L'article cible de remplacement doit être actif et non obsolète.";
            };
            LET $cycle_res = fn::catalogue_relation_check_cycle({
                source: $after.source,
                cible: $after.cible,
                relation_type: $after.relation_type
            });
            IF $cycle_res = "CYCLE_DETECTED" OR $cycle_res = true {
                THROW "CATALOGUE_RELATION_REMPLACEMENT_CYCLE: Détection d'un cycle de remplacement interdit.";
            };
            IF $cycle_res = "DEPTH_EXCEEDED" {
                THROW "CATALOGUE_RELATION_CYCLE_DEPTH_EXCEEDED: Limite technique de profondeur atteinte lors du contrôle anti-cycle.";
            };
        };
    };
};
