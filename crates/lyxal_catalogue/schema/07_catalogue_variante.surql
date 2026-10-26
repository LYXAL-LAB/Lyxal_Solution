-- ============================================================================
-- TABLE  : catalogue_variante
-- MODULE : lyxal_catalogue
-- RÔLE   : Déclinaisons physiques/commerciales d'un item parent
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_variante
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
    COMMENT "Déclinaisons et variantes d'un élément";

DEFINE FIELD OVERWRITE item ON TABLE catalogue_variante
    TYPE record<catalogue_item>
    REFERENCE
    COMMENT "Item parent porteur de la variante";

DEFINE FIELD OVERWRITE code ON TABLE catalogue_variante
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Code de référence unique de la déclinaison (ex: SKU)";

DEFINE FIELD OVERWRITE libelle ON TABLE catalogue_variante
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 255
    COMMENT "Libellé complet de la variante";

DEFINE FIELD OVERWRITE reference_fabricant ON TABLE catalogue_variante
    TYPE option<string>
    COMMENT "Référence catalogue fabricant/fournisseur";

DEFINE FIELD OVERWRITE code_barre ON TABLE catalogue_variante
    TYPE option<string>
    COMMENT "Code EAN ou code-barres";

-- L'empreinte canonique est recalculée déterministement par le moteur
DEFINE FIELD OVERWRITE empreinte_attributs ON TABLE catalogue_variante
    VALUE IF $value != NONE AND $value != "" { $value } ELSE { crypto::sha256(string::concat(<string> item, ":", <string> code)) }
    COMMENT "Empreinte canonique SHA-256 de la combinaison d'attributs";

DEFINE FIELD OVERWRITE is_default ON TABLE catalogue_variante
    TYPE bool
    DEFAULT false
    COMMENT "Indique si c'est la variante sélectionnée par défaut";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_variante
    TYPE bool
    DEFAULT true
    COMMENT "Statut d'activation de la variante";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_variante
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_variante
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de mise à jour";

-- Index d'unicité globale du code variante
DEFINE INDEX OVERWRITE idx_catalogue_variante_code ON TABLE catalogue_variante FIELDS code UNIQUE;

-- Index d'unicité de la combinaison d'attributs par item
DEFINE INDEX OVERWRITE idx_var_item_fingerprint ON TABLE catalogue_variante FIELDS item, empreinte_attributs UNIQUE;

-- Index de recherche par item parent
DEFINE INDEX OVERWRITE idx_catalogue_variante_item ON TABLE catalogue_variante FIELDS item;

-- ----------------------------------------------------------------------------
-- VERROU MOTEUR : Protection absolue de l'empreinte de la variante
-- Empêche toute tentative de falsification ou modification arbitraire
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_variante_protect_fingerprint ON TABLE catalogue_variante
WHEN $event = "UPDATE"
THEN {
    LET $attrs = (SELECT attribut, attribut_valeur FROM catalogue_variante_attribut WHERE variante = $after.id);
    LET $pairs = array::sort(array::map($attrs, |$a| string::concat(<string> $a.attribut, ":", <string> $a.attribut_valeur)));
    LET $real_fp = crypto::sha256(array::join($pairs, "|"));
    IF $after.empreinte_attributs != $real_fp {
        THROW "CATALOGUE_VARIANTE_FINGERPRINT_FORBIDDEN: Modification directe de l'empreinte interdite. L'empreinte doit correspondre aux attributs reels.";
    };
};

