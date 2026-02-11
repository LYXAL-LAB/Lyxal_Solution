-- # SurrealDB Custom Function: fn::system_sanitize_value_bulk_initialise
-- ## Description
-- This file initialises the `fn::system_sanitize_value_bulk` function,
-- which sanitizes an array of values based on specified patterns.

DEFINE FUNCTION IF NOT EXISTS fn::system_sanitize_value_bulk_initialise(
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
    'Start: initialisation de la fonction `fn::system_sanitize_value_bulk`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Define the main function
  DEFINE FUNCTION IF NOT EXISTS fn::system_sanitize_value_bulk(
    $items: array<object>
  ) {
    -- Use array::map to process each item
    LET $results = array::map($items, |$item| {
      -- Check required fields
      LET $required_check = fn::system_validate_required_fields($item, ['value', 'pattern_name']);
      IF $required_check.success != true {
        RETURN { success: false, original: $item.value ?? NONE, type: 'invalid' };
      };

      -- Define cleaning pattern by type
      LET $pattern = IF $item.pattern_name = 'email' THEN <regex>'[^a-zA-Z0-9@._-]'
          ELSE IF $item.pattern_name = 'alphanum' THEN <regex>'[^a-zA-Z0-9]'
          ELSE IF $item.pattern_name = 'letters' THEN <regex>'[^a-zA-Z]'
          ELSE IF $item.pattern_name = 'color' THEN <regex>'[^#a-zA-Z0-9]'
          ELSE IF $item.pattern_name = 'surrealdb_id' THEN <regex>'[^a-zA-Z0-9:_\\-]'
          ELSE IF $item.pattern_name = 'text' THEN <regex>'[^\\w\\s\\-\\.\/:()\\[\\],]'
          ELSE <regex>'[^\\w\\s\\-.]'
      END;

      -- Apply cleaning
      LET $clean = string::trim($item.value);
      $clean = string::replace($clean, $pattern, '');
      $clean = string::replace($clean, <regex>'\\s+', ' '); -- Replace multiple spaces with one
      $clean = string::trim($clean);

      -- Check if the result is empty after cleaning
      IF string::len($clean) = 0 {
        RETURN { success: false, original: $item.value, sanitized: '', type: 'invalid' };
      };

      -- Valid result
      RETURN { success: true, original: $item.value, sanitized: $clean, type: 'sanitized' };
    });

    -- Separate invalids and valids
    LET $invalids = array::filter($results, |$r| $r.success == false);
    LET $valids = array::filter($results, |$r| $r.success == true);

    RETURN {
      success: array::len($invalids) == 0,
      results: $results,
      valids: $valids,
      invalids: $invalids,
      total_valids: array::len($valids),
      total_invalids: array::len($invalids)
    };
  }
  COMMENT '
  Sanitizes an array of objects ({value, pattern_name}).
  Patterns: email, alphanum, letters, color, surrealdb_id, text, default.
  Returns an object with separated valid and invalid results.
  '
  PERMISSIONS FULL;

  -- Finalisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_sanitize_value_bulk`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    run_id: $run_id,
    parent_run_id: $parent_run_id,
    success: true
  };
}
COMMENT 'Initialises the value sanitization function.'
PERMISSIONS FULL;