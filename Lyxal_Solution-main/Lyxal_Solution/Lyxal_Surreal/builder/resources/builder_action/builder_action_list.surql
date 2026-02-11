DEFINE FUNCTION IF NOT EXISTS fn::builder_action_list(
  $only_active: option<bool>
) {
  LET $run_id = rand::uuid();
  LET $rows = SELECT * FROM builder_action;
  IF $only_active = true {
    $rows = array::filter($rows, |$r| $r.is_active = true);
  };
  RETURN { success: true, message: 'liste des actions', actions: $rows, run_id: $run_id };
}
COMMENT 'Liste des actions builder (filtre is_active optionnel)'
PERMISSIONS FULL;
