/*
 * LYXAL SUITE - Module Marketing
 * Migration depuis axelor-marketing vers SurrealDB
 * 
 * Ce module contient les entités pour la gestion du marketing :
 * - Campaign (campagnes marketing)
 * - TargetList (listes de cibles)
 * - CampaignType (types de campagnes)
 * - CampaignReminder (rappels de campagnes)
 * - CampaignAttendee (participants aux campagnes)
 * - Extension Event (événements de campagnes)
 * 
 * Fonctionnalités :
 * - Gestion des campagnes email et événementielles
 * - Ciblage précis via listes et filtres
 * - Gestion des rappels automatiques
 * - Suivi des participants et réponses
 * - Intégration avec CRM (leads/partners)
 * 
 * Conformité : SurrealDB v2.0+
 * Date : 2024
 */

-- =============================================
-- TABLE: campaign_type
-- Types de campagnes marketing
-- =============================================
DEFINE TABLE campaign_type SCHEMAFULL;

DEFINE FIELD name ON campaign_type TYPE string;
DEFINE FIELD code ON campaign_type TYPE string;
DEFINE FIELD description ON campaign_type TYPE option<string>;
DEFINE FIELD is_active ON campaign_type TYPE bool DEFAULT true;
DEFINE FIELD sequence ON campaign_type TYPE int;

-- Métadonnées communes
DEFINE FIELD created_on ON campaign_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON campaign_type TYPE option<record<user>>;
DEFINE FIELD updated_on ON campaign_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON campaign_type TYPE option<record<user>>;
DEFINE FIELD archived ON campaign_type TYPE bool DEFAULT false;
DEFINE FIELD version ON campaign_type TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD name ON campaign_type ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_campaign_type_name ON campaign_type FIELDS name;
DEFINE INDEX idx_campaign_type_sequence ON campaign_type FIELDS sequence UNIQUE;

-- =============================================
-- TABLE: target_list
-- Listes de cibles pour campagnes
-- =============================================
DEFINE TABLE target_list SCHEMAFULL;

DEFINE FIELD name ON target_list TYPE string;
DEFINE FIELD sequence ON target_list TYPE int;
DEFINE FIELD partner_type_select ON target_list TYPE option<int>;
DEFINE FIELD partner_set ON target_list TYPE array<record<partner>> DEFAULT [];
DEFINE FIELD partner_query ON target_list TYPE option<string>;
DEFINE FIELD partner_query_type_select ON target_list TYPE int DEFAULT 0;
DEFINE FIELD lead_set ON target_list TYPE array<record<lead>> DEFAULT [];
DEFINE FIELD lead_query ON target_list TYPE option<string>;
DEFINE FIELD lead_query_type_select ON target_list TYPE int DEFAULT 0;
DEFINE FIELD description ON target_list TYPE option<string>;
DEFINE FIELD is_active ON target_list TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON target_list TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON target_list TYPE option<record<user>>;
DEFINE FIELD updated_on ON target_list TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON target_list TYPE option<record<user>>;
DEFINE FIELD archived ON target_list TYPE bool DEFAULT false;
DEFINE FIELD version ON target_list TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD name ON target_list ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD partner_query_type_select ON target_list ASSERT $value IN [0, 1]; -- GUIDED=0, MANUAL=1
DEFINE FIELD lead_query_type_select ON target_list ASSERT $value IN [0, 1];

-- Index d'optimisation
DEFINE INDEX idx_target_list_name ON target_list FIELDS name;
DEFINE INDEX idx_target_list_sequence ON target_list FIELDS sequence UNIQUE;
DEFINE INDEX idx_target_list_active ON target_list FIELDS is_active;

-- =============================================
-- TABLE: campaign
-- Campagnes marketing
-- =============================================
DEFINE TABLE campaign SCHEMAFULL;

DEFINE FIELD name ON campaign TYPE string;
DEFINE FIELD sequence ON campaign TYPE int;
DEFINE FIELD stage_select ON campaign TYPE option<int>;
DEFINE FIELD target_model_set ON campaign TYPE array<record<target_list>> DEFAULT [];
DEFINE FIELD partner_template ON campaign TYPE option<record<message_template>>;
DEFINE FIELD lead_template ON campaign TYPE option<record<message_template>>;
DEFINE FIELD email_log ON campaign TYPE option<string>; -- path to log file
DEFINE FIELD campaign_type ON campaign TYPE option<record<campaign_type>>;
DEFINE FIELD emailing ON campaign TYPE bool DEFAULT false;
DEFINE FIELD manage_an_event_per_target ON campaign TYPE bool DEFAULT false;
DEFINE FIELD manage_attendees ON campaign TYPE bool DEFAULT false;
DEFINE FIELD generate_event_per_partner_or_lead ON campaign TYPE bool DEFAULT false;
DEFINE FIELD leads ON campaign TYPE array<record<lead>> DEFAULT [];
DEFINE FIELD partners ON campaign TYPE array<record<partner>> DEFAULT [];
DEFINE FIELD event_user ON campaign TYPE option<record<user>>;
DEFINE FIELD team ON campaign TYPE option<record<team>>;
DEFINE FIELD email_account ON campaign TYPE option<record<email_account>>;
DEFINE FIELD subject ON campaign TYPE option<string>;
DEFINE FIELD event_type_select ON campaign TYPE option<int>;
DEFINE FIELD event_start_date_time ON campaign TYPE option<datetime>;
DEFINE FIELD duration ON campaign TYPE option<duration>;
DEFINE FIELD event_end_date_time ON campaign TYPE option<datetime>;
DEFINE FIELD partner_set ON campaign TYPE array<record<partner>> DEFAULT [];
DEFINE FIELD lead_set ON campaign TYPE array<record<lead>> DEFAULT [];
DEFINE FIELD report ON campaign TYPE option<string>;
DEFINE FIELD event_start_date_t ON campaign TYPE option<datetime>;
DEFINE FIELD event_end_date_t ON campaign TYPE option<datetime>;
DEFINE FIELD invited_partner_set ON campaign TYPE array<record<partner>> DEFAULT [];
DEFINE FIELD invited_lead_set ON campaign TYPE array<record<lead>> DEFAULT [];
DEFINE FIELD not_participating_partner_set ON campaign TYPE array<record<partner>> DEFAULT [];
DEFINE FIELD not_participating_lead_set ON campaign TYPE array<record<lead>> DEFAULT [];
DEFINE FIELD present_partner_set ON campaign TYPE array<record<partner>> DEFAULT [];
DEFINE FIELD present_lead_set ON campaign TYPE array<record<lead>> DEFAULT [];
DEFINE FIELD partner_reminder_template ON campaign TYPE option<record<message_template>>;
DEFINE FIELD lead_reminder_template ON campaign TYPE option<record<message_template>>;
DEFINE FIELD is_allow_editing_of_targets ON campaign TYPE bool DEFAULT true;
DEFINE FIELD description ON campaign TYPE option<string>;

-- Métadonnées communes
DEFINE FIELD created_on ON campaign TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON campaign TYPE option<record<user>>;
DEFINE FIELD updated_on ON campaign TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON campaign TYPE option<record<user>>;
DEFINE FIELD archived ON campaign TYPE bool DEFAULT false;
DEFINE FIELD version ON campaign TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD name ON campaign ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_campaign_name ON campaign FIELDS name;
DEFINE INDEX idx_campaign_sequence ON campaign FIELDS sequence UNIQUE;
DEFINE INDEX idx_campaign_stage ON campaign FIELDS stage_select;
DEFINE INDEX idx_campaign_type ON campaign FIELDS campaign_type;
DEFINE INDEX idx_campaign_event_user ON campaign FIELDS event_user;
DEFINE INDEX idx_campaign_team ON campaign FIELDS team;
DEFINE INDEX idx_campaign_start_date ON campaign FIELDS event_start_date_time;

-- =============================================
-- TABLE: campaign_reminder
-- Rappels de campagnes
-- =============================================
DEFINE TABLE campaign_reminder SCHEMAFULL;

DEFINE FIELD campaign ON campaign_reminder TYPE record<campaign>;
DEFINE FIELD type_select ON campaign_reminder TYPE int DEFAULT 1;
DEFINE FIELD duration ON campaign_reminder TYPE option<int>;
DEFINE FIELD duration_type_select ON campaign_reminder TYPE int DEFAULT 3;
DEFINE FIELD assign_to_select ON campaign_reminder TYPE option<int>;
DEFINE FIELD is_reminded ON campaign_reminder TYPE bool DEFAULT false;
DEFINE FIELD batch_set ON campaign_reminder TYPE array<record<batch>> DEFAULT [];
DEFINE FIELD reminder_date ON campaign_reminder TYPE option<datetime>;
DEFINE FIELD message ON campaign_reminder TYPE option<string>;

-- Métadonnées communes
DEFINE FIELD created_on ON campaign_reminder TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON campaign_reminder TYPE option<record<user>>;
DEFINE FIELD updated_on ON campaign_reminder TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON campaign_reminder TYPE option<record<user>>;
DEFINE FIELD archived ON campaign_reminder TYPE bool DEFAULT false;
DEFINE FIELD version ON campaign_reminder TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD campaign ON campaign_reminder ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_campaign_reminder_campaign ON campaign_reminder FIELDS campaign;
DEFINE INDEX idx_campaign_reminder_type ON campaign_reminder FIELDS type_select;
DEFINE INDEX idx_campaign_reminder_reminded ON campaign_reminder FIELDS is_reminded;
DEFINE INDEX idx_campaign_reminder_date ON campaign_reminder FIELDS reminder_date;

-- =============================================
-- TABLE: campaign_attendee
-- Participants aux campagnes
-- =============================================
DEFINE TABLE campaign_attendee SCHEMAFULL;

DEFINE FIELD sequence ON campaign_attendee TYPE int;
DEFINE FIELD related_to_select ON campaign_attendee TYPE option<string>;
DEFINE FIELD related_to_select_id ON campaign_attendee TYPE option<int>;
DEFINE FIELD campaign ON campaign_attendee TYPE record<campaign>;
DEFINE FIELD partner ON campaign_attendee TYPE option<record<partner>>;
DEFINE FIELD lead ON campaign_attendee TYPE option<record<lead>>;
DEFINE FIELD status_select ON campaign_attendee TYPE int DEFAULT 0; -- invited, confirmed, present, absent
DEFINE FIELD response_date ON campaign_attendee TYPE option<datetime>;
DEFINE FIELD comments ON campaign_attendee TYPE option<string>;

-- Métadonnées communes
DEFINE FIELD created_on ON campaign_attendee TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON campaign_attendee TYPE option<record<user>>;
DEFINE FIELD updated_on ON campaign_attendee TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON campaign_attendee TYPE option<record<user>>;
DEFINE FIELD archived ON campaign_attendee TYPE bool DEFAULT false;
DEFINE FIELD version ON campaign_attendee TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD campaign ON campaign_attendee ASSERT $value != NONE;
DEFINE FIELD status_select ON campaign_attendee ASSERT $value IN [0, 1, 2, 3]; -- invited, confirmed, present, absent

-- Index d'optimisation
DEFINE INDEX idx_campaign_attendee_sequence ON campaign_attendee FIELDS sequence UNIQUE;
DEFINE INDEX idx_campaign_attendee_campaign ON campaign_attendee FIELDS campaign;
DEFINE INDEX idx_campaign_attendee_partner ON campaign_attendee FIELDS partner;
DEFINE INDEX idx_campaign_attendee_lead ON campaign_attendee FIELDS lead;
DEFINE INDEX idx_campaign_attendee_status ON campaign_attendee FIELDS status_select;

-- =============================================
-- TABLE: marketing_event
-- Événements marketing (extension de l'entité Event CRM)
-- =============================================
DEFINE TABLE marketing_event SCHEMAFULL;

DEFINE FIELD event_id ON marketing_event TYPE record<event>; -- Référence vers l'entité Event du CRM
DEFINE FIELD campaign ON marketing_event TYPE option<record<campaign>>;
DEFINE FIELD is_campaign_event ON marketing_event TYPE bool DEFAULT false;
DEFINE FIELD generated_from_campaign ON marketing_event TYPE bool DEFAULT false;

-- Métadonnées communes
DEFINE FIELD created_on ON marketing_event TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON marketing_event TYPE option<record<user>>;
DEFINE FIELD updated_on ON marketing_event TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON marketing_event TYPE option<record<user>>;
DEFINE FIELD archived ON marketing_event TYPE bool DEFAULT false;
DEFINE FIELD version ON marketing_event TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD event_id ON marketing_event ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_marketing_event_event_id ON marketing_event FIELDS event_id UNIQUE;
DEFINE INDEX idx_marketing_event_campaign ON marketing_event FIELDS campaign;
DEFINE INDEX idx_marketing_event_is_campaign ON marketing_event FIELDS is_campaign_event;

-- =============================================
-- ÉVÉNEMENTS ET DÉCLENCHEURS
-- =============================================

-- Événement : Génération automatique de séquence pour campaign_type
DEFINE EVENT campaign_type_sequence ON TABLE campaign_type WHEN $event = "CREATE" THEN {
    LET $max_sequence = (SELECT VALUE sequence FROM campaign_type ORDER BY sequence DESC LIMIT 1);
    LET $next_sequence = IF array::len($max_sequence) > 0 { $max_sequence[0] + 1 } ELSE { 1 };
    UPDATE $after.id SET sequence = $next_sequence;
};

-- Événement : Génération automatique de séquence pour target_list
DEFINE EVENT target_list_sequence ON TABLE target_list WHEN $event = "CREATE" THEN {
    LET $max_sequence = (SELECT VALUE sequence FROM target_list ORDER BY sequence DESC LIMIT 1);
    LET $next_sequence = IF array::len($max_sequence) > 0 { $max_sequence[0] + 1 } ELSE { 1 };
    UPDATE $after.id SET sequence = $next_sequence;
};

-- Événement : Génération automatique de séquence pour campaign
DEFINE EVENT campaign_sequence ON TABLE campaign WHEN $event = "CREATE" THEN {
    LET $max_sequence = (SELECT VALUE sequence FROM campaign ORDER BY sequence DESC LIMIT 1);
    LET $next_sequence = IF array::len($max_sequence) > 0 { $max_sequence[0] + 1 } ELSE { 1 };
    UPDATE $after.id SET sequence = $next_sequence;
};

-- Événement : Génération automatique de séquence pour campaign_attendee
DEFINE EVENT campaign_attendee_sequence ON TABLE campaign_attendee WHEN $event = "CREATE" THEN {
    LET $max_sequence = (SELECT VALUE sequence FROM campaign_attendee ORDER BY sequence DESC LIMIT 1);
    LET $next_sequence = IF array::len($max_sequence) > 0 { $max_sequence[0] + 1 } ELSE { 1 };
    UPDATE $after.id SET sequence = $next_sequence;
};

-- Événement : Calcul automatique de la date de fin d'événement
DEFINE EVENT campaign_end_date_time ON TABLE campaign WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    IF $after.event_start_date_time != NONE AND $after.duration != NONE {
        LET $end_time = $after.event_start_date_time + $after.duration;
        UPDATE $after.id SET event_end_date_time = $end_time;
    }
};

-- Événement : Calcul de la date de rappel
DEFINE EVENT campaign_reminder_date ON TABLE campaign_reminder WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    IF $after.campaign != NONE AND $after.duration != NONE {
        LET $campaign_info = (SELECT event_start_date_time FROM $after.campaign LIMIT 1);
        IF array::len($campaign_info) > 0 AND $campaign_info[0].event_start_date_time != NONE {
            LET $duration_seconds = $after.duration * 
                IF $after.duration_type_select = 1 { 60 }           -- minutes
                ELSE IF $after.duration_type_select = 2 { 3600 }   -- hours  
                ELSE IF $after.duration_type_select = 3 { 86400 }  -- days
                ELSE { 1 };
            LET $reminder_date = $campaign_info[0].event_start_date_time - <duration>string::concat($duration_seconds, "s");
            UPDATE $after.id SET reminder_date = $reminder_date;
        }
    }
};

-- Événement : Mise à jour automatique du champ updated_on
DEFINE EVENT update_timestamp_campaign ON TABLE campaign WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

DEFINE EVENT update_timestamp_campaign_reminder ON TABLE campaign_reminder WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

-- =============================================
-- DONNÉES DE RÉFÉRENCE
-- =============================================

-- Étapes des campagnes
INSERT INTO lyxal_constants (
    id: constants:campaign_stage,
    category: 'campaign_stage',
    values: {
        DRAFT: 1,
        PLANNED: 2,
        IN_PROGRESS: 3,
        COMPLETED: 4,
        CANCELLED: 5
    }
);

-- Types de requêtes pour listes de cibles
INSERT INTO lyxal_constants (
    id: constants:target_query_type,
    category: 'target_query_type',
    values: {
        GUIDED: 0,
        MANUAL: 1
    }
);

-- Types de rappels de campagne
INSERT INTO lyxal_constants (
    id: constants:campaign_reminder_type,
    category: 'campaign_reminder_type',
    values: {
        EMAIL: 1,
        TASK: 2,
        NOTIFICATION: 3
    }
);

-- Types de durée pour rappels
INSERT INTO lyxal_constants (
    id: constants:campaign_reminder_duration_type,
    category: 'campaign_reminder_duration_type',
    values: {
        MINUTES: 1,
        HOURS: 2,
        DAYS: 3,
        WEEKS: 4
    }
);

-- Statuts des participants
INSERT INTO lyxal_constants (
    id: constants:campaign_attendee_status,
    category: 'campaign_attendee_status',
    values: {
        INVITED: 0,
        CONFIRMED: 1,
        PRESENT: 2,
        ABSENT: 3
    }
);

-- Types de campagne par défaut
INSERT INTO campaign_type (
    id: campaign_type:email,
    name: 'Campagne Email',
    code: 'EMAIL',
    description: 'Campagne de marketing par email'
);

INSERT INTO campaign_type (
    id: campaign_type:event,
    name: 'Événement',
    code: 'EVENT',
    description: 'Campagne événementielle'
);

INSERT INTO campaign_type (
    id: campaign_type:webinar,
    name: 'Webinaire',
    code: 'WEBINAR',
    description: 'Webinaire en ligne'
);

INSERT INTO campaign_type (
    id: campaign_type:newsletter,
    name: 'Newsletter',
    code: 'NEWSLETTER',
    description: 'Newsletter périodique'
);

/*
 * RÉSUMÉ DU MODULE MARKETING
 * 
 * Tables créées : 6
 * - campaign_type : Types de campagnes
 * - target_list : Listes de cibles
 * - campaign : Campagnes marketing
 * - campaign_reminder : Rappels de campagnes
 * - campaign_attendee : Participants aux campagnes
 * - marketing_event : Événements marketing
 * 
 * Fonctionnalités :
 * - Gestion complète des campagnes marketing
 * - Ciblage précis via listes et filtres
 * - Campagnes email et événementielles
 * - Système de rappels automatiques
 * - Suivi des participants et réponses
 * - Intégration avec CRM (leads/partners)
 * - Génération automatique d'événements
 * - Calculs automatiques de dates
 * 
 * Relations principales :
 * - campaign -> campaign_type
 * - campaign -> target_list (many-to-many)
 * - campaign_reminder -> campaign
 * - campaign_attendee -> campaign
 * - marketing_event -> campaign
 * - Intégration avec partner, lead, user, team
 * 
 * MIGRATION AXELOR-MARKETING TERMINÉE
 */

-- Module Marketing complet 