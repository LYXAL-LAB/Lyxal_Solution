DEFINE FUNCTION IF NOT EXISTS fn::builder_action_category_list(
  $only_active: option<bool>
) {
  LET $run_id = rand::uuid();
  LET $rows = SELECT * FROM builder_action_category;
  IF $only_active = true {
    $rows = array::filter($rows, |$r| $r.is_active = true);
  };
  LET $sorted = array::sort::asc($rows, |$r| $r.sort_order);
  RETURN { success: true, message: 'liste des catégories', categories: $sorted, run_id: $run_id };
}
COMMENT 'Liste des catégories (filtre is_active optionnel, tri sort_order)'
PERMISSIONS FULL;
