-- # SurrealDB Custom Function: fn::system_validate_conformity_bulk_initialise
-- ## Description
-- This file initialises the `fn::system_validate_conformity_bulk` function,
-- which validates an array of objects for string length conformity.

DEFINE FUNCTION IF NOT EXISTS fn::system_validate_conformity_bulk_initialise(
  $parent_run_id: option<string>
) {
  -- Parameters
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Initialisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_validate_conformity_bulk`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Define the main function
  DEFINE FUNCTION IF NOT EXISTS fn::system_validate_conformity_bulk(
    $items: array<object>
  ) {
    -- Process each item
    LET $results = array::map($items, |$item| {
      -- Check required fields
      LET $required_check = fn::system_validate_required_fields($item, ['value', 'label']);
      IF $required_check.success == false {
        RETURN { success: false, errors: $required_check.errors, type: 'missing_fields' };
      };
      
      -- Set defaults for min/max length
      LET $trimmed = string::trim($item.value);
      LET $min = $item.min_length ?? 3;
      LET $max = $item.max_length ?? 50;
      
      -- Min length validation
      IF string::len($trimmed) < $min {
        RETURN { success: false, value: $item.value, error: $item.label + ' doit faire au moins '
         + <string>$min + ' caractères.', code: 'min_length' };
      };
      
      -- Max length validation
      IF string::len($trimmed) > $max {
        RETURN { success: false, value: $item.value, error: $item.label + ' ne peut pas dépasser '
         + <string>$max + ' caractères.', code: 'max_length' };
      };
      
      -- Validation successful
      RETURN { success: true, value: $trimmed, label: $item.label, type: 'valid' };
    });
    
    -- Separate valid results and errors
    LET $valids = array::filter($results, |$r| $r.success == true);
    LET $errors = array::filter($results, |$r| $r.success == false);

    RETURN {
      success: array::len($errors) == 0,
      results: $results,
      valids: $valids,
      errors: $errors
    };
  }
  COMMENT '
  Validates an array of objects: each object has its value, label, and optional min/max_length.
  Returns a status for each entry, the cleaned value, and an error message if it fails.
  '
  PERMISSIONS FULL;

  -- Finalisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_validate_conformity_bulk`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    run_id: $run_id,
    parent_run_id: $parent_run_id,
    success: true
  };
}
COMMENT 'Initialises the conformity validation function.'
PERMISSIONS FULL;