DEFINE FUNCTION IF NOT EXISTS fn::base_address_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_address', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_address TYPE NORMAL SCHEMAFULL
  COMMENT 'Address (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD country ON base_address TYPE record<base_country>;
  DEFINE FIELD department ON base_address TYPE option<string>;
  DEFINE FIELD subDepartment ON base_address TYPE option<string>;

  DEFINE FIELD addressL2 ON base_address TYPE option<string>;
  DEFINE FIELD addressL3 ON base_address TYPE option<string>;
  DEFINE FIELD addressL4 ON base_address TYPE option<string>;
  DEFINE FIELD addressL5 ON base_address TYPE option<string>;
  DEFINE FIELD addressL6 ON base_address TYPE option<string>;

  DEFINE FIELD streetName ON base_address TYPE option<string>;
  DEFINE FIELD street ON base_address TYPE option<record<base_street>>;
  DEFINE FIELD buildingNumber ON base_address TYPE option<string>;
  DEFINE FIELD buildingName ON base_address TYPE option<string>;
  DEFINE FIELD floor ON base_address TYPE option<string>;
  DEFINE FIELD postBox ON base_address TYPE option<string>;
  DEFINE FIELD room ON base_address TYPE option<string>;

  DEFINE FIELD townName ON base_address TYPE option<string>;
  DEFINE FIELD city ON base_address TYPE option<record<base_city>>;

  DEFINE FIELD zip ON base_address TYPE option<string>;
  DEFINE FIELD townLocationName ON base_address TYPE option<string>;
  DEFINE FIELD districtName ON base_address TYPE option<string>;
  DEFINE FIELD countrySubDivision ON base_address TYPE option<string>;

  DEFINE FIELD latit ON base_address TYPE option<decimal>;
  DEFINE FIELD longit ON base_address TYPE option<decimal>;
  DEFINE FIELD isValidLatLong ON base_address TYPE option<bool> DEFAULT true;
  DEFINE FIELD zoom ON base_address TYPE option<int>;
  DEFINE FIELD inseeCode ON base_address TYPE option<string>;
  DEFINE FIELD certifiedOk ON base_address TYPE option<bool> DEFAULT false;
  DEFINE FIELD pickList ON base_address TYPE array<record<base_pick_list_entry>> DEFAULT [];

  DEFINE FIELD fullName ON base_address TYPE option<string>;
  DEFINE FIELD formattedFullName ON base_address TYPE option<string>;

  DEFINE FIELD created_at ON base_address TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_address TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_address_country ON base_address FIELDS country;
  DEFINE INDEX idx_base_address_city ON base_address FIELDS city;
  DEFINE INDEX idx_base_address_zip ON base_address FIELDS zip;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_address', $sm.id, 'Adresses postales (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_address_create_table_initialise', $sm.id, 'Crée la table base_address', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_address', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_address'
PERMISSIONS FULL;

