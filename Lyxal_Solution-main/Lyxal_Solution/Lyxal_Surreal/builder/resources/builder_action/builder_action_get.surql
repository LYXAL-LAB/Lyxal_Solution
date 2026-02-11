DEFINE FUNCTION IF NOT EXISTS fn::builder_action_get(
  $code: string
) {
  LET $run_id = rand::uuid();
  LET $code_norm = string::trim($code);
  IF $code_norm = NONE OR string::len($code_norm) = 0 {
    RETURN { success: false, message: 'code requis', action: NONE, run_id: $run_id };
  };

  LET $ref = type::thing('builder_action', $code_norm);
  LET $row = SELECT * FROM $ref;
  IF array::len($row) = 0 {
    RETURN { success: false, message: 'action introuvable', action: NONE, run_id: $run_id };
  };
  RETURN { success: true, message: 'action trouvée', action: $row[0], run_id: $run_id };
}
COMMENT 'Récupère une action par code'
PERMISSIONS FULL;
