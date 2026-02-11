-- ================================================================================
-- Table des statuts de traitement par lot (Batch Status)
-- ================================================================================
-- DESCRIPTION: Statuts de batch universels pour tous les modules
-- USAGE: Référence pour crm_batch, accounting_batch, project_batch, etc.
-- ================================================================================

DEFINE TABLE batch_status SCHEMAFULL
    COMMENT "Statuts de traitement par lot universels";

-- Code unique du statut
DEFINE FIELD code ON batch_status TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Code unique (ex: DRAFT, RUNNING, COMPLETED)";

-- Nom du statut
DEFINE FIELD name ON batch_status TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom du statut (ex: Brouillon, En cours, Terminé)";

-- Description détaillée
DEFINE FIELD description ON batch_status TYPE option<string>
    COMMENT "Description du statut";

-- Valeur numérique pour compatibilité
DEFINE FIELD numeric_value ON batch_status TYPE int UNIQUE
    COMMENT "Valeur numérique pour les champs select";

-- Icône pour l'interface
DEFINE FIELD icon ON batch_status TYPE string DEFAULT 'fa-circle'
    COMMENT "Icône FontAwesome pour l'interface";

-- Couleur pour l'interface
DEFINE FIELD color ON batch_status TYPE string DEFAULT '#6c757d'
    COMMENT "Couleur hexadécimale pour l'interface";

-- Couleur de fond pour l'interface
DEFINE FIELD background_color ON batch_status TYPE string DEFAULT '#f8f9fa'
    COMMENT "Couleur de fond pour l'interface";

-- Type de statut
DEFINE FIELD status_type ON batch_status TYPE string
    ASSERT $value INSIDE ['INITIAL', 'PROCESSING', 'FINAL', 'ERROR']
    COMMENT "Type de statut (INITIAL, PROCESSING, FINAL, ERROR)";

-- Indique si le batch peut être modifié dans ce statut
DEFINE FIELD is_editable ON batch_status TYPE bool DEFAULT true
    COMMENT "Batch modifiable dans ce statut";

-- Indique si le batch peut être exécuté dans ce statut
DEFINE FIELD is_executable ON batch_status TYPE bool DEFAULT false
    COMMENT "Batch exécutable dans ce statut";

-- Indique si le batch est terminé dans ce statut
DEFINE FIELD is_final ON batch_status TYPE bool DEFAULT false
    COMMENT "Statut final du batch";

-- Indique si c'est un statut d'erreur
DEFINE FIELD is_error ON batch_status TYPE bool DEFAULT false
    COMMENT "Statut d'erreur";

-- Statuts suivants possibles
DEFINE FIELD next_statuses ON batch_status TYPE array<record<batch_status>>
    COMMENT "Statuts suivants possibles";

-- Actions automatiques lors du passage à ce statut
DEFINE FIELD auto_actions ON batch_status TYPE object VALUE {
    send_notification: false,
    update_timestamps: true,
    log_change: true,
    trigger_events: []
} COMMENT "Actions automatiques";

-- Configuration spécifique au statut
DEFINE FIELD status_config ON batch_status TYPE object VALUE {
    allow_retry: false,
    auto_cleanup: false,
    retention_days: 30,
    archive_after_days: 90
} COMMENT "Configuration du statut";

-- Statut actif
DEFINE FIELD is_active ON batch_status TYPE bool DEFAULT true
    COMMENT "Statut actif";

-- Ordre d'affichage
DEFINE FIELD sequence ON batch_status TYPE int DEFAULT 0
    COMMENT "Ordre d'affichage";

-- Métadonnées
DEFINE FIELD created_at ON batch_status TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON batch_status TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON batch_status TYPE option<record<user>>;
DEFINE FIELD updated_by ON batch_status TYPE option<record<user>>;
DEFINE FIELD version ON batch_status TYPE int DEFAULT 0;

-- Index pour performance
DEFINE INDEX idx_batch_status_code ON batch_status COLUMNS code UNIQUE;
DEFINE INDEX idx_batch_status_numeric ON batch_status COLUMNS numeric_value UNIQUE;
DEFINE INDEX idx_batch_status_type ON batch_status COLUMNS status_type;
DEFINE INDEX idx_batch_status_active ON batch_status COLUMNS is_active;
DEFINE INDEX idx_batch_status_sequence ON batch_status COLUMNS sequence;

-- ================================================================================
-- DONNÉES INITIALES - STATUTS STANDARDS
-- ================================================================================

-- Statut 1: Brouillon (INITIAL)
INSERT INTO batch_status {
    code: 'DRAFT',
    name: 'Brouillon',
    description: 'Batch en cours de configuration, non encore lancé',
    numeric_value: 1,
    icon: 'fa-edit',
    color: '#6c757d',
    background_color: '#f8f9fa',
    status_type: 'INITIAL',
    is_editable: true,
    is_executable: true,
    is_final: false,
    is_error: false,
    auto_actions: {
        send_notification: false,
        update_timestamps: true,
        log_change: true,
        trigger_events: ['batch_created']
    },
    status_config: {
        allow_retry: false,
        auto_cleanup: false,
        retention_days: 30,
        archive_after_days: 90
    },
    is_active: true,
    sequence: 1,
    created_by: 'system'
};

-- Statut 2: En cours (PROCESSING)
INSERT INTO batch_status {
    code: 'RUNNING',
    name: 'En cours',
    description: 'Batch en cours d\'exécution',
    numeric_value: 2,
    icon: 'fa-spinner',
    color: '#007bff',
    background_color: '#e3f2fd',
    status_type: 'PROCESSING',
    is_editable: false,
    is_executable: false,
    is_final: false,
    is_error: false,
    auto_actions: {
        send_notification: true,
        update_timestamps: true,
        log_change: true,
        trigger_events: ['batch_started', 'batch_progress']
    },
    status_config: {
        allow_retry: false,
        auto_cleanup: false,
        retention_days: 30,
        archive_after_days: 90
    },
    is_active: true,
    sequence: 2,
    created_by: 'system'
};

-- Statut 3: Terminé (FINAL)
INSERT INTO batch_status {
    code: 'COMPLETED',
    name: 'Terminé',
    description: 'Batch terminé avec succès',
    numeric_value: 3,
    icon: 'fa-check-circle',
    color: '#28a745',
    background_color: '#e8f5e8',
    status_type: 'FINAL',
    is_editable: false,
    is_executable: false,
    is_final: true,
    is_error: false,
    auto_actions: {
        send_notification: true,
        update_timestamps: true,
        log_change: true,
        trigger_events: ['batch_completed', 'batch_success']
    },
    status_config: {
        allow_retry: false,
        auto_cleanup: true,
        retention_days: 90,
        archive_after_days: 365
    },
    is_active: true,
    sequence: 3,
    created_by: 'system'
};

-- Statut 4: Erreur (ERROR)
INSERT INTO batch_status {
    code: 'ERROR',
    name: 'Erreur',
    description: 'Batch terminé en erreur',
    numeric_value: 4,
    icon: 'fa-exclamation-triangle',
    color: '#dc3545',
    background_color: '#ffeaea',
    status_type: 'ERROR',
    is_editable: true,
    is_executable: true,
    is_final: true,
    is_error: true,
    auto_actions: {
        send_notification: true,
        update_timestamps: true,
        log_change: true,
        trigger_events: ['batch_error', 'batch_failed']
    },
    status_config: {
        allow_retry: true,
        auto_cleanup: false,
        retention_days: 180,
        archive_after_days: 730
    },
    is_active: true,
    sequence: 4,
    created_by: 'system'
};

-- Statut 5: Annulé (FINAL)
INSERT INTO batch_status {
    code: 'CANCELLED',
    name: 'Annulé',
    description: 'Batch annulé par l\'utilisateur',
    numeric_value: 5,
    icon: 'fa-ban',
    color: '#fd7e14',
    background_color: '#fff3e0',
    status_type: 'FINAL',
    is_editable: false,
    is_executable: false,
    is_final: true,
    is_error: false,
    auto_actions: {
        send_notification: true,
        update_timestamps: true,
        log_change: true,
        trigger_events: ['batch_cancelled']
    },
    status_config: {
        allow_retry: false,
        auto_cleanup: true,
        retention_days: 30,
        archive_after_days: 90
    },
    is_active: true,
    sequence: 5,
    created_by: 'system'
};

-- Statut 6: En pause (PROCESSING)
INSERT INTO batch_status {
    code: 'PAUSED',
    name: 'En pause',
    description: 'Batch mis en pause',
    numeric_value: 6,
    icon: 'fa-pause',
    color: '#ffc107',
    background_color: '#fff8e1',
    status_type: 'PROCESSING',
    is_editable: true,
    is_executable: true,
    is_final: false,
    is_error: false,
    auto_actions: {
        send_notification: false,
        update_timestamps: true,
        log_change: true,
        trigger_events: ['batch_paused']
    },
    status_config: {
        allow_retry: false,
        auto_cleanup: false,
        retention_days: 30,
        archive_after_days: 90
    },
    is_active: true,
    sequence: 6,
    created_by: 'system'
};

-- Statut 7: Planifié (INITIAL)
INSERT INTO batch_status {
    code: 'SCHEDULED',
    name: 'Planifié',
    description: 'Batch planifié pour exécution future',
    numeric_value: 7,
    icon: 'fa-clock',
    color: '#6f42c1',
    background_color: '#f3e5f5',
    status_type: 'INITIAL',
    is_editable: true,
    is_executable: false,
    is_final: false,
    is_error: false,
    auto_actions: {
        send_notification: false,
        update_timestamps: true,
        log_change: true,
        trigger_events: ['batch_scheduled']
    },
    status_config: {
        allow_retry: false,
        auto_cleanup: false,
        retention_days: 30,
        archive_after_days: 90
    },
    is_active: true,
    sequence: 7,
    created_by: 'system'
};

-- ================================================================================
-- CONFIGURATION DES TRANSITIONS DE STATUTS
-- ================================================================================

-- Configuration des statuts suivants possibles
UPDATE batch_status:draft SET next_statuses = [batch_status:running, batch_status:scheduled, batch_status:cancelled];
UPDATE batch_status:running SET next_statuses = [batch_status:completed, batch_status:error, batch_status:paused, batch_status:cancelled];
UPDATE batch_status:completed SET next_statuses = [];
UPDATE batch_status:error SET next_statuses = [batch_status:draft, batch_status:running, batch_status:cancelled];
UPDATE batch_status:cancelled SET next_statuses = [batch_status:draft];
UPDATE batch_status:paused SET next_statuses = [batch_status:running, batch_status:cancelled];
UPDATE batch_status:scheduled SET next_statuses = [batch_status:running, batch_status:cancelled, batch_status:draft];

-- ================================================================================
-- FONCTIONS UTILITAIRES
-- ================================================================================

-- Fonction pour récupérer les statuts actifs
DEFINE FUNCTION fn::get_active_batch_statuses() {
    RETURN (
        SELECT * FROM batch_status 
        WHERE is_active = true 
        ORDER BY sequence, name
    );
};

-- Fonction pour récupérer les statuts par type
DEFINE FUNCTION fn::get_batch_statuses_by_type($status_type: string) {
    RETURN (
        SELECT * FROM batch_status 
        WHERE is_active = true 
        AND status_type = $status_type
        ORDER BY sequence, name
    );
};

-- Fonction pour récupérer un statut par code
DEFINE FUNCTION fn::get_batch_status_by_code($code: string) {
    RETURN (
        SELECT * FROM batch_status 
        WHERE code = $code 
        AND is_active = true
        LIMIT 1
    );
};

-- Fonction pour récupérer un statut par valeur numérique
DEFINE FUNCTION fn::get_batch_status_by_numeric($numeric_value: int) {
    RETURN (
        SELECT * FROM batch_status 
        WHERE numeric_value = $numeric_value 
        AND is_active = true
        LIMIT 1
    );
};

-- Fonction pour vérifier si une transition de statut est valide
DEFINE FUNCTION fn::is_status_transition_valid($from_status_id: string, $to_status_id: string) {
    LET $from_status = (SELECT * FROM batch_status WHERE id = $from_status_id LIMIT 1);
    IF $from_status IS NONE {
        RETURN false;
    };
    
    RETURN array::contains($from_status.next_statuses, $to_status_id);
};

-- Fonction pour récupérer les statuts suivants possibles
DEFINE FUNCTION fn::get_next_batch_statuses($current_status_id: string) {
    LET $current_status = (SELECT * FROM batch_status WHERE id = $current_status_id LIMIT 1);
    IF $current_status IS NONE {
        RETURN [];
    };
    
    RETURN (
        SELECT * FROM batch_status 
        WHERE id IN $current_status.next_statuses 
        AND is_active = true
        ORDER BY sequence, name
    );
};

-- Fonction pour vérifier les permissions sur un statut
DEFINE FUNCTION fn::can_edit_batch_in_status($status_code: string) {
    LET $status = (SELECT * FROM batch_status WHERE code = $status_code AND is_active = true LIMIT 1);
    IF $status IS NONE {
        RETURN false;
    };
    RETURN $status.is_editable;
};

-- Fonction pour vérifier si un batch peut être exécuté
DEFINE FUNCTION fn::can_execute_batch_in_status($status_code: string) {
    LET $status = (SELECT * FROM batch_status WHERE code = $status_code AND is_active = true LIMIT 1);
    IF $status IS NONE {
        RETURN false;
    };
    RETURN $status.is_executable;
};

-- Fonction pour récupérer la configuration d'un statut
DEFINE FUNCTION fn::get_batch_status_config($status_code: string) {
    LET $status = (SELECT * FROM batch_status WHERE code = $status_code AND is_active = true LIMIT 1);
    IF $status IS NONE {
        RETURN {};
    };
    RETURN $status.status_config;
};

-- Fonction pour récupérer les actions automatiques d'un statut
DEFINE FUNCTION fn::get_batch_status_auto_actions($status_code: string) {
    LET $status = (SELECT * FROM batch_status WHERE code = $status_code AND is_active = true LIMIT 1);
    IF $status IS NONE {
        RETURN {};
    };
    RETURN $status.auto_actions;
}; 