DEFINE TABLE IF NOT EXISTS crm_app_groups_assignable TYPE RELATION
    COMMENT 'Relation many-to-many : crm_app <-> base_user_group (groupes assignables)'
    PERMISSIONS FULL;

  -- ==================================
  -- DÉFINITION DES CHAMPS (in / out)
  -- ==================================
  DEFINE FIELD in ON TABLE crm_app_groups_assignable TYPE record<crm_app>
    COMMENT 'Référence vers la configuration CRM';

  DEFINE FIELD out ON TABLE crm_app_groups_assignable TYPE record<base_user_group>
    COMMENT 'Référence vers le groupe d\'utilisateurs';

  -- ==================================
  -- INDEX
  -- ==================================
  DEFINE INDEX idx_crm_app_groups_assignable_app ON crm_app_groups_assignable FIELDS in;
  DEFINE INDEX idx_crm_app_groups_assignable_group ON crm_app_groups_assignable FIELDS out;
  DEFINE INDEX idx_crm_app_groups_assignable_unique 
    ON crm_app_groups_assignable FIELDS in, out 
    UNIQUE 
    COMMENT 'Empêche la duplication de liaison entre une configuration de CRM et un groupe';