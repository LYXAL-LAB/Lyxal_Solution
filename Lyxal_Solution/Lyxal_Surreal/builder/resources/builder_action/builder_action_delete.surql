DEFINE FUNCTION IF NOT EXISTS fn::builder_action_delete(
  $code: string
) {
  LET $run_id = rand::uuid();
  LET $code_norm = string::trim($code);
  IF $code_norm = NONE OR string::len($code_norm) = 0 {
    RETURN { success: false, message: 'code requis', run_id: $run_id };
  };

  LET $ref = type::thing('builder_action', $code_norm);
  LET $row = SELECT id FROM $ref;
  IF array::len($row) = 0 {
    RETURN { success: false, message: 'action introuvable', run_id: $run_id };
  };

  DELETE $ref;
  RETURN { success: true, message: 'action supprimée', run_id: $run_id };
}
COMMENT 'Supprime une action par code'
PERMISSIONS FULL;
