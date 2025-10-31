-- ================================================================================
-- Table des préférences de communication
-- ================================================================================
-- DESCRIPTION: Gère les préférences de communication utilisées dans le CRM
-- USAGE: Référence pour partners, leads, contacts
-- ================================================================================

DEFINE TABLE communication_preference SCHEMAFULL;

-- Nom de la préférence
DEFINE FIELD name ON communication_preference TYPE string 
    ASSERT string::len($value) > 0 AND string::len($value) <= 50;

-- Nom en français
DEFINE FIELD name_fr ON communication_preference TYPE string;

-- Nom en anglais
DEFINE FIELD name_en ON communication_preference TYPE string;

-- Nom en allemand
DEFINE FIELD name_de ON communication_preference TYPE string;

-- Nom en espagnol
DEFINE FIELD name_es ON communication_preference TYPE string;

-- Description détaillée
DEFINE FIELD description ON communication_preference TYPE string;

-- Référence vers le type de média associé
DEFINE FIELD media_type ON communication_preference TYPE record<media_type>;

-- Icône associée
DEFINE FIELD icon ON communication_preference TYPE string;

-- Couleur d'affichage (hex color)
DEFINE FIELD color ON communication_preference TYPE string 
    ASSERT string::len($value) = 7 AND string::starts_with($value, '#');

-- Indique si c'est un canal digital
DEFINE FIELD is_digital ON communication_preference TYPE bool DEFAULT true;

-- Indique si c'est un canal instantané
DEFINE FIELD is_instant ON communication_preference TYPE bool DEFAULT false;

-- Indique si le canal permet les pièces jointes
DEFINE FIELD supports_attachments ON communication_preference TYPE bool DEFAULT false;

-- Indique si le canal est trackable
DEFINE FIELD is_trackable ON communication_preference TYPE bool DEFAULT false;

-- Coût moyen par message
DEFINE FIELD average_cost_per_message ON communication_preference TYPE decimal DEFAULT 0.0;

-- Taux de lecture moyen (en pourcentage)
DEFINE FIELD average_read_rate ON communication_preference TYPE decimal DEFAULT 0.0;

-- Taux de réponse moyen (en pourcentage)
DEFINE FIELD average_response_rate ON communication_preference TYPE decimal DEFAULT 0.0;

-- Délai de réponse moyen (en heures)
DEFINE FIELD average_response_time ON communication_preference TYPE int DEFAULT 24;

-- Ordre d'affichage
DEFINE FIELD display_order ON communication_preference TYPE int DEFAULT 0;

-- Statut actif/inactif
DEFINE FIELD is_active ON communication_preference TYPE bool DEFAULT true;

-- Métadonnées de suivi
DEFINE FIELD created_at ON communication_preference TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON communication_preference TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON communication_preference TYPE option<string>;
DEFINE FIELD updated_by ON communication_preference TYPE option<string>;

-- Index pour performance
DEFINE INDEX idx_communication_preference_name ON communication_preference COLUMNS name UNIQUE;
DEFINE INDEX idx_communication_preference_active ON communication_preference COLUMNS is_active;
DEFINE INDEX idx_communication_preference_digital ON communication_preference COLUMNS is_digital;
DEFINE INDEX idx_communication_preference_instant ON communication_preference COLUMNS is_instant;
DEFINE INDEX idx_communication_preference_media_type ON communication_preference COLUMNS media_type;

-- ================================================================================
-- DONNÉES INITIALES - PRÉFÉRENCES DE COMMUNICATION STANDARDS
-- ================================================================================

-- Email
INSERT INTO communication_preference {
    name: 'Email',
    name_fr: 'Email',
    name_en: 'Email',
    name_de: 'E-Mail',
    name_es: 'Correo electrónico',
    description: 'Communication par courrier électronique',
    media_type: (SELECT id FROM media_type WHERE name = 'Email' LIMIT 1),
    icon: 'envelope',
    color: '#007bff',
    is_digital: true,
    is_instant: false,
    supports_attachments: true,
    is_trackable: true,
    average_cost_per_message: 0.01,
    average_read_rate: 85.0,
    average_response_rate: 15.0,
    average_response_time: 4,
    display_order: 1,
    is_active: true,
    created_by: 'system'
};

-- Téléphone
INSERT INTO communication_preference {
    name: 'Téléphone',
    name_fr: 'Téléphone',
    name_en: 'Phone',
    name_de: 'Telefon',
    name_es: 'Teléfono',
    description: 'Communication téléphonique directe',
    media_type: (SELECT id FROM media_type WHERE name = 'Téléphone' LIMIT 1),
    icon: 'phone',
    color: '#28a745',
    is_digital: false,
    is_instant: true,
    supports_attachments: false,
    is_trackable: true,
    average_cost_per_message: 0.50,
    average_read_rate: 100.0,
    average_response_rate: 75.0,
    average_response_time: 0,
    display_order: 2,
    is_active: true,
    created_by: 'system'
};

-- SMS
INSERT INTO communication_preference {
    name: 'SMS',
    name_fr: 'SMS',
    name_en: 'SMS',
    name_de: 'SMS',
    name_es: 'SMS',
    description: 'Messages texte courts',
    icon: 'sms',
    color: '#17a2b8',
    is_digital: true,
    is_instant: true,
    supports_attachments: false,
    is_trackable: true,
    average_cost_per_message: 0.08,
    average_read_rate: 95.0,
    average_response_rate: 35.0,
    average_response_time: 1,
    display_order: 3,
    is_active: true,
    created_by: 'system'
};

-- Courrier postal
INSERT INTO communication_preference {
    name: 'Courrier postal',
    name_fr: 'Courrier postal',
    name_en: 'Mail',
    name_de: 'Post',
    name_es: 'Correo postal',
    description: 'Courrier traditionnel par voie postale',
    media_type: (SELECT id FROM media_type WHERE name = 'Courrier postal' LIMIT 1),
    icon: 'mail-bulk',
    color: '#6c757d',
    is_digital: false,
    is_instant: false,
    supports_attachments: true,
    is_trackable: false,
    average_cost_per_message: 2.50,
    average_read_rate: 70.0,
    average_response_rate: 5.0,
    average_response_time: 168,
    display_order: 4,
    is_active: true,
    created_by: 'system'
};

-- WhatsApp
INSERT INTO communication_preference {
    name: 'WhatsApp',
    name_fr: 'WhatsApp',
    name_en: 'WhatsApp',
    name_de: 'WhatsApp',
    name_es: 'WhatsApp',
    description: 'Messagerie instantanée WhatsApp',
    icon: 'whatsapp',
    color: '#25d366',
    is_digital: true,
    is_instant: true,
    supports_attachments: true,
    is_trackable: true,
    average_cost_per_message: 0.05,
    average_read_rate: 90.0,
    average_response_rate: 45.0,
    average_response_time: 0.5,
    display_order: 5,
    is_active: true,
    created_by: 'system'
};

-- LinkedIn
INSERT INTO communication_preference {
    name: 'LinkedIn',
    name_fr: 'LinkedIn',
    name_en: 'LinkedIn',
    name_de: 'LinkedIn',
    name_es: 'LinkedIn',
    description: 'Messages via LinkedIn',
    media_type: (SELECT id FROM media_type WHERE name = 'Réseaux sociaux' LIMIT 1),
    icon: 'linkedin',
    color: '#0077b5',
    is_digital: true,
    is_instant: false,
    supports_attachments: true,
    is_trackable: true,
    average_cost_per_message: 0.00,
    average_read_rate: 80.0,
    average_response_rate: 25.0,
    average_response_time: 8,
    display_order: 6,
    is_active: true,
    created_by: 'system'
};

-- Visioconférence
INSERT INTO communication_preference {
    name: 'Visioconférence',
    name_fr: 'Visioconférence',
    name_en: 'Video call',
    name_de: 'Videokonferenz',
    name_es: 'Videoconferencia',
    description: 'Réunion par visioconférence',
    icon: 'video',
    color: '#6f42c1',
    is_digital: true,
    is_instant: true,
    supports_attachments: true,
    is_trackable: true,
    average_cost_per_message: 0.00,
    average_read_rate: 100.0,
    average_response_rate: 90.0,
    average_response_time: 0,
    display_order: 7,
    is_active: true,
    created_by: 'system'
};

-- ================================================================================
-- FONCTIONS UTILITAIRES
-- ================================================================================

-- Fonction pour récupérer les préférences actives
DEFINE FUNCTION fn::get_active_communication_preferences() {
    RETURN (
        SELECT * FROM communication_preference 
        WHERE is_active = true 
        ORDER BY display_order, name
    );
};

-- Fonction pour récupérer les préférences digitales
DEFINE FUNCTION fn::get_digital_communication_preferences() {
    RETURN (
        SELECT * FROM communication_preference 
        WHERE is_active = true 
        AND is_digital = true
        ORDER BY average_response_rate DESC
    );
};

-- Fonction pour récupérer les préférences instantanées
DEFINE FUNCTION fn::get_instant_communication_preferences() {
    RETURN (
        SELECT * FROM communication_preference 
        WHERE is_active = true 
        AND is_instant = true
        ORDER BY average_response_time ASC
    );
};

-- Fonction pour récupérer les préférences trackables
DEFINE FUNCTION fn::get_trackable_communication_preferences() {
    RETURN (
        SELECT * FROM communication_preference 
        WHERE is_active = true 
        AND is_trackable = true
        ORDER BY average_read_rate DESC
    );
};

-- Fonction pour récupérer une préférence par nom
DEFINE FUNCTION fn::get_communication_preference_by_name($name: string) {
    RETURN (
        SELECT * FROM communication_preference 
        WHERE name = $name 
        AND is_active = true
        LIMIT 1
    );
};

-- Fonction pour récupérer le nom localisé d'une préférence
DEFINE FUNCTION fn::get_communication_preference_localized_name($pref_id: string, $language: string) {
    LET $pref = (SELECT * FROM communication_preference WHERE id = $pref_id AND is_active = true LIMIT 1);
    IF $pref IS NONE {
        RETURN NONE;
    };
    
    RETURN SWITCH $language {
        'fr' => $pref.name_fr,
        'en' => $pref.name_en,
        'de' => $pref.name_de,
        'es' => $pref.name_es,
        DEFAULT => $pref.name
    };
};

-- Fonction pour récupérer la préférence par défaut (Email)
DEFINE FUNCTION fn::get_default_communication_preference() {
    RETURN (
        SELECT * FROM communication_preference 
        WHERE name = 'Email' 
        AND is_active = true
        LIMIT 1
    );
};

-- Fonction pour calculer l'efficacité d'une préférence
DEFINE FUNCTION fn::calculate_communication_efficiency($pref_id: string) {
    LET $pref = (SELECT * FROM communication_preference WHERE id = $pref_id AND is_active = true LIMIT 1);
    IF $pref IS NONE {
        RETURN NONE;
    };
    
    LET $efficiency_score = ($pref.average_read_rate * 0.3) + ($pref.average_response_rate * 0.5) + ((100 - $pref.average_response_time) * 0.2);
    
    RETURN {
        preference_name: $pref.name,
        read_rate: $pref.average_read_rate,
        response_rate: $pref.average_response_rate,
        response_time: $pref.average_response_time,
        cost_per_message: $pref.average_cost_per_message,
        efficiency_score: $efficiency_score
    };
}; 