-- ============================================================================
-- TABLE  : catalogue_attribut_valeur
-- MODULE : lyxal_catalogue
-- RÔLE   : Valeurs autorisées et prédéfinies des attributs
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_attribut_valeur
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE
    COMMENT "Dictionnaire des valeurs autorisées et typées pour chaque attribut";

DEFINE FIELD OVERWRITE attribut ON TABLE catalogue_attribut_valeur
    TYPE record<catalogue_attribut>
    REFERENCE
    COMMENT "Attribut parent propriétaire";

DEFINE FIELD OVERWRITE code ON TABLE catalogue_attribut_valeur
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Code de la valeur (ex: BLANC, ROUGE, 50W)";

DEFINE FIELD OVERWRITE valeur_texte ON TABLE catalogue_attribut_valeur
    TYPE option<string>
    COMMENT "Valeur typée texte ou code couleur hex";

DEFINE FIELD OVERWRITE valeur_nombre ON TABLE catalogue_attribut_valeur
    TYPE option<decimal>
    COMMENT "Valeur typée numérique";

DEFINE FIELD OVERWRITE valeur_booleen ON TABLE catalogue_attribut_valeur
    TYPE option<bool>
    COMMENT "Valeur typée booléenne";

DEFINE FIELD OVERWRITE valeur_date ON TABLE catalogue_attribut_valeur
    TYPE option<datetime>
    COMMENT "Valeur typée horodatée";

DEFINE FIELD OVERWRITE libelle_affichage ON TABLE catalogue_attribut_valeur
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Libellé lisible pour l'utilisateur";

DEFINE FIELD OVERWRITE ordre ON TABLE catalogue_attribut_valeur
    TYPE int
    DEFAULT 0
    COMMENT "Ordre de tri lors de la sélection";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_attribut_valeur
    TYPE bool
    DEFAULT true
    COMMENT "Statut d'activation de la valeur";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_attribut_valeur
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_attribut_valeur
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de mise à jour";

DEFINE INDEX OVERWRITE idx_attr_val_unique ON TABLE catalogue_attribut_valeur FIELDS attribut, code UNIQUE;
DEFINE INDEX OVERWRITE idx_attr_val_lookup ON TABLE catalogue_attribut_valeur FIELDS attribut, enabled;
