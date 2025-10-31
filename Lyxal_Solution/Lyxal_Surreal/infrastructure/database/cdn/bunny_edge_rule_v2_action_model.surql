-- Table: bunny_edge_rule_v2_action_model
-- Source: EdgeRuleV2ActionModel
-- Description: Table pour EdgeRuleV2ActionModel

DEFINE TABLE IF NOT EXISTS bunny_edge_rule_v2_action_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour EdgeRuleV2ActionModel';

DEFINE FIELD IF NOT EXISTS action_type ON bunny_edge_rule_v2_action_model
  TYPE option<record<edge_rule_action_type>>
;

DEFINE FIELD IF NOT EXISTS action_parameter1 ON bunny_edge_rule_v2_action_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS action_parameter2 ON bunny_edge_rule_v2_action_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS action_parameter3 ON bunny_edge_rule_v2_action_model
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_edge_rule_v2_action_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_edge_rule_v2_action_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
