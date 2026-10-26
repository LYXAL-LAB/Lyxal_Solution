-- ============================================================================
-- TABLE  : catalogue_item
-- MODULE : lyxal_catalogue
-- RÔLE   : Identité universelle de tout produit, service, ressource, ouvrage ou ensemble
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_item
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND (
                ($token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $token.scope AND is_custom = false)
                OR ($token.role = "tenant_user" AND (is_custom = false OR (is_custom = true AND tenant_id != NONE AND $token.tenant_id != NONE AND tenant_id = $token.tenant_id)))
            ))
            OR ($token == NONE AND $auth != NONE AND (
                ($auth.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $auth.permissions AND is_custom = false)
                OR ($auth.role = "tenant_user" AND (is_custom = false OR (is_custom = true AND tenant_id != NONE AND $auth.tenant_id != NONE AND tenant_id = $auth.tenant_id)))
            ))
        )
        FOR create WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND (
                ($token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $token.scope AND is_custom = false)
                OR ($token.role = "tenant_user" AND is_custom = true AND master_id == NONE AND tenant_id != NONE AND $token.tenant_id != NONE AND tenant_id = $token.tenant_id)
            ))
            OR ($token == NONE AND $auth != NONE AND (
                ($auth.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $auth.permissions AND is_custom = false)
                OR ($auth.role = "tenant_user" AND is_custom = true AND master_id == NONE AND tenant_id != NONE AND $auth.tenant_id != NONE AND tenant_id = $auth.tenant_id)
            ))
        )
        FOR update WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND (
                ($token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $token.scope AND is_custom = false)
                OR ($token.role = "tenant_user" AND (
                    (is_custom = true AND tenant_id != NONE AND $token.tenant_id != NONE AND tenant_id = $token.tenant_id)
                    OR (is_custom = false AND master_id != NONE)
                ))
            ))
            OR ($token == NONE AND $auth != NONE AND (
                ($auth.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $auth.permissions AND is_custom = false)
                OR ($auth.role = "tenant_user" AND (
                    (is_custom = true AND tenant_id != NONE AND $auth.tenant_id != NONE AND tenant_id = $auth.tenant_id)
                    OR (is_custom = false AND master_id != NONE)
                ))
            ))
        )
        FOR delete WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND (
                $token.role = "tenant_user" AND is_custom = true AND tenant_id != NONE AND $token.tenant_id != NONE AND tenant_id = $token.tenant_id
            ))
            OR ($token == NONE AND $auth != NONE AND (
                $auth.role = "tenant_user" AND is_custom = true AND tenant_id != NONE AND $auth.tenant_id != NONE AND tenant_id = $auth.tenant_id
            ))
        )
    COMMENT "Identité universelle des éléments du catalogue (génériques et commerciaux)";

DEFINE FIELD OVERWRITE code ON TABLE catalogue_item
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Code de référence unique de l'élément";

DEFINE FIELD OVERWRITE type ON TABLE catalogue_item
    TYPE record<catalogue_type>
    REFERENCE
    COMMENT "Type fondamental de l'élément";

DEFINE FIELD OVERWRITE libelle ON TABLE catalogue_item
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 255
    COMMENT "Désignation principale";

DEFINE FIELD OVERWRITE description ON TABLE catalogue_item
    TYPE option<string>
    COMMENT "Description technique ou commerciale";

DEFINE FIELD OVERWRITE unite_reference ON TABLE catalogue_item
    TYPE record<base_unite>
    REFERENCE
    COMMENT "Unité de mesure principale de référence";

DEFINE FIELD OVERWRITE is_composite ON TABLE catalogue_item
    TYPE bool
    DEFAULT false
    COMMENT "Indique si l'élément possède une composition active";

DEFINE FIELD OVERWRITE has_variants ON TABLE catalogue_item
    TYPE bool
    DEFAULT false
    COMMENT "Indique si l'élément se décline en variantes";

-- ----------------------------------------------------------------------------
-- Caractéristiques des références commerciales et cycle de vie
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE nature_reference ON TABLE catalogue_item
    TYPE string
    DEFAULT "GENERIQUE"
    ASSERT $value IN ["GENERIQUE", "COMMERCIALE"]
    COMMENT "Distingue un article générique normatif d'une référence commerciale de fabricant";

DEFINE FIELD OVERWRITE fabricant ON TABLE catalogue_item
    TYPE option<string>
    VALUE IF $value != NONE { string::uppercase(string::trim($value)) } ELSE { NONE }
    ASSERT $value == NONE OR (string::len($value) >= 1 AND string::len($value) <= 128)
    COMMENT "Raison sociale ou identité normalisée du fabricant";

DEFINE FIELD OVERWRITE marque ON TABLE catalogue_item
    TYPE option<string>
    VALUE IF $value != NONE { string::uppercase(string::trim($value)) } ELSE { NONE }
    ASSERT $value == NONE OR (string::len($value) >= 1 AND string::len($value) <= 128)
    COMMENT "Marque commerciale sous laquelle l'article est distribué";

DEFINE FIELD OVERWRITE reference_fabricant ON TABLE catalogue_item
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    ASSERT $value == NONE OR (string::len($value) >= 1 AND string::len($value) <= 64)
    COMMENT "Code article officiel attribué par le fabricant";

DEFINE FIELD OVERWRITE code_barre ON TABLE catalogue_item
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    ASSERT $value == NONE OR (
        string::is_numeric($value) 
        AND (string::len($value) = 8 OR string::len($value) = 12 OR string::len($value) = 13 OR string::len($value) = 14)
    )
    COMMENT "Identifiant mondial standard GS1 (EAN/GTIN)";

DEFINE FIELD OVERWRITE statut_commercial ON TABLE catalogue_item
    TYPE string
    DEFAULT "ACTIF"
    ASSERT $value IN ["ACTIF", "FIN_DE_SERIE", "OBSOLETE", "REMPLACE"]
    COMMENT "Cycle de vie commercial (permet de maintenir les chantiers passés tout en interdisant les nouveaux devis)";

DEFINE FIELD OVERWRITE documents ON TABLE catalogue_item
    TYPE option<array<object>>
    DEFAULT []
    COMMENT "Ensemble des documents techniques rattachés (FDS, FT, DoP/CE, Avis CSTB, FDES)";

DEFINE FIELD OVERWRITE documents[*] ON TABLE catalogue_item
    TYPE object;

DEFINE FIELD OVERWRITE documents[*].type ON TABLE catalogue_item
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT $value IN ["FT", "FDS", "DOP", "AVIS_TECHNIQUE", "FDES", "MANUEL", "CERTIFICAT", "AUTRE"]
    COMMENT "Type de documentation normalisée";

DEFINE FIELD OVERWRITE documents[*].titre ON TABLE catalogue_item
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1
    COMMENT "Titre ou désignation du document";

DEFINE FIELD OVERWRITE documents[*].url ON TABLE catalogue_item
    TYPE string
    VALUE string::trim($value)
    ASSERT string::starts_with($value, "http://") OR string::starts_with($value, "https://")
    COMMENT "Lien d'accès web sécurisé vers le document";

DEFINE FIELD OVERWRITE documents[*].date ON TABLE catalogue_item
    TYPE option<datetime>
    COMMENT "Date de publication ou version du document";

DEFINE FIELD OVERWRITE documents[*].version ON TABLE catalogue_item
    TYPE option<string>
    COMMENT "Indice de révision ou version";

DEFINE FIELD OVERWRITE conditionnement ON TABLE catalogue_item
    TYPE option<object>
    COMMENT "Caractéristiques physiques intrinsèques du conditionnement produit";

DEFINE FIELD OVERWRITE conditionnement.type_unite ON TABLE catalogue_item
    TYPE option<record<base_unite>>
    COMMENT "Unité physique de conditionnement (ex: base_unite:PCE, base_unite:ROUL)";

DEFINE FIELD OVERWRITE conditionnement.quantite ON TABLE catalogue_item
    TYPE option<decimal>
    ASSERT $value == NONE OR $value > 0
    COMMENT "Quantité unitaire de référence contenue dans le conditionnement";

DEFINE FIELD OVERWRITE conditionnement.poids_kg ON TABLE catalogue_item
    TYPE option<decimal>
    ASSERT $value == NONE OR $value >= 0
    COMMENT "Poids brut unitaire en kilogrammes";

DEFINE FIELD OVERWRITE conditionnement.volume_m3 ON TABLE catalogue_item
    TYPE option<decimal>
    ASSERT $value == NONE OR $value >= 0
    COMMENT "Volume unitaire en mètres cubes";

DEFINE FIELD OVERWRITE conditionnement.dimensions ON TABLE catalogue_item
    TYPE option<object>
    COMMENT "Dimensions géométriques physiques";

DEFINE FIELD OVERWRITE conditionnement.dimensions.longueur ON TABLE catalogue_item
    TYPE option<decimal>
    ASSERT $value == NONE OR $value >= 0
    COMMENT "Longueur en mm";

DEFINE FIELD OVERWRITE conditionnement.dimensions.largeur ON TABLE catalogue_item
    TYPE option<decimal>
    ASSERT $value == NONE OR $value >= 0
    COMMENT "Largeur en mm";

DEFINE FIELD OVERWRITE conditionnement.dimensions.epaisseur ON TABLE catalogue_item
    TYPE option<decimal>
    ASSERT $value == NONE OR $value >= 0
    COMMENT "Épaisseur ou hauteur en mm";

DEFINE FIELD OVERWRITE conditionnement.dimensions.diametre ON TABLE catalogue_item
    TYPE option<decimal>
    ASSERT $value == NONE OR $value >= 0
    COMMENT "Diamètre en mm";

-- ----------------------------------------------------------------------------
-- Champs de Synchronisation Master / Tenant et personnalisations locales
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE master_id ON TABLE catalogue_item
    TYPE option<string>
    COMMENT "Identifiant immuable de l'article dans le Master Catalogue (ex: catalogue_item:PLACO_BA13_2500)";

DEFINE FIELD OVERWRITE is_custom ON TABLE catalogue_item
    TYPE bool
    DEFAULT true
    COMMENT "true si l'article est une création privée locale, false si synchronisé du Master";

DEFINE FIELD OVERWRITE code_interne_client ON TABLE catalogue_item
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    COMMENT "Code article personnalisé propre à l'organisation cliente";

DEFINE FIELD OVERWRITE libelle_personnalise ON TABLE catalogue_item
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    COMMENT "Désignation commerciale locale affichée sur les devis à la place du libellé officiel";

DEFINE FIELD OVERWRITE tenant_id ON TABLE catalogue_item
    TYPE option<string>
    DEFAULT IF $token.tenant_id != NONE { $token.tenant_id } ELSE IF $auth.tenant_id != NONE { $auth.tenant_id } ELSE { NONE }
    READONLY
    COMMENT "Identifiant de l'organisation cliente propriétaire (pour les articles privés)";

-- ----------------------------------------------------------------------------
-- Métadonnées et contrôles système
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE metadata ON TABLE catalogue_item
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Métadonnées libres complémentaires";

DEFINE FIELD OVERWRITE metadata.is_master_sync ON TABLE catalogue_item
    TYPE option<bool>
    COMMENT "Indicateur d'autorisation pour les flux de synchronisation Master";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_item
    TYPE bool
    DEFAULT true
    COMMENT "Indique si l'élément est actif pour de nouveaux documents";

DEFINE FIELD OVERWRITE is_system ON TABLE catalogue_item
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Indique si l'élément fait partie du socle immuable";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_item
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_item
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière mise à jour";

-- ============================================================================
-- INDEX
-- ============================================================================
DEFINE INDEX OVERWRITE idx_catalogue_item_code ON TABLE catalogue_item FIELDS code UNIQUE;
DEFINE INDEX OVERWRITE idx_catalogue_item_type ON TABLE catalogue_item FIELDS type;
DEFINE INDEX OVERWRITE idx_catalogue_item_enabled ON TABLE catalogue_item FIELDS enabled;
DEFINE INDEX OVERWRITE idx_catalogue_item_nature ON TABLE catalogue_item FIELDS nature_reference;
DEFINE INDEX OVERWRITE idx_catalogue_item_statut ON TABLE catalogue_item FIELDS statut_commercial;

-- Unicité stricte des identifiants commerciaux et maîtres
DEFINE INDEX OVERWRITE idx_catalogue_item_code_barre ON TABLE catalogue_item FIELDS code_barre UNIQUE;
DEFINE INDEX OVERWRITE idx_catalogue_item_fab_ref ON TABLE catalogue_item FIELDS fabricant, reference_fabricant UNIQUE;
DEFINE INDEX OVERWRITE idx_catalogue_item_master_id ON TABLE catalogue_item FIELDS master_id UNIQUE;
DEFINE INDEX OVERWRITE idx_catalogue_item_tenant ON TABLE catalogue_item FIELDS tenant_id;

-- ============================================================================
-- VERROU MOTEUR : Gardien d'intégrité universel contre les écritures directes
-- ============================================================================
DEFINE EVENT OVERWRITE evt_catalogue_item_guard ON TABLE catalogue_item
WHEN ($event = "CREATE" OR $event = "UPDATE" OR $event = "DELETE")
THEN {
    -- 1. Contrôle d'intégrité de la nature générique vs commerciale (sur CREATE et UPDATE)
    IF $event != "DELETE" {
        IF $after.nature_reference = "GENERIQUE" {
            IF $after.fabricant != NONE OR $after.marque != NONE OR $after.reference_fabricant != NONE OR $after.code_barre != NONE {
                THROW "CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND: Un article générique ne peut comporter ni fabricant, ni marque, ni référence usine, ni code-barres.";
            };
        };
        IF $after.nature_reference = "COMMERCIALE" {
            IF $after.fabricant == NONE AND $after.marque == NONE {
                THROW "CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND: Un article commercial doit obligatoirement spécifier un fabricant ou une marque.";
            };
        };

        -- 2. Validation de la clé de contrôle GS1 Modulo 10 si code_barre est fourni
        IF $after.code_barre != NONE {
            LET $is_gtin_valid = fn::catalogue_validate_gtin($after.code_barre);
            IF $is_gtin_valid != true {
                THROW "CATALOGUE_ITEM_GTIN_INVALID: Le code GTIN/EAN est invalide (clé de contrôle GS1 modulo 10 incorrecte).";
            };
        };
    };

    -- 3. Vérification de l'identité de service de synchronisation
    LET $is_sync_auth = (
        ($token != NONE 
        AND $token.role = "catalogue_sync_agent" 
        AND $token.iss = "lyxal-os"
        AND $token.aud = "lyxal-catalogue"
        AND "catalogue:sync:write" IN $token.scope)
        OR
        ($auth != NONE 
        AND $auth.role = "catalogue_sync_agent" 
        AND "catalogue:sync:write" IN $auth.permissions)
    );

    -- 4. Protection absolue en suppression
    IF $event = "DELETE" {
        IF $before.is_custom = false {
            THROW "CATALOGUE_ITEM_MASTER_CANNOT_BE_DELETED: Les articles synchronisés du Master Catalogue ne peuvent pas être supprimés localement.";
        };
        IF $before.is_custom = true {
            IF $is_sync_auth {
                THROW "CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM: Le service catalogue_sync_agent ne doit pas modifier ou supprimer les articles privés des clients.";
            };
            LET $caller_role = IF $token != NONE AND $token.role != NONE { string::trim($token.role) } ELSE IF $auth != NONE AND $auth.role != NONE { string::trim($auth.role) } ELSE { NONE };
            IF $caller_role != "tenant_user" {
                THROW "CATALOGUE_ITEM_TENANT_REQUIRED: Toute opération sur un article privé exige une identité cliente avec le rôle tenant_user.";
            };
            IF $before.tenant_id == NONE OR string::len(string::trim($before.tenant_id)) == 0 {
                THROW "CATALOGUE_ITEM_TENANT_ORPHAN: Article privé orphelin sans propriétaire vérifiable : suppression interdite.";
            };
            LET $caller_tenant = IF $token != NONE AND $token.tenant_id != NONE { string::trim($token.tenant_id) } ELSE IF $auth != NONE AND $auth.tenant_id != NONE { string::trim($auth.tenant_id) } ELSE { NONE };
            IF $caller_tenant == NONE OR $caller_tenant != $before.tenant_id {
                THROW "CATALOGUE_ITEM_TENANT_FORBIDDEN: Suppression interdite : cet article privé appartient à une autre organisation.";
            };
        };
    };

    -- 5. Protection absolue en création
    IF $event = "CREATE" {
        IF $after.is_custom = false AND !$is_sync_auth {
            THROW "CATALOGUE_ITEM_SYNC_CANNOT_CREATE_MASTER: Seul l'agent de synchronisation officiel peut injecter des articles maîtres.";
        };
        IF $after.is_custom = true AND $after.master_id != NONE {
            THROW "CATALOGUE_ITEM_CUSTOM_CANNOT_HAVE_MASTER_ID: Un article privé ne peut pas avoir d'identifiant maître.";
        };
        IF $after.is_custom = true {
            IF $is_sync_auth {
                THROW "CATALOGUE_ITEM_SYNC_CANNOT_CREATE_CUSTOM: Le service catalogue_sync_agent ne peut pas créer d'articles privés pour les clients.";
            };
            LET $caller_role = IF $token != NONE AND $token.role != NONE { string::trim($token.role) } ELSE IF $auth != NONE AND $auth.role != NONE { string::trim($auth.role) } ELSE { NONE };
            IF $caller_role != "tenant_user" {
                THROW "CATALOGUE_ITEM_TENANT_REQUIRED: Toute opération sur un article privé exige une identité cliente avec le rôle tenant_user.";
            };
            IF $after.tenant_id == NONE OR string::len(string::trim($after.tenant_id)) == 0 {
                THROW "CATALOGUE_ITEM_TENANT_REQUIRED: Tout article privé doit obligatoirement avoir un propriétaire tenant_id vérifiable.";
            };
            LET $caller_tenant = IF $token != NONE AND $token.tenant_id != NONE { string::trim($token.tenant_id) } ELSE IF $auth != NONE AND $auth.tenant_id != NONE { string::trim($auth.tenant_id) } ELSE { NONE };
            IF $caller_tenant == NONE OR $after.tenant_id != $caller_tenant {
                THROW "CATALOGUE_ITEM_TENANT_FORBIDDEN: Le propriétaire tenant_id doit obligatoirement être déduit de l'identité cliente authentifiée.";
            };
        };
    };

    -- 6. Contrôles stricts en modification
    IF $event = "UPDATE" {
        IF $after.tenant_id != $before.tenant_id {
            THROW "CATALOGUE_ITEM_TENANT_ID_IMMUTABLE: Le propriétaire tenant_id d'un article est strictement immuable.";
        };
        IF $before.is_custom = true AND $after.is_custom = false {
            THROW "CATALOGUE_ITEM_CUSTOM_CANNOT_CONVERT_MASTER: Un article privé ne peut pas être converti en article maître.";
        };

        -- Protection des articles privés contre les tiers et contre catalogue_sync_agent
        IF $before.is_custom = true {
            IF $is_sync_auth {
                THROW "CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM: Le service catalogue_sync_agent ne doit pas lire ou modifier les articles privés des clients.";
            };
            LET $caller_role = IF $token != NONE AND $token.role != NONE { string::trim($token.role) } ELSE IF $auth != NONE AND $auth.role != NONE { string::trim($auth.role) } ELSE { NONE };
            IF $caller_role != "tenant_user" {
                THROW "CATALOGUE_ITEM_TENANT_REQUIRED: Toute opération sur un article privé exige une identité cliente avec le rôle tenant_user.";
            };
            IF $before.tenant_id == NONE OR string::len(string::trim($before.tenant_id)) == 0 {
                THROW "CATALOGUE_ITEM_TENANT_ORPHAN: Article privé orphelin sans propriétaire vérifiable : modification interdite.";
            };
            LET $caller_tenant = IF $token != NONE AND $token.tenant_id != NONE { string::trim($token.tenant_id) } ELSE IF $auth != NONE AND $auth.tenant_id != NONE { string::trim($auth.tenant_id) } ELSE { NONE };
            IF $caller_tenant == NONE OR $caller_tenant != $before.tenant_id {
                THROW "CATALOGUE_ITEM_TENANT_FORBIDDEN: Cet article privé appartient exclusivement à une autre organisation cliente.";
            };
        };
    };

    -- 6. Protection absolue des champs maîtres synchronisés contre les modifications locales
    IF $event = "UPDATE" AND $before.is_custom = false AND $before.master_id != NONE {
        IF $after.master_id != $before.master_id {
            THROW "CATALOGUE_ITEM_MASTER_ID_IMMUTABLE: L'identifiant maître d'un article synchronisé est strictement immuable.";
        };
        IF $after.is_custom = true {
            THROW "CATALOGUE_ITEM_SYNC_CANNOT_CONVERT_CUSTOM: Un article synchronisé du Master ne peut pas être converti en article privé.";
        };

        -- Si non autorisé explicitement par le Master, TOUS les champs maîtres sont strictement protégés
        -- (enabled est modifiable localement par le locataire, statut_commercial reste exclusif Master)
        IF !$is_sync_auth {
            IF $after.code != $before.code 
               OR $after.type != $before.type 
               OR $after.nature_reference != $before.nature_reference
               OR $after.fabricant != $before.fabricant
               OR $after.marque != $before.marque
               OR $after.reference_fabricant != $before.reference_fabricant
               OR $after.code_barre != $before.code_barre
               OR $after.unite_reference != $before.unite_reference
               OR $after.conditionnement != $before.conditionnement
               OR $after.documents != $before.documents
               OR $after.libelle != $before.libelle
               OR $after.description != $before.description
               OR $after.statut_commercial != $before.statut_commercial {
                THROW "CATALOGUE_ITEM_SYNC_FIELD_PROTECTED: Les spécifications maîtresses d'un article synchronisé ne peuvent être modifiées que par le flux Master officiel.";
            };
        };

        -- Si appel de l'agent de synchronisation :
        -- 1. Interdiction formelle d'écraser les personnalisations locales du client !
        -- 2. Interdiction formelle de réactiver un article désactivé localement par le client !
        IF $is_sync_auth {
            IF $after.code_interne_client != $before.code_interne_client 
               OR $after.libelle_personnalise != $before.libelle_personnalise {
                THROW "CATALOGUE_ITEM_SYNC_CANNOT_OVERWRITE_LOCAL_CUSTOMIZATION: La synchronisation Master ne peut en aucun cas modifier ou écraser les personnalisations locales du client.";
            };
            IF $before.enabled = false AND $after.enabled = true {
                THROW "CATALOGUE_ITEM_SYNC_CANNOT_REACTIVATE_DISABLED: Une mise à jour Master ne peut jamais réactiver un article désactivé localement par l'organisation cliente.";
            };
        };
    };
};
