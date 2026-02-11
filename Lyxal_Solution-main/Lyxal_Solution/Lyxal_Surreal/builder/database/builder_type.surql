DEFINE TABLE IF NOT EXISTS builder_type TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : types de ressources du Builder'
PERMISSIONS
FOR SELECT,CREATE FULL
FOR UPDATE,DELETE NONE;

DEFINE FIELD IF NOT EXISTS code ON builder_type
    TYPE object
    COMMENT 'Identifiants du type de ressource';

DEFINE FIELD IF NOT EXISTS code.prefix ON builder_type
    TYPE string
    READONLY
    COMMENT 'Préfixe pour construire les IDs des ressources (ex: \'function_\', \'table_\')';

DEFINE FIELD IF NOT EXISTS code.search ON builder_type
    TYPE string
    READONLY
    COMMENT 'Code de recherche pour l\'IA et les requêtes (ex: \'function\', \'table\')';

-- Clés i18n du type de ressource

DEFINE FIELD IF NOT EXISTS i18n_key ON builder_type
    TYPE object
    COMMENT 'Clés i18n du type de ressource';

DEFINE FIELD IF NOT EXISTS i18n_key.name ON builder_type
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Clé i18n du nom du type de ressource';

DEFINE FIELD IF NOT EXISTS i18n_key.description ON builder_type
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Clé i18n de la description du type de ressource';

-- Métadonnées du type de ressource
DEFINE FIELD IF NOT EXISTS metadata ON builder_type
    FLEXIBLE
    TYPE object
    COMMENT 'Métadonnées du type de ressource';

DEFINE FIELD IF NOT EXISTS metadata.interface ON builder_type
    FLEXIBLE
    TYPE object
    COMMENT 'Interface du type de ressource. Exemple :
        metadata.interface: {
                icon: "⚡",
                color: "#8B5CF6"
                color_daisy: "info"
        }';

-- Métadonnées structurelles du type de ressource
DEFINE FIELD IF NOT EXISTS metadata.structure ON builder_type
    FLEXIBLE
    TYPE object
    COMMENT 'Structure du type de ressource. Exemple type=\'function\':
            metadata.structure: {
            parameters: [ {name, type, required, description}, ... ],
            return_type: string,
            related_functions: [record_ids],
            related_tables: [record_ids],
            examples: [ {code, description}, ... ]
            }';

DEFINE FIELD IF NOT EXISTS state ON builder_type
    TYPE object
    COMMENT 'État et cycle de vie du type de ressource';

DEFINE FIELD IF NOT EXISTS state.isactive ON builder_type
    TYPE bool
    DEFAULT true
    COMMENT 'Type actif/inactif (toggle simple)';

DEFINE FIELD IF NOT EXISTS state.status ON builder_type
    TYPE record<builder_status>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Statut du cycle de vie (draft, active, deprecated, disabled, archived)';

DEFINE FIELD IF NOT EXISTS timestamp ON builder_type
    TYPE object
    COMMENT 'Timestamps du type de ressource';

DEFINE FIELD IF NOT EXISTS timestamp.created_at ON builder_type
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création du type de ressource';

DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON builder_type
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de mise à jour du type de ressource';

DEFINE INDEX IF NOT EXISTS idx_builder_type_code_search ON builder_type 
    FIELDS code.search UNIQUE
    COMMENT 'Unicité du code de recherche';

DEFINE INDEX IF NOT EXISTS idx_builder_type_code_prefix ON builder_type 
    FIELDS code.prefix UNIQUE
    COMMENT 'Unicité du préfixe ID';