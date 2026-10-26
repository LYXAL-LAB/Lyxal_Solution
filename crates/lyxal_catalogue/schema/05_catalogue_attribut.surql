-- ============================================================================
-- TABLE  : catalogue_attribut
-- MODULE : lyxal_catalogue
-- RÔLE   : Dictionnaire des caractéristiques techniques typées
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_attribut
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE
    COMMENT "Dictionnaire des caractéristiques techniques typées";

DEFINE FIELD OVERWRITE code ON TABLE catalogue_attribut
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Code unique de la caractéristique (ex: COULEUR, PUISSANCE)";

DEFINE FIELD OVERWRITE libelle ON TABLE catalogue_attribut
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Libellé de la caractéristique";

DEFINE FIELD OVERWRITE type_donnee ON TABLE catalogue_attribut
    TYPE string
    ASSERT $value IN ["STRING", "NUMBER", "BOOLEAN", "DATE", "COLOR"]
    COMMENT "Typage strict de la donnée";

DEFINE FIELD OVERWRITE unite ON TABLE catalogue_attribut
    TYPE option<record<base_unite>>
    REFERENCE
    COMMENT "Unité associée pour les grandeurs physiques";

DEFINE FIELD OVERWRITE is_variant_driver ON TABLE catalogue_attribut
    TYPE bool
    DEFAULT false
    COMMENT "Vrai si cet attribut peut servir à décliner des variantes";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_attribut
    TYPE bool
    DEFAULT true
    COMMENT "Statut d'activation";

DEFINE FIELD OVERWRITE is_system ON TABLE catalogue_attribut
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Indique si la définition fait partie du socle immuable";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_attribut
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_attribut
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de mise à jour";

DEFINE INDEX OVERWRITE idx_catalogue_attribut_code ON TABLE catalogue_attribut FIELDS code UNIQUE;
