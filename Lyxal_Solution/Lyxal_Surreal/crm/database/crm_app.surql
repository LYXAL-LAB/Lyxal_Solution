DEFINE TABLE IF NOT EXISTS crm_app TYPE NORMAL SCHEMAFULL
    COMMENT 'Configuration globale du module CRM (paramètres, statuts par défaut, etc.)'
    PERMISSIONS FULL;

  -- ==================================
  -- CHAMPS SIMPLES
  -- ==================================
  DEFINE FIELD assignable_users ON TABLE crm_app TYPE int
    COMMENT 'Nombre d\'utilisateurs assignables (sélection)';

  DEFINE FIELD display_customer_description_in_opportunity ON TABLE crm_app TYPE bool
    DEFAULT false;

  DEFINE FIELD is_manage_recurrent ON TABLE crm_app TYPE bool
    DEFAULT false;

  DEFINE FIELD default_recurring_duration ON TABLE crm_app TYPE int;

  DEFINE FIELD is_manage_catalogs ON TABLE crm_app TYPE bool
    DEFAULT false;

  DEFINE FIELD agencies_management ON TABLE crm_app TYPE bool
    DEFAULT false;

  DEFINE FIELD crm_process_on_partner ON TABLE crm_app TYPE bool
    DEFAULT false;

  DEFINE FIELD is_search_functionality_enabled ON TABLE crm_app TYPE bool
    DEFAULT false;

  DEFINE FIELD is_corporate_partner_enabled ON TABLE crm_app TYPE bool
    DEFAULT false;

  DEFINE FIELD email_domain_to_ignore ON TABLE crm_app TYPE string
    COMMENT 'Domaines email à ignorer (ex: exemple.com,autre.fr)';

  -- ==================================
  -- CHAMPS DE RELATION (many-to-one)
  -- ==================================
  DEFINE FIELD closed_win_opportunity_status ON TABLE crm_app TYPE option<record<crm_opportunity_status>>;
  DEFINE FIELD closed_lost_opportunity_status ON TABLE crm_app TYPE option<record<crm_opportunity_status>>;
  DEFINE FIELD sales_proposition_status ON TABLE crm_app TYPE option<record<crm_opportunity_status>>;
  DEFINE FIELD opportunity_default_status ON TABLE crm_app TYPE option<record<crm_opportunity_status>>;

  DEFINE FIELD converted_lead_status ON TABLE crm_app TYPE option<record<crm_lead_status>>;
  DEFINE FIELD lost_lead_status ON TABLE crm_app TYPE option<record<crm_lead_status>>;
  DEFINE FIELD lead_default_status ON TABLE crm_app TYPE option<record<crm_lead_status>>;

  DEFINE FIELD closed_win_partner_status ON TABLE crm_app TYPE option<record<crm_partner_status>>;
  DEFINE FIELD closed_lost_partner_status ON TABLE crm_app TYPE option<record<crm_partner_status>>;
  DEFINE FIELD partner_default_status ON TABLE crm_app TYPE option<record<crm_partner_status>>;

  -- ==================================
  -- CHAMP one-to-one : référence vers studio_app
  -- ==================================
  DEFINE FIELD app ON TABLE crm_app TYPE record<studio_app>
    COMMENT 'Référence one-to-one vers l\'application générale';

  -- ==================================
  -- INDEX
  -- ==================================
  DEFINE INDEX idx_crm_app_app ON crm_app FIELDS app UNIQUE;

  -- Index sur les statuts fréquemment utilisés
  DEFINE INDEX idx_crm_app_default_statuses ON crm_app 
    FIELDS lead_default_status, opportunity_default_status, partner_default_status;