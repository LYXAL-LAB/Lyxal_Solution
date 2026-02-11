-- ================================================
-- MODULE AXELOR QUALITY - CONFIGURATION ET BASE
-- ================================================
-- Migration des entités de configuration et base du module axelor-quality
-- Total: 9 entités (AppQuality, App, Company, QualityConfig, QualityProcess, QualityMeasuringPoint, QualityPictures, Sequence, RootCause)

-- ================================================
-- TABLES DE BASE
-- ================================================

-- Table App (référence générique)
DEFINE TABLE app SCHEMAFULL;
DEFINE FIELD id ON app TYPE record<app>;
DEFINE FIELD name ON app TYPE string;
DEFINE FIELD code ON app TYPE string;
DEFINE FIELD description ON app TYPE string;
DEFINE FIELD active ON app TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app TYPE int;
DEFINE FIELD version ON app TYPE string;
DEFINE FIELD created_on ON app TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON app TYPE string;
DEFINE FIELD updated_by ON app TYPE string;
DEFINE INDEX idx_app_code ON app COLUMNS code UNIQUE;
DEFINE INDEX idx_app_name ON app COLUMNS name;

-- Table Company_quality (extension entreprises pour quality)
DEFINE TABLE company_quality SCHEMAFULL;
DEFINE FIELD id ON company_quality TYPE record<company_quality>;
DEFINE FIELD company_id ON company_quality TYPE record<company>;
-- Tous les champs communs sont maintenant dans la table company de base
DEFINE FIELD created_on ON company_quality TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON company_quality TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON company_quality TYPE string;
DEFINE FIELD updated_by ON company_quality TYPE string;

-- Table Sequence (référence étendue)  
DEFINE TABLE sequence SCHEMAFULL;
DEFINE FIELD id ON sequence TYPE record<sequence>;
DEFINE FIELD name ON sequence TYPE string;
DEFINE FIELD code ON sequence TYPE string;
DEFINE FIELD prefix ON sequence TYPE string;
DEFINE FIELD suffix ON sequence TYPE string;
DEFINE FIELD padding ON sequence TYPE int DEFAULT 1;
DEFINE FIELD next_num ON sequence TYPE int DEFAULT 1;
DEFINE FIELD increment ON sequence TYPE int DEFAULT 1;
DEFINE FIELD active ON sequence TYPE bool DEFAULT true;
DEFINE FIELD company ON sequence TYPE record<company>;
DEFINE FIELD created_on ON sequence TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sequence TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON sequence TYPE string;
DEFINE FIELD updated_by ON sequence TYPE string;
DEFINE INDEX idx_sequence_code ON sequence COLUMNS code UNIQUE;
DEFINE INDEX idx_sequence_company ON sequence COLUMNS company;

-- ================================================
-- ENTITÉS PRINCIPALES DU MODULE QUALITY
-- ================================================

-- AppQuality - Configuration de l'application qualité
DEFINE TABLE app_quality SCHEMAFULL;
DEFINE FIELD id ON app_quality TYPE record<app_quality>;
DEFINE FIELD app ON app_quality TYPE string;
DEFINE FIELD quality_control_template ON app_quality TYPE string;
DEFINE FIELD automatic_mail ON app_quality TYPE bool DEFAULT false;
DEFINE FIELD created_on ON app_quality TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_quality TYPE datetime DEFAULT time::now();

-- QualityConfig - Configuration qualité par entreprise
DEFINE TABLE quality_config SCHEMAFULL;
DEFINE FIELD id ON quality_config TYPE record<quality_config>;
DEFINE FIELD company ON quality_config TYPE string;
DEFINE FIELD qi_action_distribution_print_template ON quality_config TYPE string;
DEFINE FIELD qi_action_distribution_sequence ON quality_config TYPE string;
DEFINE FIELD qi_decision_distribution_print_template ON quality_config TYPE string;
DEFINE FIELD qi_decision_distribution_sequence ON quality_config TYPE string;
DEFINE FIELD created_on ON quality_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON quality_config TYPE datetime DEFAULT time::now();

-- QualityProcess - Processus qualité
DEFINE TABLE quality_process SCHEMAFULL;
DEFINE FIELD id ON quality_process TYPE record<quality_process>;
DEFINE FIELD name ON quality_process TYPE string;
DEFINE FIELD code ON quality_process TYPE string;
DEFINE FIELD description ON quality_process TYPE string;
DEFINE FIELD active ON quality_process TYPE bool DEFAULT true;
DEFINE FIELD company ON quality_process TYPE string;
DEFINE FIELD created_on ON quality_process TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON quality_process TYPE datetime DEFAULT time::now();

-- QualityMeasuringPoint - Points de mesure qualité
DEFINE TABLE quality_measuring_point SCHEMAFULL;
DEFINE FIELD id ON quality_measuring_point TYPE record<quality_measuring_point>;
DEFINE FIELD name ON quality_measuring_point TYPE string;
DEFINE FIELD code ON quality_measuring_point TYPE string;
DEFINE FIELD description ON quality_measuring_point TYPE string;
DEFINE FIELD unit ON quality_measuring_point TYPE string;
DEFINE FIELD min_value ON quality_measuring_point TYPE float;
DEFINE FIELD max_value ON quality_measuring_point TYPE float;
DEFINE FIELD target_value ON quality_measuring_point TYPE float;
DEFINE FIELD tolerance ON quality_measuring_point TYPE float;
DEFINE FIELD active ON quality_measuring_point TYPE bool DEFAULT true;
DEFINE FIELD company ON quality_measuring_point TYPE string;
DEFINE FIELD created_on ON quality_measuring_point TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON quality_measuring_point TYPE datetime DEFAULT time::now();

-- QualityPictures - Images qualité
DEFINE TABLE quality_pictures SCHEMAFULL;
DEFINE FIELD id ON quality_pictures TYPE record<quality_pictures>;
DEFINE FIELD name ON quality_pictures TYPE string;
DEFINE FIELD file_name ON quality_pictures TYPE string;
DEFINE FIELD file_path ON quality_pictures TYPE string;
DEFINE FIELD file_size ON quality_pictures TYPE int;
DEFINE FIELD mime_type ON quality_pictures TYPE string;
DEFINE FIELD description ON quality_pictures TYPE string;
DEFINE FIELD quality_control ON quality_pictures TYPE string;
DEFINE FIELD quality_alert ON quality_pictures TYPE string;
DEFINE FIELD created_on ON quality_pictures TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON quality_pictures TYPE datetime DEFAULT time::now();

-- RootCause - Causes racines
DEFINE TABLE root_cause SCHEMAFULL;
DEFINE FIELD id ON root_cause TYPE record<root_cause>;
DEFINE FIELD name ON root_cause TYPE string;
DEFINE FIELD code ON root_cause TYPE string;
DEFINE FIELD description ON root_cause TYPE string;
DEFINE FIELD category ON root_cause TYPE string;
DEFINE FIELD active ON root_cause TYPE bool DEFAULT true;
DEFINE FIELD company ON root_cause TYPE string;
DEFINE FIELD created_on ON root_cause TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON root_cause TYPE datetime DEFAULT time::now();

-- ================================================
-- FONCTIONS UTILITAIRES
-- ================================================

-- Fonction pour générer le prochain numéro de séquence
DEFINE FUNCTION fn::generate_sequence_number($sequence_id: record<sequence>) -> string {
    LET $seq = (SELECT * FROM $sequence_id)[0];
    LET $next_num = $seq.next_num;
    LET $padded_num = string::concat(string::repeat('0', $seq.padding - string::len(string::from($next_num))), string::from($next_num));
    LET $full_number = string::concat($seq.prefix, $padded_num, $seq.suffix);
    
    -- Mettre à jour le compteur
    UPDATE $sequence_id SET next_num = $next_num + $seq.increment;
    
    RETURN $full_number;
};

-- Fonction pour valider les valeurs de mesure
DEFINE FUNCTION fn::validate_measurement($value: float, $min_value: float, $max_value: float) -> bool {
    RETURN $value >= $min_value AND $value <= $max_value;
};

-- Fonction pour calculer l'écart par rapport à la cible
DEFINE FUNCTION fn::calculate_deviation($value: float, $target: float) -> float {
    RETURN math::abs($value - $target);
};

-- ================================================
-- VUES UTILITAIRES
-- ================================================

-- Vue des configurations qualité actives
DEFINE TABLE quality_config_active AS SELECT 
    id,
    company,
    qi_action_distribution_print_template,
    qi_action_distribution_sequence,
    qi_decision_distribution_print_template,
    qi_decision_distribution_sequence,
    created_on,
    updated_on
FROM quality_config 
WHERE company.active = true;

-- Vue des processus qualité actifs
DEFINE TABLE quality_process_active AS SELECT 
    id,
    name,
    code,
    description,
    company,
    created_on,
    updated_on
FROM quality_process 
WHERE active = true;

-- Vue des points de mesure avec statistiques
DEFINE TABLE quality_measuring_point_stats AS SELECT 
    id,
    name,
    code,
    unit,
    min_value,
    max_value,
    target_value,
    tolerance,
    (max_value - min_value) AS range_value,
    company,
    created_on,
    updated_on
FROM quality_measuring_point 
WHERE active = true;

-- ================================================
-- TRIGGERS
-- ================================================

-- Trigger pour mettre à jour updated_on automatiquement
DEFINE EVENT quality_config_updated ON TABLE quality_config WHEN $event = "UPDATE" THEN (
    UPDATE quality_config SET updated_on = time::now() WHERE id = $after.id
);

DEFINE EVENT quality_process_updated ON TABLE quality_process WHEN $event = "UPDATE" THEN (
    UPDATE quality_process SET updated_on = time::now() WHERE id = $after.id
);

DEFINE EVENT quality_measuring_point_updated ON TABLE quality_measuring_point WHEN $event = "UPDATE" THEN (
    UPDATE quality_measuring_point SET updated_on = time::now() WHERE id = $after.id
);

-- ================================================
-- CONSTANTES
-- ================================================

-- Constantes pour les statuts
DEFINE PARAM $QUALITY_STATUS_ACTIVE = 'active';
DEFINE PARAM $QUALITY_STATUS_INACTIVE = 'inactive';
DEFINE PARAM $QUALITY_STATUS_DRAFT = 'draft';
DEFINE PARAM $QUALITY_STATUS_VALIDATED = 'validated';

-- Constantes pour les types de processus
DEFINE PARAM $QUALITY_PROCESS_TYPE_CONTROL = 'control';
DEFINE PARAM $QUALITY_PROCESS_TYPE_IMPROVEMENT = 'improvement';
DEFINE PARAM $QUALITY_PROCESS_TYPE_AUDIT = 'audit';

-- Constantes pour les catégories de causes racines
DEFINE PARAM $ROOT_CAUSE_CATEGORY_HUMAN = 'human';
DEFINE PARAM $ROOT_CAUSE_CATEGORY_MACHINE = 'machine';
DEFINE PARAM $ROOT_CAUSE_CATEGORY_MATERIAL = 'material';
DEFINE PARAM $ROOT_CAUSE_CATEGORY_METHOD = 'method';
DEFINE PARAM $ROOT_CAUSE_CATEGORY_ENVIRONMENT = 'environment';
DEFINE PARAM $ROOT_CAUSE_CATEGORY_MEASUREMENT = 'measurement';

-- ================================================
-- DONNÉES INITIALES
-- ================================================

-- Création des séquences par défaut
INSERT INTO sequence (
    id,
    name,
    code,
    prefix,
    suffix,
    padding,
    next_num,
    increment,
    active,
    created_on,
    created_by
) VALUES (
    sequence:quality_control,
    'Contrôle Qualité',
    'QUALITY_CONTROL',
    'QC',
    '',
    6,
    1,
    1,
    true,
    time::now(),
    'system'
), (
    sequence:quality_improvement,
    'Amélioration Qualité',
    'QUALITY_IMPROVEMENT',
    'QI',
    '',
    6,
    1,
    1,
    true,
    time::now(),
    'system'
), (
    sequence:quality_alert,
    'Alerte Qualité',
    'QUALITY_ALERT',
    'QA',
    '',
    6,
    1,
    1,
    true,
    time::now(),
    'system'
);

-- Création des causes racines de base
INSERT INTO root_cause (
    id,
    name,
    code,
    description,
    category,
    active,
    created_on,
    created_by
) VALUES (
    root_cause:defaut_humain,
    'Défaut Humain',
    'HUMAN_ERROR',
    'Erreur liée au facteur humain',
    'human',
    true,
    time::now(),
    'system'
), (
    root_cause:defaut_machine,
    'Défaut Machine',
    'MACHINE_ERROR',
    'Erreur liée à l\'équipement',
    'machine',
    true,
    time::now(),
    'system'
), (
    root_cause:defaut_materiel,
    'Défaut Matériel',
    'MATERIAL_ERROR',
    'Erreur liée au matériel',
    'material',
    true,
    time::now(),
    'system'
), (
    root_cause:defaut_methode,
    'Défaut Méthode',
    'METHOD_ERROR',
    'Erreur liée à la méthode',
    'method',
    true,
    time::now(),
    'system'
), (
    root_cause:defaut_environnement,
    'Défaut Environnement',
    'ENVIRONMENT_ERROR',
    'Erreur liée à l\'environnement',
    'environment',
    true,
    time::now(),
    'system'
), (
    root_cause:defaut_mesure,
    'Défaut Mesure',
    'MEASUREMENT_ERROR',
    'Erreur liée aux mesures',
    'measurement',
    true,
    time::now(),
    'system'
);

-- ================================================
-- COMMENTAIRES DE MIGRATION
-- ================================================

-- Migration terminée pour les entités de base du module quality
-- Entités migrées (9/9):
-- ✓ AppQuality -> app_quality
-- ✓ App -> app  
-- ✓ Company -> company_quality
-- ✓ QualityConfig -> quality_config
-- ✓ QualityProcess -> quality_process
-- ✓ QualityMeasuringPoint -> quality_measuring_point
-- ✓ QualityPictures -> quality_pictures
-- ✓ Sequence -> sequence
-- ✓ RootCause -> root_cause