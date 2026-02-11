

-- Namespacing recommandé : <app_namespace>.<db> (géré par ton orchestrateur)

-- -----------------------------

-- Tenancy basics (références)

-- -----------------------------

DEFINE TABLE IF NOT EXISTS tenant TYPE NORMAL SCHEMAFULL
    COMMENT 'Locataire logique (SaaS client).'
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS code ON TABLE tenant 
    TYPE string 
    ASSERT string::len($value) > 0
    COMMENT 'Code du tenant';

DEFINE FIELD IF NOT EXISTS name ON TABLE tenant 
    TYPE string
    COMMENT 'Nom du tenant';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE tenant 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création du tenant';