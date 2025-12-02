-- ============================================================
-- TABLE: custom_data (DONNÉES PERSONNALISÉES)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE custom_data TYPE NORMAL SCHEMAFULL
COMMENT "Données personnalisées libres (utilisées par les applications)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS data ON TABLE custom_data 
    TYPE object
    DEFAULT {}
    COMMENT "Objet JSON libre pour stocker des données custom";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE custom_data 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;
