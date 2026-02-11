-- Table: bunny_edge_rule_v2_model
-- Source: EdgeRuleV2Model
-- Description: Model definition for EdgeRuleV2Model

DEFINE TABLE IF NOT EXISTS bunny_edge_rule_v2_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Model definition for EdgeRuleV2Model';

DEFINE FIELD IF NOT EXISTS guid ON bunny_edge_rule_v2_model
  TYPE option<string>
  COMMENT 'The unique GUID of the edge rule';

DEFINE FIELD IF NOT EXISTS action_type ON bunny_edge_rule_v2_model
  TYPE option<string>
  COMMENT 'The action type of the edge rule';

DEFINE FIELD IF NOT EXISTS action_parameter1 ON bunny_edge_rule_v2_model
  TYPE option<string>
  COMMENT 'The Action parameter 1. The value depends on other parameters of the edge rule.';

DEFINE FIELD IF NOT EXISTS action_parameter2 ON bunny_edge_rule_v2_model
  TYPE option<string>
  COMMENT 'The Action parameter 2. The value depends on other parameters of the edge rule.';

DEFINE FIELD IF NOT EXISTS action_parameter3 ON bunny_edge_rule_v2_model
  TYPE option<string>
  COMMENT 'The Action parameter 3. The value depends on other parameters of the edge rule.';

DEFINE FIELD IF NOT EXISTS triggers ON bunny_edge_rule_v2_model
  TYPE option<array<option<record<trigger>>>>
  COMMENT 'The list of trigger that trigger the edge rule';

DEFINE FIELD IF NOT EXISTS extra_actions ON bunny_edge_rule_v2_model
  TYPE option<array<option<record<edge_rule_v2_action_model>>>>
  COMMENT 'Additional actions to be performed';

DEFINE FIELD IF NOT EXISTS trigger_matching_type ON bunny_edge_rule_v2_model
  TYPE option<string>
  COMMENT 'The trigger matching type';

DEFINE FIELD IF NOT EXISTS description ON bunny_edge_rule_v2_model
  TYPE option<string>
  COMMENT 'The description of the edge rule';

DEFINE FIELD IF NOT EXISTS enabled ON bunny_edge_rule_v2_model
  TYPE option<bool>
  COMMENT 'Determines if the edge rule is currently enabled or not';

DEFINE FIELD IF NOT EXISTS order_index ON bunny_edge_rule_v2_model
  TYPE option<int>
  COMMENT 'The index of the edge rule in the list of execution priority';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_edge_rule_v2_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_edge_rule_v2_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
