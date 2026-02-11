DEFINE TABLE IF NOT EXISTS crm_app_audit TYPE NORMAL SCHEMAFULL
  COMMENT 'Audit des modifications sur les champs trackés de crm_app_crm';

DEFINE FIELD field ON TABLE crm_app_audit TYPE string
  COMMENT 'Champ modifié';

DEFINE FIELD old_value ON TABLE crm_app_audit TYPE any
  COMMENT 'Ancienne valeur';

DEFINE FIELD new_value ON TABLE crm_app_audit TYPE any
  COMMENT 'Nouvelle valeur';

DEFINE FIELD record_id ON TABLE crm_app_audit TYPE record<crm_app>
  COMMENT 'Référence vers le record concerné';

DEFINE FIELD modified_by ON TABLE crm_app_audit TYPE record<base_user>
  COMMENT 'Qui a fait le changement ?';

DEFINE FIELD modified_at ON TABLE crm_app_audit TYPE datetime VALUE time::now()
  COMMENT 'Quand ?';

-- Index pour les requêtes rapides
DEFINE INDEX idx_audit_record ON crm_app_audit FIELDS record_id;
DEFINE INDEX idx_audit_field ON crm_app_audit FIELDS field;
DEFINE INDEX idx_audit_modified_at ON crm_app_audit FIELDS modified_at;
