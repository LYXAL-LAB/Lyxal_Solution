-- # SurrealDB Custom Function: fn::system_validate_existing_bulk_initialise
-- ## Description
-- This file initialises the `fn::system_validate_existing_bulk` function,
-- which checks if values already exist in specified table fields.

DEFINE FUNCTION IF NOT EXISTS fn::system_validate_existing_bulk_initialise(
  $parent_run_id: option<string>
) {
  -- Parameters
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Initialisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], 
    $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_validate_existing_bulk`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Define the main function
  DEFINE FUNCTION IF NOT EXISTS fn::system_validate_existing_bulk(
    $items: array<object>
  ) {
    -- Process each item
    LET $results = array::map($items, |$item| {
      -- Check required fields
      LET $required = fn::system_validate_required_fields($item, ['table', 'field', 'value',
       'label']);
      IF $required.success != true {
        RETURN { success: false, errors: $required.errors, type: 'missing_fields' };
      };

      -- Prepare values
      LET $table = string::trim($item.table);
      LET $field = string::trim($item.field);
      LET $value = IF type::is::string($item.value) THEN string::trim($item.value) ELSE 
      $item.value END;

      -- Check for existence
      LET $existing = SELECT id FROM type::table($table) WHERE type::field($field) = 
      $value LIMIT 1;

      LET $found = count($existing) > 0;

      RETURN {
        success: !$found, -- Success means it does NOT exist (it's unique)
        value: $item.value,
        label: $item.label,
        type: IF $found THEN 'already_exists' ELSE 'unique' END,
        error: IF $found THEN $item.label + ' avec la valeur `' + <string>$item.value + 
        '` existe déjà.' ELSE NONE END
      };
    });

    -- Separate results
    LET $errors = array::filter($results, |$r| $r.success == false);
    LET $valids = array::filter($results, |$r| $r.success == true);

    RETURN {
      success: array::len($errors) == 0,
      results: $results,
      valids: $valids,
      errors: $errors
    };
  }
  COMMENT '
  Checks for the existence of each value in an array of objects {table, field, value, label}.
  Returns the list of results, separating unique values from those that already exist.
  Success is true if the value is unique (does not exist).
  '
  PERMISSIONS FULL;

  -- Finalisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_validate_existing_bulk`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    run_id: $run_id,
    parent_run_id: $parent_run_id,
    success: true
  };
}
COMMENT "Initialises the existence validation function."
PERMISSIONS FULL;
