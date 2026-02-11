-- # SurrealDB Custom Function: fn::system_validate_required_fields_initialise
-- ## Description
-- This file initialises the `fn::system_validate_required_fields` function,
-- which checks if an object contains all specified required fields.

DEFINE FUNCTION IF NOT EXISTS fn::system_validate_required_fields_initialise(
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
    'Start: initialisation de la fonction `fn::system_validate_required_fields`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Define the main function
  DEFINE FUNCTION IF NOT EXISTS fn::system_validate_required_fields(
    $item: object,
    $fields: array<string>
  ) {
    -- Find missing fields
    LET $item_keys = object::keys($item);
    LET $missing_fields = array::filter($fields, |$f| !($f IN $item_keys) OR $item[$f] = NONE);
    
    -- Create errors for missing fields
    IF count($missing_fields) > 0 {
      LET $errors = array::map($missing_fields, |$field| {
        RETURN { field: $field, error: 'Le champ `' + $field + '` est obligatoire et ne peut 
        être vide.' };
      });
      RETURN { success: false, missing_fields: $missing_fields, errors: $errors };
    };

    RETURN { success: true };
  }
  COMMENT "Checks that an object has all the required properties and that they are not NONE. 
  Returns the missing fields and their errors."
  PERMISSIONS FULL;

  -- Finalisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_validate_required_fields`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    run_id: $run_id,
    parent_run_id: $parent_run_id,
    success: true
  };
}
COMMENT "Initialises the required fields validation function."
PERMISSIONS FULL;